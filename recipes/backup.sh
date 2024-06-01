now=$(date +"%Y_%m_%d")
dst="/mnt/disk/backup/$now"
mkdir -p $dst

START_TIME=$(date +%s)

sudo rsync -a --info=progress2 --exclude="lost+found" --exclude=".cache" /home/romheat/ $dst

ELAPSED=$(($(date +%s) - START_TIME))
printf "elapsed: %s\n\n" "$(date -d@$ELAPSED -u +%H\ hours\ %M\ min\ %S\ sec)"

