#!/bin/sh

mycmd=$(basename $0)
if [ -z "$2" ]; then
  echo "Usage: $mycmd input_image.vmdk output_image.vdi"
  exit 1
fi

set -e
echo "Checking existence of VBoxManage"
VBoxManage --version
echo "Checking existence of qemu-img"
which qemu-img
set +e
echo "\n"

tempfile=$(mktemp -t $mycmd)

echo "Converting from vmdk to binary"
qemu-img convert -p "$1" "$tempfile"

tempinfo=( $(ls -on "$tempfile") )
tempsize=${tempinfo[3]}

cat "$tempfile" | pv -s $tempsize | VBoxManage convertdd stdin "$2" $tempsize

unlink "$tempfile"
