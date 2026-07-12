#!/usr/bin/env bash
# docker-info.sh — gather and display Docker system information
# Usage: docker-info.sh [-v|--verbose]

set -euo pipefail

VERBOSE=false

for arg in "$@"; do
  case "$arg" in
    -v|--verbose) VERBOSE=true ;;
    -h|--help)
      echo "Usage: $(basename "$0") [-v|--verbose]"
      echo "  -v, --verbose   Show container environment variables and full image details"
      exit 0
      ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
dim()   { printf '\033[2m%s\033[0m\n' "$*"; }
sep()   { printf '\033[2m%s\033[0m\n' "$(printf '─%.0s' {1..60})"; }
label() { printf '\033[1;36m%-18s\033[0m %s\n' "$1" "$2"; }

# ---------------------------------------------------------------------------
# Engine
# ---------------------------------------------------------------------------
bold "═══ Docker Engine"
sep
ENGINE_VER=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "unavailable")
label "Version:"    "$ENGINE_VER"
label "OS/Arch:"    "$(docker version --format '{{.Server.Os}}/{{.Server.Arch}}' 2>/dev/null)"
label "Storage:"    "$(docker info --format '{{.Driver}}' 2>/dev/null)"
label "Root dir:"   "$(docker info --format '{{.DockerRootDir}}' 2>/dev/null)"
label "Log driver:" "$(docker info --format '{{.LoggingDriver}}' 2>/dev/null)"
echo

# ---------------------------------------------------------------------------
# Disk usage
# ---------------------------------------------------------------------------
bold "═══ Disk Usage"
sep
docker system df
echo

# ---------------------------------------------------------------------------
# Images
# ---------------------------------------------------------------------------
bold "═══ Images ($(docker images -q | wc -l | tr -d ' '))"
sep
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedSince}}"
echo

# ---------------------------------------------------------------------------
# Containers
# ---------------------------------------------------------------------------
TOTAL=$(docker ps -aq | wc -l | tr -d ' ')
RUNNING=$(docker ps -q | wc -l | tr -d ' ')
bold "═══ Containers  (running: $RUNNING / total: $TOTAL)"
sep
docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
echo

if $VERBOSE; then
  for cid in $(docker ps -aq); do
    name=$(docker inspect --format '{{.Name}}' "$cid" | tr -d '/')
    bold "  ── $name"
    docker inspect --format \
      '  Image:   {{.Config.Image}}
  Created: {{.Created}}
  IP:      {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}
  Mounts:  {{range .Mounts}}{{.Source}} → {{.Destination}}  {{end}}' "$cid"
    env_vars=$(docker inspect --format '{{range .Config.Env}}  {{.}}{{"\n"}}{{end}}' "$cid")
    if [[ -n "$env_vars" ]]; then
      echo "  Env vars:"
      echo "$env_vars" | grep -v -E '(PASSWORD|SECRET|TOKEN|KEY)' || true
    fi
    echo
  done
fi

# ---------------------------------------------------------------------------
# Volumes
# ---------------------------------------------------------------------------
VOL_COUNT=$(docker volume ls -q | wc -l | tr -d ' ')
bold "═══ Volumes ($VOL_COUNT)"
sep
if [[ "$VOL_COUNT" -gt 0 ]]; then
  docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"
else
  dim "  No volumes found."
fi
echo

# ---------------------------------------------------------------------------
# Networks
# ---------------------------------------------------------------------------
NET_COUNT=$(docker network ls -q | wc -l | tr -d ' ')
bold "═══ Networks ($NET_COUNT)"
sep
docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"
echo

# ---------------------------------------------------------------------------
# Summary of dangling/unused resources
# ---------------------------------------------------------------------------
DANGLING_IMAGES=$(docker images -f dangling=true -q | wc -l | tr -d ' ')
STOPPED=$(docker ps -a -f status=exited -q | wc -l | tr -d ' ')
UNUSED_VOLS=$(docker volume ls -f dangling=true -q | wc -l | tr -d ' ')

bold "═══ Cleanup Candidates"
sep
label "Dangling images:"  "$DANGLING_IMAGES"
label "Stopped containers:" "$STOPPED"
label "Unused volumes:"   "$UNUSED_VOLS"
if [[ "$DANGLING_IMAGES" -gt 0 || "$STOPPED" -gt 0 || "$UNUSED_VOLS" -gt 0 ]]; then
  echo
  dim "  Run docker-prune.sh to reclaim space."
fi
echo
