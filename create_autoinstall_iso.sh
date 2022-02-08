#!/usr/bin/env bash

set -e
set -x

############################################################################
############################################################################

_PROJECT_NAME="my-project"
# _ISO_DOWNLOAD_URL="http://releases.ubuntu.com/focal/ubuntu-20.04.3-live-server-amd64.iso"
# _ISO_CHECKSUM_URL="http://releases.ubuntu.com/focal/SHA256SUMS"
_ISO_DOWNLOAD_URL="https://cdimage.ubuntu.com/ubuntu-server/focal/daily-live/current/focal-live-server-amd64.iso"
_ISO_CHECKSUM_URL="https://cdimage.ubuntu.com/ubuntu-server/focal/daily-live/current/SHA256SUMS"

_SED="sed"

_TMPDIR="tmp"
_ISO_OUTPUT_DIR="output"

############################################################################
############################################################################

_BASEDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
_ISO_FILE="$(basename ${_ISO_DOWNLOAD_URL})"
_OUTPUT_ISO_FILE="${_PROJECT_NAME}_${_ISO_FILE%.*}_autoinstall.iso"
_WORKDIR="${_BASEDIR}/${_TMPDIR}"
_OUTPUTDIR="${_BASEDIR}/${_ISO_OUTPUT_DIR}"
_ISO_EXTRACT_DIR="${_WORKDIR}/iso"
_CLOUD_INIT_CONFIG_DIR="${_BASEDIR}/cloud-init"

# Delete previously extracted iso directory and output iso file
rm -rf "${_ISO_EXTRACT_DIR}" "${_OUTPUTDIR}/${_OUTPUT_ISO_FILE}"

# Create ISO distribution directory
mkdir -p "${_ISO_EXTRACT_DIR}/nocloud/" "${_OUTPUTDIR}"
cd "${_WORKDIR}"

# Download ISO installer if does not exist
if [ ! -f "${_WORKDIR}/${_ISO_FILE}" ]; then
  curl -fsSL --retry 3 -o "${_WORKDIR}/${_ISO_FILE}" "${_ISO_DOWNLOAD_URL}"
  curl -fsSL --retry 3 -o "${_WORKDIR}/SHA256SUMS" "${_ISO_CHECKSUM_URL}"
  sha256sum --check --ignore-missing SHA256SUMS
fi

# Extract ISO using 7z
# 7z x "$ISO_FILE" -x'![BOOT]' -o${_ISO_EXTRACT_DIR}
# Or extract ISO using xorriso and fix permissions
xorriso \
  -osirrox on \
  -indev "${_WORKDIR}/${_ISO_FILE}" \
  -extract / "${_ISO_EXTRACT_DIR}" && \
  chmod -R +w "${_ISO_EXTRACT_DIR}"

# Copy meta-data and user-data file
cp -r ${_CLOUD_INIT_CONFIG_DIR}/* "${_ISO_EXTRACT_DIR}/nocloud/"

# Update boot flags with cloud-init autoinstall
$_SED -i 's|---|autoinstall ds=nocloud\\\;s=/cdrom/nocloud/ ---|g' "${_ISO_EXTRACT_DIR}/boot/grub/grub.cfg"
$_SED -i 's|---|autoinstall ds=nocloud;s=/cdrom/nocloud/ ---|g' "${_ISO_EXTRACT_DIR}/isolinux/txt.cfg"

# Disable mandatory md5 checksum on boot
md5sum "${_ISO_EXTRACT_DIR}/.disk/info" > "${_ISO_EXTRACT_DIR}/md5sum.txt"
$_SED -i 's|'${_ISO_EXTRACT_DIR}'/|./|g' "${_ISO_EXTRACT_DIR}/md5sum.txt"

# Create Install ISO from extracted dir (Ubuntu):
xorriso -as mkisofs -r \
  -V Ubuntu\ custom\ amd64 \
  -o "${_OUTPUTDIR}/${_OUTPUT_ISO_FILE}" \
  -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -isohybrid-gpt-basdat -isohybrid-apm-hfsplus \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  ${_ISO_EXTRACT_DIR}/boot ${_ISO_EXTRACT_DIR}
# iso/boot iso
