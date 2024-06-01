#!/bin/bash
export LFS=/mnt/lfs

echo "Creating a new partition"
dd if=/dev/zero of=/dev/sd1 bs=1G count=20
mkfs.ext4 /dev/sd1
mkdir -pv /mnt/lfs
mount -o loop /dev/sd1 /mnt/lfs

cp ./curl.txt ./build_initial.sh ./build_secondary.sh ./chroot.sh /mnt/lfs/

cd /mnt/lfs/

mkdir -pv ./sources
chmod a+wt ./sources
cd sources
cat ../curl.txt | while read -r url; do curl -O $url; done
cd ..
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
	ln -sv usr/$i $LFS/$i
done

case $(uname -m) in
x86_64) mkdir -pv $LFS/lib64 ;;
esac

mkdir -pv tools

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
passwd lfs

chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
x86_64) chown -v lfs $LFS/lib64 ;;
esac

chown -v -R lfs:lfs /home/lfs

su - lfs

cat >~/.bash_profile <<"EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat >~/.bashrc <<"EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF

cat >>~/.bashrc <<"EOF"
export MAKEFLAGS=-j$(nproc)
EOF

source ~/.bash_profile
