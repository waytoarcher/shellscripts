#!/usr/bin/bash
#virt-manager
#v1.0 by sandylaw <waytoarcher@gmail.com> 2020-08-21
#
function install_kvm_packages() {
    TUSER="$(whoami)"
    echo "Kvm installation"
    sudo apt install -y libvirt-dev virt-viewer uuid-runtime
    sudo apt install -y pkg-config genisoimage netcat
    sudo apt install -y kpartx qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager qemu-system-arm qemu-utils qemu-user-static
    sudo apt install -y qemu-efi qemu-efi-aarch64 qemu-efi-arm qemu python3-libvirt uml-utilities qemu-system gcc-arm-linux-gnueabihf libc6-dev-armhf-cross
    sudo apt install -y virt-top libguestfs-tools libosinfo-bin libvirt-daemon qemu-system-mips
    sudo usermod -aG libvirt "$TUSER"
    sudo usermod -aG kvm "$TUSER"
    sudo apt autoremove
}
function install_from_iso() {
    read -rp "Please input the arch(amd64 arm64): " ARCH
    read -rp "Please input the kvm name: " NAME
    read -rp "Please input the kvm size(GB) 20-256: " SIZE
    ISO="$(zenity --title "Please select the iso image file." --file-selection)" 2> /dev/null
    case $ARCH in
        amd64)
            ARCH=x86_64
            VIDEO=spice
            #UEFI=/usr/share/qemu-efi/QEMU_EFI.fd
            ;;
        arm64)
            ARCH=aarch64
            VIDEO=none
            #UEFI=/usr/share/qemu-efi-aarch64/QEMU_EFI.fd
            ;;
        *)
            echo "Please Check your input arch."
            exit 1
            ;;
    esac
    if [[ "$SIZE" -ge 20 ]] || [[ "$SIZE" -le 256  ]]; then
        :
    else
        echo "Please check the size num."
    fi
    if [ ! -f "$ISO" ]; then
        echo "Please check the iso path."
    fi
    TIMETAG=$(date +%F)
    VCPUS=$(($(grep -c processor < /proc/cpuinfo) / 3))
    MEMORY=$(($(grep MemAvailable < /proc/meminfo | awk '{print $2}') / 1024 / 3))

    qemu-img create -f qcow2 /home/"$USER"/Downloads/"$NAME"_"$ARCH"_"$TIMETAG".qcow2 "$SIZE"G
    virt-install -n "$NAME"_"$ARCH"_"$TIMETAG" --memory "$MEMORY" --arch "$ARCH" --vcpus "$VCPUS" \
        --disk /home/"$USER"/Downloads/"$NAME"_"$ARCH"_"$TIMETAG".qcow2,device=disk,bus=virtio \
        --os-type=linux \
        --os-variant debian10 \
        --graphics "$VIDEO" \
        --noreboot \
        --boot uefi \
        --cdrom "$ISO" \
        --connect qemu:///system \
        --network network:default \
        --check path_in_use=off
}

# -nographic
function install_mips_with_qemu() {
    read -rp "Please input the kvm name: " NAME
    read -rp "Please input the kvm size(GB) 20-256: " SIZE
    ISO="$(zenity --title "Please select thi iso image file." --file-selection)" 2> /dev/null

    if [[ "$SIZE" -ge 20 ]] || [[ "$SIZE" -le 256  ]]; then
        :
    else
        echo "Please check the size num."
    fi

    TIMETAG=$(date +%F)
    qemu-img create -f qcow2 /home/"$USER"/Downloads/"$NAME"_Mips_"$TIMETAG".qcow2 "$SIZE"G
    rm -f vmlinux* initrd*
    wget http://ftp.debian.org/debian/dists/stretch/main/installer-mips64el/current/images/malta/netboot/vmlinux-4.9.0-13-5kc-malta
    wget http://ftp.debian.org/debian/dists/stretch/main/installer-mips64el/current/images/malta/netboot/initrd.gz
    _kernel=$(basename vmlinux*)
    _initrd=$(basename initrd)
    sudo  qemu-system-mips64el -cpu 5KEf \
        -M  malta \
        -cdrom "$ISO" \
        -kernel "$_kernel" \
        -initrd "$_initrd".gz \
        -append "root=/dev/sda1 console=ttyS0 nokaslr" \
        -hda /home/"$USER"/Downloads/"$NAME"_Mips_"$TIMETAG".qcow2 \
        -nographic

}

