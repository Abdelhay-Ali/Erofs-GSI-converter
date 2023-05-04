#!/usr/bin/env bash

msg(){
    echo
    echo "==> $*"
    echo
}

err(){
    echo 1>&2
    echo "==> $*" 1>&2
    echo 1>&2
}

set_output(){
    echo "$1=$2" >> $GITHUB_OUTPUT
}

extract_tarball(){
    echo "Extracting $1 to $2"
    tar xf "$1" -C "$2"
}
#: <<'END'
workdir="$GITHUB_WORKSPACE"
arch="$1"
compiler="$2"
defconfig="$3"
image="$4"
repo_name="${GITHUB_REPOSITORY/*\/}"
zipper_path="${ZIPPER_PATH:-zipper}"
kernel_path="${KERNEL_PATH:-.}"
name="${NAME:-$repo_name}"
python_version="${PYTHON_VERSION:-3}"

msg "Updating container..."
apt update && apt upgrade -y




msg "Installing essential packages..."
apt install -y --no-install-recommends git make bc bison openssl \
    curl zip wget erofs-utils xz-utils
    
set_output hash "$(cd "$kernel_path" && git rev-parse HEAD || exit 127)"
git config --global --add safe.directory /github/workspace

#sudo rm -f /etc/ssl/certs/ca-bundle.crt
#sudo apt reinstall ca-certificates
#sudo update-ca-certificates
#curl --remote-name https://github.com/ponces/treble_build_evo/releases/download/v2023.05.04/evolution_arm64-ab-vndklite-7.9-unofficial-20230503.img.xz

msg "Download GSI..."

wget --no-check-certificate https://github.com/ponces/treble_build_evo/releases/download/v2023.05.04/evolution_arm64-ab-vndklite-7.9-unofficial-20230503.img.xz

msg "Extract GSI..."
tar -xvf evolution_arm64-ab-vndklite-7.9-unofficial-20230503.img.xz
git config --global --add safe.directory /github/workspace

sleep 5

ls
pwd
msg "Convert GSI..."
rm -Rf tmp
mkdir -p d tmp
e2fsck -y -f evolution_arm64-ab-vndklite-7.9-unofficial-20230503.img
resize2fs evolution_arm64-ab-vndklite-7.9-unofficial-20230503.img. 5000M
e2fsck -E unshare_blocks -y -f evolution_arm64-ab-vndklite-7.9-unofficial-20230503.img
mount -o loop,rw evolution_arm64-ab-vndklite-7.9-unofficial-20230503.img d
sleep 1
rm -Rf evolution_arm64-ab-vndklite-7.9-unofficial-20230503.img
mkfs.erofs -E legacy-compress -zlz4hc -d2 evolution_arm64-ab-vndklite-7.9-unofficial-20230503-erofs.img d/
umount d



set_output outfile evolution_arm64-ab-vndklite-7.9-unofficial-20230503-erofs.img

    exit 0
