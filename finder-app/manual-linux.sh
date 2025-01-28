#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.
# The script is based on instructions provided in the assignment 3 part 2.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # Adding kernel build steps
    # Make sure the following apps are installed: make build-essential libncurses-dev bison flex libssl-dev libelf-dev qemu 
    # Deep clean the kernel source
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    # Configure the default configuration
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    # Building the kernel image
    make -j16 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
    # Building the kernel modules
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    # Building the device tree blobs
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
fi

echo "Adding the Image in outdir"
cp -a ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# Creating necessary base directories
mkdir -p ${OUTDIR}/rootfs/{bin,dev,etc,home,lib,lib64,proc,sbin,sys,tmp,var/log,usr/{bin,sbin}}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # Configuring busybox
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
else
    cd busybox
fi

# Making and installing busybox
make -j16 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make -j16 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} CONFIG_PREFIX=${OUTDIR}/rootfs install

# Checking the library dependencies
cd ${OUTDIR}/rootfs
echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# Adding library dependencies to rootfs
SYSROOT=$(${CROSS_COMPILE}gcc -print-sysroot)
cp -L $SYSROOT/lib/ld-linux-aarch64.so.1 lib
cp -L $SYSROOT/lib64/libm.so.6 lib64
cp -L $SYSROOT/lib64/libresolv.so.2 lib64
cp -L $SYSROOT/lib64/libc.so.6 lib64

# Making device nodes for console and null
cd ${OUTDIR}/rootfs
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1

# Cleaning and building the writer utility
cd "$FINDER_APP_DIR"
make clean
make CROSS_COMPILE=${CROSS_COMPILE}

# Copying the finder related scripts and executables to the /home directory
# on the target rootfs
cp ./writer.sh ${OUTDIR}/rootfs/home
cp ./autorun-qemu.sh ${OUTDIR}/rootfs/home
cp ./finder.sh ${OUTDIR}/rootfs/home
cp ./finder-test.sh ${OUTDIR}/rootfs/home
cp ./Makefile ${OUTDIR}/rootfs/home
cp ./writer.c ${OUTDIR}/rootfs/home
cp -L -r ./conf ${OUTDIR}/rootfs/home
cp ./writer ${OUTDIR}/rootfs/home
# Copying the start-qemu scripts to the output directory
# Make sure you have installed qemu-system-aarch64, qemu
cp ./start-qemu-app.sh ${OUTDIR}
cp ./start-qemu-terminal.sh ${OUTDIR}


# Chown-ing the root directory
cd ${OUTDIR}/rootfs
sudo chown -R root:root *

# Creating initramfs.cpio.gz
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd ..
gzip -f initramfs.cpio
