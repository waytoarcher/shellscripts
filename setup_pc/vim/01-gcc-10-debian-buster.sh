#!/bin/bash
#
# Steps to build GCC 10 on Debian Buster.
#

set -e -x

if ! [ "$(id -u)" -eq 0 ]; then
        error "Please run $0 with non-root."
        exit 1
fi
# Install all dependencies.
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y wget xz-utils bzip2 make autoconf gcc-multilib g++-multilib
cd /var/tmp
# Download GCC sources.
proxychains wget https://ftp.wrz.de/pub/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.xz
tar xf gcc-10.2.0.tar.xz
cd gcc-10.2.0
wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz
tar xf gmp-6.2.0.tar.xz
mv gmp-6.2.0 gmp
wget https://ftp.gnu.org/gnu/mpfr/mpfr-4.1.0.tar.gz
tar xf mpfr-4.1.0.tar.gz
mv mpfr-4.1.0 mpfr
wget ftp://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz
tar xf mpc-1.2.1.tar.gz
mv mpc-1.2.1 mpc
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2
tar xf isl-0.18.tar.bz2
mv isl-0.18 isl

# Build and install it.
./configure --prefix=/opt/gcc-10 --enable-languages=c,c++
make -j$(nproc)
make install

# Create an archive of the installed version.
cd /opt
tar cvJf gcc-10.2.0-debian-buster.tar.xz gcc-10

# Usage example:
#
# CC=/opt/gcc-10/bin/gcc CXX=/opt/gcc-10/bin/g++ LDFLAGS="-Wl,-rpath,/opt/gcc-10/lib64" cmake [..]
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/gcc-10/lib64/
#

echo '
Please set:
export CC=/opt/gcc-10/bin/gcc
export CXX=/opt/gcc-10/bin/g++
export LDFLAGS="-Wl,-rpath,/opt/gcc-10/lib64"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/gcc-10/lib64/
'
