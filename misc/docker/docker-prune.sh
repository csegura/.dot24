#!/usr/bin/env bash
# docker-prune.sh — safely clean up unused Docker resources
# Usage: docker-prune.sh [OPTIONS]
#
# Prune targets (all selected by default):
#   --containers   Remove stopped containers
#   --images       Remove dangling (untagged) images
#   --images-all   Remove ALL unused images (not just dangling)
#   --volumes      Remove unused volumes  ⚠ data loss risk
#   --networks     Remove unused networks
#   --all          All of the above (except --images-all)
#   --full         Everything including all unused images
#
# Other options:
#   -f, --force    Skip confirmation prompts
#   -n, --dry-run  Show what would be removed without removing anything
#   -h, --help     Show this help

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
DO_CONTAINERS=false
DO_IMAGES=false
DO_IMAGES_ALL=false
DO_VOLUMES=false
DO_NETWORKS=false
FORCE=false
DRY_RUN=false
ANY_TARGET=false

# ---------------------------------------------------------------------------
# Parse args
# ---------------------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    --containers)  DO_CONTAINERS=true; ANY_TARGET=true ;;
    --images)      DO_IMAGES=true; ANY_TARGET=true ;;
    --images-all)  DO_IMAGES_ALL=true; ANY_TARGET=true ;;
    --volumes)     DO_VOLUMES=true; ANY_TARGET=true ;;
    --networks)    DO_NETWORKS=true; ANY_TARGET=true ;;
    --all)
      DO_CONTAINERS=true; DO_IMAGES=true; DO_NETWORKS=true
      ANY_TARGET=true
      ;;
    --full)
      DO_CONTAINERS=true; DO_IMAGES=true; DO_IMAGES_ALL=true
      DO_VOLUMES=true; DO_NETWORKS=true
      ANY_TARGET=true
      ;;
    -f|--force)    FORCE=true ;;
    -n|--dry-run)  DRY_RUN=true ;;
    -h|--help)
      sed -n '2,20p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
bold()    { printf '\033[1m%s\033[0m\n' "$*"; }
warn()    { printf '\033[1;33m⚠  %s\033[0m\n' "$*"; }
ok()      { printf '\033[1;32m✔  %s\033[0m\n' "$*"; }
info()    { printf '\033[1;36mℹ  %s\033[0m\n' "$*"; }
sep()     { printf '\033[2m%s\033[0m\n' "$(printf '─%.0s' {1..60})"; }

