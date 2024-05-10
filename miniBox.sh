#!/bin/bash


##########################################################
#			Variables
##########################################################

# wget
WGET=wget

# kernel and busybox version
# first test version for linux : 6.8.9 and for busybox was 1.36.1
# second test version for linux : 5.15.6 and for busybox was 1.34.1
# [Help] - to download a different version of the linux and busybox you can modify `KERNEL_VERSION` and `BUSYBOX VERSION
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
BUILDDIR=./Build
INITRD=initrd

# download directory
LINUXKERNEL_DOWNLOADDIR=./Download/linuxKernel
BUSYBOX_DOWNLOADDIR=./Download/busyBox

#--------------------------------------------------------------
# make && number of process
BUILDER=make
NUMBEROFPROCESS=$(nproc)

#--------------------------------------------------------------

MACHINE=qemu-system-x86_64
KERNEL_FLAG=-kernel
INITRD_FLAG=-initrd
KERNEL_FILE=bzImage
INITRD_FILE=initrd.img
PREFIX_FLAGS='-nographic -no-reboot'
POSTFIX_FLAGS='-m 1024'
APPEND_FLAGS=-'append "console=ttyS0"'
#-------------------------------------------------------------

MINIBOX_VERSION='v0.1'
MINIBOX_AUTHOR=@vheidari
MINIBOX_URL=https://github.com/vheidari/miniBox
#-------------------------------------------------------------

##########################################################
#			Functions
##########################################################

# decompress files
DeCompressFiles() {
 	# $1 = stand for file directoy
	# $2 = stand for file name
	decompressor=
	decompressorFlags=
	destinationDir=$1
	fileName=$2
	fileExt=$(echo $fileName | grep -o -E ".zip$|.tar.xz$|.tar.bz2$" )	

	if [[ $fileExt =  '.zip' ]]; then
		decompressor=unzip
	elif [[ $fileExt = '.tar.xz' || $fileExt = '.tar.bz2' ]]; then
		decompressor=tar
		if [[ $fileExt = '.tar.xz' ]]; then
			decompressorFlags=-xf
		elif [[ $fileExt = '.tar.bz2' ]]; then
			decompressorFlags=-xjf
		fi	
	fi
	
	cd $destinationDir
	echo "-----------------------------------------------"
	echo "Start decompress ${fileName} in to ${destinationDir} Directory." 
	echo "Please wait to decompress ${fileName} ...."
	echo "-----------------------------------------------"
	echo ""
	
	# decompress file in destination
	$decompressor $decompressorFlags $fileName
	
	echo ""
	echo "All most done :)"
	echo ""
	cd ../..
}


# downloading neccecary files
DownloadFiles() {
	# $1 = stand for download url
	# $2 = stand for downlod file name
	# $3 = stand for download directory name
	echo "-----------------------------------------------"
	echo "Start download ${3} in to ${2} Directory." 
	echo "Please wait to download file complete ...."
	echo "-----------------------------------------------"
	echo ""
	$WGET $1 -P $2
	echo ""
	echo "Download is done :)"
	echo ""
}


# compile source code
DoCompile() {
	# $1 = stand for filename
	# $2 = stand for destination directoy
	fileName=$1
	destinationDir=$2
	compileDir=$(echo $fileName | sed 's/.tar.*//')

	echo "-----------------------------------------------"
	echo "Start compiling ${fileName}." 
	echo "Please wait to Compiling progress finish ...."
	echo "-----------------------------------------------"
	echo ""
	cd $destinationDir/$compileDir

	$BUILDER defconfig
	
	# set prapre config on busybox
	if [[ $fileName = $BUSYBOX_NAME ]]; then
		cat .config | sed "s/# CONFIG_STATIC is not set/CONFIG_STATIC=y/" > .bk_config
		mv ./.bk_config ./.config
	fi

	# start build project	
	$BUILDER -j $NUMBEROFPROCESS || exit
	
	cd ../../..

	echo ""
	echo "Thats cool, ${fileName} compiled :)"
	echo ""
}


# create initrd.img
InitImage() {
	initrdDir=$BUILDDIR/$INITRD
	cd $initrdDir
		find . | cpio -o -H newc > ../$INITRD_FILE
		cd ..
	# removing initrd directory after initrd.im made
	rm -rf ./$INITRD
	cd ..
}



