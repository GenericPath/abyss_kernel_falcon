#!/bin/bash
#
# abyss kernel falcon build script
#
clear

# Resources
THREAD="-j4"
KERNEL="zImage"
DTBIMAGE="dtb"
DEFCONFIG="titan_defconfig"
DEVICE="titan"

# Kernel Details
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=${HOME}/toolchains/arm-cortex_a7-linux-android-4.x-kernel-linaro/bin/arm-cortex_a7-linux-gnueabihf-

# Paths
KERNEL_DIR="${HOME}/kernel/falcon"
ANYKERNEL_DIR="${HOME}/kernel/anykernel"
ZIP_MOVE_STABLE="${HOME}/kernel/out/$DEVICE/stable"
ZIP_MOVE_NIGHTLY="${HOME}/kernel/out/$DEVICE/nightly"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot"
KERNEL_VER=$( grep -r "EXTRAVERSION = -Abyss-" ${KERNEL_DIR}/Makefile | sed 's/EXTRAVERSION = -Abyss-//' )

# Functions
function clean_all {
		cd $ANYKERNEL_DIR
		git checkout falcon
		rm -rf $KERNEL
		rm -rf $DTBIMAGE
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make CONFIG_DEBUG_SECTION_MISMATCH=y $THREAD
		cd $ANYKERNEL_DIR
		git checkout falcon
		cd $KERNEL_DIR
}

function make_dtb {
		$ANYKERNEL_DIR/tools/dtbToolCM -2 -o $ANYKERNEL_DIR/$DTBIMAGE -s 2048 -p scripts/dtc/ arch/arm/boot/
}

function make_zip {
		cp -vr $ZIMAGE_DIR/$KERNEL $ANYKERNEL_DIR
		cd $ANYKERNEL_DIR
		zip -r9 abyss-kernel-$DEVICE-$KERNEL_VER.zip *
		mv abyss-kernel-$DEVICE-$KERNEL_VER.zip $ZIP_MOVE_NIGHTLY
		cd $KERNEL_DIR
}

echo "    ___    __                                            ";
echo "   /   |  / /_  __  ____________                         ";
echo "  / /| | / __ \/ / / / ___/ ___/                         ";
echo " / ___ |/ /_/ / /_/ (__  |__  )                          ";
echo "/_/  |_/_.___/\__, /____/____/_ __                     __";
echo "             /____/         / //_/__  _________  ___  / /";
echo "                           / ,< / _ \/ ___/ __ \/ _ \/ / ";
echo "                          / /| /  __/ /  / / / /  __/ /  ";
echo "                         /_/ |_\___/_/  /_/ /_/\___/_/   ";
echo "                                                         ";

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		DATE_START=$(date +"%s")
		make_kernel
		if [ -f $ZIMAGE_DIR/$KERNEL ];
		then
			make_dtb
			make_zip
		else
			echo
			echo "Kernel build failed."
			echo
		fi
		break
		;;
	n|N )
		DATE_START=$(date +"%s")
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