confirm() {
  local msg="$1"
  if $FORCE; then return 0; fi
  printf '\033[1;33m%s [y/N] \033[0m' "$msg"
  read -r reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

run_or_dry() {
  # run_or_dry <description> <cmd...>
  local desc="$1"; shift
  if $DRY_RUN; then
    info "[dry-run] $desc: $*"
  else
    eval "$@"
  fi
}

# Apply safe defaults when no target was explicitly chosen
if ! $ANY_TARGET; then
  DO_CONTAINERS=true
  DO_IMAGES=true
  DO_NETWORKS=true
fi

# ---------------------------------------------------------------------------
# Show current state
# ---------------------------------------------------------------------------
bold "═══ Current Docker Disk Usage"
sep
docker system df
echo

# ---------------------------------------------------------------------------
# Build summary of what will be removed
# ---------------------------------------------------------------------------
STOPPED_IDS=$(docker ps -a -f status=exited -q)
DANGLING_IDS=$(docker images -f dangling=true -q)
UNUSED_VOL_NAMES=$(docker volume ls -f dangling=true -q)
UNUSED_NET_IDS=$(docker network ls -f type=custom -q)

STOPPED_COUNT=$(echo "$STOPPED_IDS" | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')
DANGLING_COUNT=$(echo "$DANGLING_IDS" | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')
UNUSED_VOL_COUNT=$(echo "$UNUSED_VOL_NAMES" | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')
UNUSED_NET_COUNT=$(echo "$UNUSED_NET_IDS" | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')

bold "═══ Prune Plan"
sep
$DO_CONTAINERS && echo "  • Stopped containers : $STOPPED_COUNT"
$DO_IMAGES     && echo "  • Dangling images    : $DANGLING_COUNT"
$DO_IMAGES_ALL && echo "  • ALL unused images  : $(docker images -q | wc -l | tr -d ' ') (dangling + unneeded)"
$DO_VOLUMES    && warn "  Unused volumes       : $UNUSED_VOL_COUNT  (DATA LOSS RISK)"
$DO_NETWORKS   && echo "  • Unused networks    : $UNUSED_NET_COUNT"
echo

if $DRY_RUN; then
  warn "DRY RUN — nothing will be removed."
  echo
fi

# ---------------------------------------------------------------------------
# Stopped containers
# ---------------------------------------------------------------------------
if $DO_CONTAINERS; then
  if [[ -n "$STOPPED_IDS" ]]; then
    bold "── Stopped containers"
    docker ps -a -f status=exited --format "  {{.Names}} ({{.Image}}, exited {{.Status}})"
    echo
    if confirm "Remove stopped containers?"; then
      run_or_dry "Removing stopped containers" "docker container prune -f"
      ok "Stopped containers removed."
    fi
  else
    info "No stopped containers."
  fi
  echo
fi

# ---------------------------------------------------------------------------
# Dangling images
# ---------------------------------------------------------------------------
if $DO_IMAGES; then
  if [[ -n "$DANGLING_IDS" ]]; then
    bold "── Dangling images"
    docker images -f dangling=true --format "  {{.Repository}}:{{.Tag}} {{.ID}} ({{.Size}})"
    echo
    if confirm "Remove dangling images?"; then
      run_or_dry "Removing dangling images" "docker image prune -f"
      ok "Dangling images removed."
    fi
  else
    info "No dangling images."
  fi
  echo
fi

# ---------------------------------------------------------------------------
# All unused images
# ---------------------------------------------------------------------------
if $DO_IMAGES_ALL; then
  UNUSED=$(docker images -f dangling=true -q; \
    comm -23 \
      <(docker images -q | sort -u) \
      <(docker ps -aq | xargs -r docker inspect --format '{{.Image}}' | sort -u) \
    2>/dev/null || true)
  if [[ -n "$UNUSED" ]]; then
    bold "── All unused images"
    docker images --format "  {{.Repository}}:{{.Tag}} {{.ID}} ({{.Size}})"
    echo
    warn "This removes images not referenced by any container (running or stopped)."
    if confirm "Remove ALL unused images?"; then
      run_or_dry "Removing all unused images" "docker image prune -a -f"
      ok "All unused images removed."
    fi
  else
    info "No unused images."
  fi
  echo
fi

# ---------------------------------------------------------------------------
# Unused volumes
# ---------------------------------------------------------------------------
if $DO_VOLUMES; then
  if [[ -n "$UNUSED_VOL_NAMES" ]]; then
    bold "── Unused volumes"
    echo "$UNUSED_VOL_NAMES" | sed 's/^/  /'
    echo
    warn "Removing volumes permanently deletes their data!"
    if confirm "Remove unused volumes? (IRREVERSIBLE)"; then
      run_or_dry "Removing unused volumes" "docker volume prune -f"
      ok "Unused volumes removed."
    fi
  else
    info "No unused volumes."
  fi
  echo
fi

# ---------------------------------------------------------------------------
# Unused networks
# ---------------------------------------------------------------------------
if $DO_NETWORKS; then
  if [[ -n "$UNUSED_NET_IDS" ]]; then
    bold "── Unused networks"
    docker network ls -f type=custom --format "  {{.Name}} ({{.Driver}})"
    echo
    if confirm "Remove unused networks?"; then
      run_or_dry "Removing unused networks" "docker network prune -f"
      ok "Unused networks removed."
    fi
  else
    info "No unused custom networks."
  fi
  echo
fi

# ---------------------------------------------------------------------------
# Final disk usage
# ---------------------------------------------------------------------------
if ! $DRY_RUN; then
  bold "═══ Docker Disk Usage After Prune"
  sep
  docker system df
fi
echo
