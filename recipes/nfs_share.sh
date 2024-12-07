#!/bin/bash

# sudo apt install nfs-kernel-server
pre_dir="/mnt"

read -p "Enter the directory path (under /mnt): " directory_path

share="$pre_dir/$directory_path"

# create the directory if it doesn't exist
if ! [[ -d "$share" ]]; then
    mkdir -p "$share"
fi

chown -R romheat:romheat "$share"
find "$share" -type d -exec chmod 755 {} \;
find "$share" -type f -exec chmod 644 {} \;

# id romheat

# add to /etc/exports
# /mnt/share *(rw,all_squash,insecure,async,no_subtree_check,anonuid=1000,anongid=1000)
export="${share} *(rw,all_squash,insecure,async,no_subtree_check,anonuid=1000,anongid=1000)"
echo "${export}" >> /etc/exports

systemctl restart nfs-kernel-server

# show shares
exportfs