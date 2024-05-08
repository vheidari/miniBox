#!/bin/sh


# wget
WGET=wget

# kernel and busybox version
KERNEL_VERSION=6.8.9
KERNEL_MAJOR_VERSION=$(echo $KERNEL_VERSION | grep -o -e ^.)
BUSYBOX_VERSION=1.36.1

# kernel and busybox name
KERNEL_NAME=linux-$KERNEL_VERSION.tar.xz
BUSYBOX_NAME=busybox-$BUSYBOX_VERSION.tar.bz2


# kernel and busybox url
KERNEL_URL=https://mirrors.edge.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR_VERSION.x/$KERNEL_NAME
BUSYBOX_URL=https://busybox.net/downloads/$BUSYBOX_NAME


# build directory
BUILDDIR=Build

# download directory
LINUXKERNEL_DOWNLOADDIR=./Download/linuxKernel
BUSYBOX_DOWNLOADDIR=./Download/busyBox

DownloadFiles() {
	echo "Start download ${3} in to ${2} Directory." 
	echo "Please wait to download file complete ...."
	$WGET $1 -P $2
	echo "Download is done :)"
}

# downlod kernel to download directory
DownloadFiles $KERNEL_URL $LINUXKERNEL_DOWNLOADDIR $KERNEL_NAME

# download busybox to download directory
DownloadFiles $BUSYBOX_URL $BUSYBOX_DOWNLOADDIR $BUSYBOX_NAME


