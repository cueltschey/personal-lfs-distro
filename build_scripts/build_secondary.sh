#!/bin/bash

if [ $(whoami) != "lfs" ]; then
	su - lfs
fi

cd /mnt/lfs/tools/
# Making m4

tar -xvf ../sources/m4-1.4.19.tar.xz
cd m4-1.4.19
./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(build-aux/config.guess)
make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/

# Making Ncurses

tar -xvf ../sources/ncurses-6.4-20230520.tar.xz
cd ncurses-6.4-20230520
sed -i s/mawk// configure
mkdir build
pushd build
../configure
make -C include
make -C progs tic
popd
./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(./config.guess) \
	--mandir=/usr/share/man \
	--with-manpage-format=normal \
	--with-shared \
	--without-normal \
	--with-cxx-shared \
	--without-debug \
	--without-ada \
	--disable-stripping \
	--enable-widec
make
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
	-i $LFS/usr/include/curses.h
cd /mnt/lfs/tools/

# Making Bash

tar -xvf ../sources/bash-5.2.21.tar.gz
cd bash-5.2.21
./configure --prefix=/usr \
	--build=$(sh support/config.guess) \
	--host=$LFS_TGT \
	--without-bash-malloc

make && make DESTDIR=$LFS install
ln -sv bash $LFS/bin/sh
cd /mnt/lfs/tools/

# Making coreutils

tar -xvf ../sources/coreutils-9.4.tar.xz
cd coreutils-9.4
./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(build-aux/config.guess) \
	--enable-install-program=hostname \
	--enable-no-install-program=kill,uptime
make && make DESTDIR=$LFS install
mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
cd /mnt/lfs/tools/

# Making diffutils
tar -xvf ../sources/diffutils-3.10.tar.xz
cd diffutils-3.10

./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(./build-aux/config.guess)

make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/

# Making File

tar -xvf ../sources/file-5.45.tar.gz
cd file-5.45

mkdir build
pushd build
../configure --disable-bzlib \
	--disable-libseccomp \
	--disable-xzlib \
	--disable-zlib
make
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/libmagic.la
cd /mnt/lfs/tools/

# Making Find

tar -xvf ../sources/findutils-4.9.0.tar.xz
./configure --prefix=/usr \
	--localstatedir=/var/lib/locate \
	--host=$LFS_TGT \
	--build=$(build-aux/config.guess)

make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/

# Making Gawk

tar -xvf ../sources/gawk-5.3.0.tar.xz
cd gawk-5.3.0
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(build-aux/config.guess)

make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/

# Making Grep

tar -xvf ../sources/grep-3.11.tar.xz
cd grep-3.11
./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(./build-aux/config.guess)

make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/

# Making Gzip

tar -xvf ../sources/gzip-1.13.tar.xz
cd gzip-1.13
./configure --prefix=/usr --host=$LFS_TGT

make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/

# Making Make

tar -xvf ../sources/make-4.4.1.tar.gz
cd make-4.4.1
./configure --prefix=/usr \
	--without-guile \
	--host=$LFS_TGT \
	--build=$(build-aux/config.guess)

make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/

# Making Patch

tar -xvf ../sources/patch-2.7.6.tar.xz
cd patch-2.7.6
./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(build-aux/config.guess)

make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/

# Making Sed

tar -xvf ../sources/sed-4.9.tar.xz
cd sed-4.9
./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(./build-aux/config.guess)

make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/

# Making Tar

tar -xvf ../sources/tar-1.35.tar.xz
cd tar-1.35
./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(build-aux/config.guess)

make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/

# Makig XZ

tar -xvf ../sources/xz-5.4.6.tar.xz
cd xz-5.4.6
./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(build-aux/config.guess) \
	--disable-static \
	--docdir=/usr/share/doc/xz-5.4.6

make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/

rm -v $LFS/usr/lib/liblzma.la

# Making Binutils Pass 2

cd binutils-2.42
rm -rf ./build
mkdir -pv ./build
cd build
../configure \
	--prefix=/usr \
	--build=$(../config.guess) \
	--host=$LFS_TGT \
	--disable-nls \
	--enable-shared \
	--enable-gprofng=no \
	--disable-werror \
	--enable-64-bit-bfd \
	--enable-default-hash-style=gnu

make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/
rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

# Making gcc pass 2

cd gcc-13.2.0
case $(uname -m) in
x86_64)
	sed -e '/m64=/s/lib64/lib/' \
		-i.orig gcc/config/i386/t-linux64
	;;
esac
sed '/thread_header =/s/@.*@/gthr-posix.h/' \
	-i libgcc/Makefile.in libstdc++-v3/include/Makefile.in
rm -rf ./build
mkdir ./build
cd build
../configure \
	--build=$(../config.guess) \
	--host=$LFS_TGT \
	--target=$LFS_TGT \
	LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc \
	--prefix=/usr \
	--with-build-sysroot=$LFS \
	--enable-default-pie \
	--enable-default-ssp \
	--disable-nls \
	--disable-multilib \
	--disable-libatomic \
	--disable-libgomp \
	--disable-libquadmath \
	--disable-libsanitizer \
	--disable-libssp \
	--disable-libvtv \
	--enable-languages=c,c++

make && make DESTDIR=$LFS install
cd /mnt/lfs/tools/
ln -sv gcc $LFS/usr/bin/cc