# generate init script
InitScript() {
	initrdDir=$BUILDDIR/$INITRD
	cd $initrdDir
		echo '#!/bin/sh' > init
		echo 'mount -t sysfs sysfs /sys' >> init
		echo 'mount -t proc proc /proc' >> init
		echo 'mount -t devtmpfs udev /dev' >> init
		echo 'clear' >> init
		echo 'echo "       _     _ _____         "' >> init
		echo 'echo " _____|_|___|_| __  |___ _ _ "' >> init
		echo 'echo "|     | |   | | __ -| . |_| |"' >> init
		echo 'echo "|_|_|_|_|_|_|_|_____|___|_,_|"' >> init
		echo 'echo ' >> init
		echo 'echo ----------------------------------------------------' >> init
		echo 'echo --------- Hey Guys !!, Welcome to miniBox ----------' >> init
		echo 'echo MiniBox Version      :' $MINIBOX_VERSION >> init
		echo 'echo Linux Kernel Version :' $KERNEL_VERSION >> init
		echo 'echo Busybox Version      :' $BUSYBOX_VERSION >> init
		echo 'echo ----------------------------------------------------' >> init
		echo 'echo MiniBox Author       :' $MINIBOX_AUTHOR >> init
		echo 'echo MiniBox Home Url     :' $MINIBOX_URL >> init
		echo 'echo ----------------------------------------------------' >> init
		echo 'echo ' >> init
		echo '/bin/sh' >> init
		echo 'poweroff -f' >> init
		
		chmod +x ./init
		chmod -R 777 .
	cd ../..

	# create InitImage
	InitImage
}	


# generate neccacery directory inside build
PrepareBuildDir() {
	
	linuxKernelBuildDirectory=$(echo $KERNEL_NAME | sed 's/.tar.*//')

	busyBoxBuildDirectory=$(echo $BUSYBOX_NAME | sed 's/.tar.*//')

	linuxKernelFilePath=../$LINUXKERNEL_DOWNLOADDIR/$linuxKernelBuildDirectory/arch/x86_64/boot/bzImage
	busyBoxFilePath=../../$BUSYBOX_DOWNLOADDIR/$busyBoxBuildDirectory/busybox
		
	cd $BUILDDIR
	
	# copy linux kernel to root Directory
	cp $linuxKernelFilePath ./

	mkdir $INITRD
       	cd ./$INITRD	
		mkdir -p bin sys dev proc etc
		cp $busyBoxFilePath ./bin
			cd ./bin
			for program in $(./busybox --list); do
				ln -s ./busybox ./$program
			done 
			cd ..
		cd ..
	cd ..

	# run init script generator
	InitScript	

}

#  run kernel and initrd image through virtual machine (Qemu)
DeployOnTheMachine() {
	# run machine
	$MACHINE ${PREFIX_FLAGS} ${KERNEL_FLAG} ${KERNEL_FILE} ${INITRD_FLAG} ${INITRD_FILE} ${APPEND_FLAGS} ${POSTFIX_FLAGS}
}


#-------------------------------------------------------------

# downlod kernel to download directory
DownloadFiles $KERNEL_URL $LINUXKERNEL_DOWNLOADDIR $KERNEL_NAME

# download busybox to download directory
DownloadFiles $BUSYBOX_URL $BUSYBOX_DOWNLOADDIR $BUSYBOX_NAME
#-------------------------------------------------------------

# decompress kernel inside download directory 
DeCompressFiles $LINUXKERNEL_DOWNLOADDIR  $KERNEL_NAME

# decompress busybox inside download directory
DeCompressFiles $BUSYBOX_DOWNLOADDIR $BUSYBOX_NAME
#-------------------------------------------------------------

# compile kernel 
DoCompile $KERNEL_NAME $LINUXKERNEL_DOWNLOADDIR 

# compile busybox 
DoCompile $BUSYBOX_NAME $BUSYBOX_DOWNLOADDIR 
#-------------------------------------------------------------

# prepare linux kernel as bzImage and busybox as initrd.img and put them inside ./Build directory
PrepareBuildDir

# switch to build directory
cd $BUILDDIR

# [Last step :) ] -> deploy kernel and init on virtual machine
DeployOnTheMachine
