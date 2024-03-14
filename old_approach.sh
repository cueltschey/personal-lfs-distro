echo "Downloading debian.iso"
echo
echo
# curl -O https://gemmei.ftp.acc.umu.se/debian-cd/current/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso
echo
echo
echo "Creating lfs.img"
qemu-img create -f qcow2 lfs.img 20G

echo
echo
echo "Intalling debian on lfs.img"
qemu-system-x86_64 -m 20G -boot d -enable-kvm -cdrom debian-12.5.0-amd64-netinst.iso -hda lfs.img
