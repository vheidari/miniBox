#!/bin/sh

BUSYBOX_DOWNLOADDIR=./Download/busyBox
LINUXKERNEL_DOWNLOADDIR=./Download/linuxKernel
BUILDDIR=./Build

# remove downloaded kernel and busybox file inside download directory
cd $BUSYBOX_DOWNLOADDIR
rm ./*.bz2
ls
rm -rf ./busybox-*
cd ../..
cd $LINUXKERNEL_DOWNLOADDIR
rm ./*.xz
ls
rm -rf ./linux-*
cd ../..

rm -rf $BUILDDIR
mkdir $BUILDDIR
touch $BUILDDIR/.nothing
