#!/bin/bash -e
#Modify by sandylaw <waytoarcher@gmail.com> 2020-11-04
#用于开发板镜像的解包、挂载

TARGET_ROOTFS_DIR=./binary
MOUNTPOINT=./rootfs
OUTPUT=./output
ROOTFSIMAGE=rootfs.img
ROOTFSIMAGE_SIZE=4000
# shellcheck disable=SC1091
source chrootsh
pause() {
    read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
}

finish() {
    sudo umount "${MOUNTPOINT}" || true
    echo -e "\e[31m MAKE ROOTFS FAILED.\e[0m"
    exit 1
}
unpack_image() {
    IMAGE="$(zenity --title "Please select the image file." --file-selection)" 2> /dev/null
    if [ ! -f "${IMAGE}" ]; then
        echo "Error:No found image file!"
        exit 1
    fi
    if [ -d "$OUTPUT" ]; then
        sudo rm -rf "$OUTPUT"
    fi

    mkdir -p "$OUTPUT" || exit

    echo "start to unpack ${IMAGE}..."
    ./rkImageMaker -unpack "${IMAGE}" "$OUTPUT" || pause
    ./afptool -unpack "$OUTPUT"/firmware.img "$OUTPUT" || pause

}
mount_rootfs_image() {

    echo Unpack rootfs image

    if [ -e "${TARGET_ROOTFS_DIR}" ]; then
        sudo rm -rf "${TARGET_ROOTFS_DIR}"
    fi
    # Create directories
    mkdir -p "${TARGET_ROOTFS_DIR}"

    if [[ -e "$OUTPUT"/Image/rootfs.img ]]; then
        sudo mount "$OUTPUT"/Image/rootfs.img "${TARGET_ROOTFS_DIR}" || pause
    else
        echo "Error: no rootfs.img"
        exit 1
    fi

}

mount_new_rootfs() {
    echo "umount ${MOUNTPOINT}"
    sudo umount "${MOUNTPOINT}" || true

    if [ -e "${MOUNTPOINT}" ]; then
        sudo rm -rf "${MOUNTPOINT}"
    fi
    if [ -e "${ROOTFSIMAGE}" ]; then
        sudo rm -f "${ROOTFSIMAGE}"
    fi

    mkdir -p "${MOUNTPOINT}" || exit 1
    echo "Creat target rootfsimage file"
    dd if=/dev/zero of="${ROOTFSIMAGE}" bs=1M count=0 seek="$ROOTFSIMAGE_SIZE"

    echo Format rootfs to ext4
    mkfs.ext4 "${ROOTFSIMAGE}"

    echo Mount rootfs to "${MOUNTPOINT}"
    sudo mount "${ROOTFSIMAGE}" "${MOUNTPOINT}"
    trap finish ERR

    echo Copy rootfs to "${MOUNTPOINT}"
    sudo cp -rfp ${TARGET_ROOTFS_DIR}/* "${MOUNTPOINT}"
    sudo umount "${TARGET_ROOTFS_DIR}"
    echo "Info: ${MOUNTPOINT} is ready"

}
chroot_modify() {
    prechroot ${MOUNTPOINT} || true
    echo "Do something at here..."
    chroot_do ${MOUNTPOINT} apt-get -y --allow-unauthenticated --allow-downgrades update || true
    postchroot ${MOUNTPOINT} || true
}
make_new_rootfs() {
    echo Umount rootfs
    sudo umount ${MOUNTPOINT} || true

    if ! [[ -e "${ROOTFSIMAGE}" ]]; then
        echo "${ROOTFSIMAGE}" does not exist.
        exit 1
    fi

    echo Rootfs Image: "${ROOTFSIMAGE}"

    e2fsck -p -f "${ROOTFSIMAGE}"
    resize2fs -M "${ROOTFSIMAGE}"
    cp "${ROOTFSIMAGE}" "$OUTPUT"/Image/rootfs.img
    echo "Info: $OUTPUT/Image/rootfs.img is OK."
}
make_new_image() {
    cat "$OUTPUT"/package-file
    echo "Please Prepare these files."
    read -rp "Are you ready? yes or no: " ready
    case $ready in
        yes | y | Y | YES)

            if [[ -e "$OUTPUT"/Image/rootfs.img ]]; then
                echo "Info: make new fireware.img"
                ./afptool -pack "$OUTPUT"/ "$OUTPUT"/firmware.img || pause
            fi
            if [[ -e "$OUTPUT"/firmware.img ]]; then
                echo "Info: make update.img"
                ./rkImageMaker -RK330C "$OUTPUT"/MiniLoaderAll.bin "$OUTPUT"/firmware.img update.img -os_type:androidos || pause
                echo "Info: New update image is OK"
            fi
            ;;
        *) ;;

    esac
}
while true; do
    echo "
This script will unpack development board image 、rootfs and make new rootfs file.
本脚本用于解压开发板镜像，并可以解压rootfs、生成新的rootfs。
生成新的update.img需要手动准备好各个文件。尚未开发自动检测功能。
主要功能取材于SDK，稍作修改、整合。
1. unpack image
2. mount rootfs image
3. mount new rootfs image
4. chroot rootfs and do something
5. make new rootfs image
6. make update image
7. exit
Please input num:

"
    read -r ipx
    case $ipx in
        1)
            unpack_image
            ;;
        2)
            mount_rootfs_image
            ;;
        3)
            mount_new_rootfs
            ;;
        4)
            chroot_modify
            ;;
        5)
            make_new_rootfs
            ;;
        6)
            make_new_image
            ;;
        7)
            exit
            ;;
        *)
            echo "None"
            ;;

    esac
done
