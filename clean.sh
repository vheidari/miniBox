#!/bin/sh

BUSYBOX_DOWNLOADDIR=./Download/busyBox
LINUXKERNEL_DOWNLOADDIR=./Download/linuxKernel
BUILDDIR=./Build

# remove downloaded kernel and busybox file inside download directory
cd $BUSYBOX_DOWNLOADDIR
rm ./*.bz2
cd ../..
cd $LINUXKERNEL_DOWNLOADDIR
rm ./*.xz
cd ../..

rm -rf $BUILDDIR
mkdir $BUILDDIR
touch $BUILDDIR/.nothing