function virsh_list() {
    virsh --connect qemu:///system list --all
}
function list_kvms() {
    read -ra KVMS <<< "$(virsh --connect qemu:///system list --all | sed -n "3,\$p" | awk '{print $2}' | tr "\n" " ")"

    kvm_sum=${#KVMS[*]}
    if [[ $kvm_sum -lt 1 ]]; then
        echo "This no kvm exist now."
        exit 0
    fi
    listnum=$(($(virsh --connect qemu:///system list --all | wc -l) - 1))
    virsh --connect qemu:///system list --all | sed -n "3,${listnum}p" | awk '{print $2}' | cat -n
}

function virsh_start() {
    list_kvms
    read -rp "Please input the kvm id:" kvmid

    if [[ "${kvmid}" -gt "${kvm_sum}" ]]; then
        echo "Please check the kvm id."
    fi
    virsh --connect qemu:///system start --domain "${KVMS[$kvmid - 1]}"
    read -rp "Viewer ${KVMS[$kvmid - 1]} Now? Y/N?" YN
    case $YN in
        yes | Yes | Y | y | YES | YEs | yES | yeS)
            virt-viewer --connect qemu:///system "${KVMS[$kvmid - 1]}"
            ;;
        *) ;;

    esac
}
function virsh_resume() {
    list_kvms
    read -rp "Please input the kvm id:" kvmid

    if [[ "${kvmid}" -gt "${kvm_sum}" ]]; then
        echo "Please check the kvm id."
    fi
    virsh --connect qemu:///system resume --domain "${KVMS[$kvmid - 1]}"
    read -rp "Viewer ${KVMS[$kvmid - 1]} Now? Y/N?" YN
    case $YN in
        yes | Yes | Y | y | YES | YEs | yES | yeS)
            virt-viewer --connect qemu:///system "${KVMS[$kvmid - 1]}"
            ;;
        *) ;;

    esac
}

function virsh_reboot() {
    list_kvms
    read -rp "Please input the kvm id:" kvmid

    if [[ "${kvmid}" -gt "${kvm_sum}" ]]; then
        echo "Please check the kvm id."
    fi
    virsh --connect qemu:///system reboot --domain "${KVMS[$kvmid - 1]}"
}
function virsh_shutdown() {
    list_kvms
    read -rp "Please input the kvm id:" kvmid

    if [[ "${kvmid}" -gt "${kvm_sum}" ]]; then
        echo "Please check the kvm id."
    fi
    virsh --connect qemu:///system shutdown --domain "${KVMS[$kvmid - 1]}"
}
function virsh_delete() {
    list_kvms
    read -rp "Please input the kvm id:" kvmid

    if [[ "${kvmid}" -gt "${kvm_sum}" ]]; then
        echo "Please check the kvm id."
    fi

    virsh --connect qemu:///system shutdown --domain "${KVMS[$kvmid - 1]}"

    virsh --connect qemu:///system destroy --domain "${KVMS[$kvmid - 1]}"
    virsh --connect qemu:///system undefine --domain "${KVMS[$kvmid - 1]}"
    virsh --connect qemu:///system undefine --nvram "${KVMS[$kvmid - 1]}"
    rm -rf /home/"$USER"/Downloads/"${KVMS[$kvmid - 1]}".qcow2
}
function virt_viewer() {

    virt-viewer --connect qemu:///system
}

echo "Install and manager kvm ,Please select:"
echo " 1: Install kvm "
echo " 2: List kvm "
echo " 3: Start kvm "
echo " 4: View kvm "
echo " 5: Reboot kvm "
echo " 6: Shutdown kvm "
echo " 7: Delete kvm "
echo " 8: Resume kvm "
echo " 9: Install kvm packages "
echo " 0: Install mips64el with qemu "
echo ""

read -r -p "Please input the choice:"  idx
if [[ "$idx" -ge 1 ]] || [[ "$idx" -le 6 ]]; then
    :
else
    echo "Please check the your choice."
fi
#  echo "no choice,exit"
if [[ '1' = "$idx" ]]; then
    eval "install_from_iso"
elif [[ '2' = "$idx" ]]; then
    eval "virsh_list"
elif [[ '3' = "$idx" ]]; then
    eval "virsh_start"
elif [[ '4' = "$idx" ]]; then
    eval "virt_viewer"
elif [[ '5' = "$idx" ]]; then
    eval "virsh_reboot"
elif [[ '6' = "$idx" ]]; then
    eval "virsh_shutdown"
elif [[ '7' = "$idx" ]]; then
    eval "virsh_delete"
elif [[ '8' = "$idx" ]]; then
    eval "virsh_resume"
elif [[ '9' = "$idx" ]]; then
    eval "install_kvm_packages"
elif  [[ '0' = "$idx" ]]; then
    eval "install_mips_with_qemu"
else
    echo "no choice,exit!"
fi
