#!/usr/bin/env bash

apt -y install cmake make autoconf libtool pkg-config clang libblocksruntime-dev libkqueue-dev libbsd-dev libicu-dev || exit 1

if [ ! -d libs ]
then
  mkdir libs || exit 1
fi

cd libs || exit 1

# libpwq

if [ ! -e "libpwq" ]
then
  git clone git://github.com/mheily/libpwq.git || exit 1
fi

cd libpwq || exit 1

if [ ! -e "/usr/include/" ]
then
  cp include/pthread_workqueue.h /usr/include/ || exit 1
fi

if [ ! -e "/usr/lib/libpthread_workqueue.so" ]
then
  cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ || exit 1
  make || exit 1
  cp libpthread_workqueue.so /usr/lib/ || exit 1
fi

cd .. || exit 1

# libdispatch

if [ ! -e "swift-corelibs-libdispatch" ]
then
  git clone "git://github.com/apple/swift-corelibs-libdispatch.git" || exit 1
fi

cd swift-corelibs-libdispatch || exit 1

if [ ! -e "/usr/lib/libdispatch.so" ]
then
  ./autogen.sh || exit 1
  ./configure --prefix=/usr CC=clang CXX=clang++ || exit 1
  make || exit 1
  make install || exit 1
fi

cd .. || exit 1

# CF-Lite

if [ ! -e "CF-855.17" ]
then
  wget -c "https://opensource.apple.com/tarballs/CF/CF-855.17.tar.gz" || exit 1
  tar --no-same-owner --no-same-permissions -xvf CF-855.17.tar.gz || exit 1
  patch -p0 < ../CF-855.17.patch || exit 1
fi

cd CF-855.17 || exit 1

if [ ! -e "/usr/lib/libCoreFoundation.so" ]
then
    make -f MakefileLinux || exit 1
    make -f MakefileLinux install || exit 1
fi

cd .. || exit 1


if [ ! -e "swift-2.2.1-RELEASE-ubuntu15.10" ]
then
    wget -c "https://swift.org/builds/swift-2.2.1-release/ubuntu1510/swift-2.2.1-RELEASE/swift-2.2.1-RELEASE-ubuntu15.10.tar.gz" || exit 1
    tar -xvf swift-2.2.1-RELEASE-ubuntu15.10.tar.gz || exit 1
fi

cd swift-2.2.1-RELEASE-ubuntu15.10 || exit 1

if [ ! -e "/usr/bin/swiftc" ]
then
    cp -r usr/lib/swift /usr/lib/ || exit 1
    cp usr/bin/* /usr/bin || exit 1
fi

cd .. || exit 1

cd .. || exit 1

if [ ! -e "/usr/lib/swift/CoreFoundation" ]
then
    cp -r modules/* /usr/lib/swift
fi
