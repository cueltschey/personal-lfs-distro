#!/bin/bash

if [ $(whoami) != "lfs" ]; then
	su - lfs
fi

# Making binutils
cd /mnt/lfs/tools
tar -xvf ../sources/binutils-2.42.tar.xz
cd binutils-2.42
mkdir -pv build
cd build
../configure --prefix=$LFS/tools \
	--with-sysroot=$LFS \
	--target=$LFS_TGT \
	--disable-nls \
	--enable-gprofng=no \
	--disable-werror \
	--enable-default-hash-style=gnu

make && make install
cd /mnt/lfs/tools/

# Making gcc
tar -xvf ../sources/gcc-13.2.0.tar.xz
cp ../sources/mpfr-4.2.1.tar.xz ../sources/gmp-6.3.0.tar.xz ../sources/mpc-1.3.1.tar.gz .
cd gcc-13.2.0
tar -xf ../mpfr-4.2.1.tar.xz
mv -v mpfr-4.2.1 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc
case $(uname -m) in
x86_64)
	sed -e '/m64=/s/lib64/lib/' \
		-i.orig gcc/config/i386/t-linux64
	;;
esac
mkdir -pv build
cd build
../configure \
	--target=$LFS_TGT \
	--prefix=$LFS/tools \
	--with-glibc-version=2.39 \
	--with-sysroot=$LFS \
	--with-newlib \
	--without-headers \
	--enable-default-pie \
	--enable-default-ssp \
	--disable-nls \
	--disable-shared \
	--disable-multilib \
	--disable-threads \
	--disable-libatomic \
	--disable-libgomp \
	--disable-libquadmath \
	--disable-libssp \
	--disable-libvtv \
	--disable-libstdcxx \
	--enable-languages=c,c++
make && make install
cd /mnt/lfs/tools/

# Making Linux API headers

curl -O https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/linux-6.7.4.tar.gz
tar -xvf ./linux-6.7.4.tar.gz
cd linux-6.7.4
make mrproper && make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr
cd /mnt/lfs/tools/

# Making Glibc

tar -xvf ../sources/glibc-2.39.tar.xz
cp ../sources/glibc-2.39-fhs-1.patch .
cd glibc-2.39
case $(uname -m) in
i?86)
	ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
	;;
x86_64)
	ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
	ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
	;;
esac

patch -Np1 -i ../glibc-2.39-fhs-1.patch
mkdir -pv build
cd build
echo "rootsbindir=/usr/sbin" >configparms
../configure \
	--prefix=/usr \
	--host=$LFS_TGT \
	--build=$(../scripts/config.guess) \
	--enable-kernel=4.19 \
	--with-headers=$LFS/usr/include \
	--disable-nscd \
	libc_cv_slibdir=/usr/lib

make && make DESTDIR=$LFS install
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

echo 'int main(){}' | $LFS_TGT-gcc -xc -
readelf -l a.out | grep ld-linux
rm -v ./a.out

# Making libstdc++

cd /mnt/lfs/tools/gcc-13.2.0
rm -rf ./build
mkdir -pv build && cd build
../libstdc++-v3/configure \
	--host=$LFS_TGT \
	--build=$(../config.guess) \
	--prefix=/usr \
	--disable-multilib \
	--disable-nls \
	--disable-libstdcxx-pch \
	--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/13.2.0

make && make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la
