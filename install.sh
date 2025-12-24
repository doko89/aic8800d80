#!/bin/bash
set -e

KERNEL_VER=$(uname -r)
KERNEL_BUILD_DIR="/lib/modules/${KERNEL_VER}/build"

# Cek kernel headers
if [ ! -d "$KERNEL_BUILD_DIR" ]; then
    echo "Linux headers untuk kernel ${KERNEL_VER} TIDAK ditemukan."

    # Ambil nama paket kernel (contoh: linux66, linux61, dll)
    KERNEL_PKG=$(mhwd-kernel -li | awk '/\*/ {print $2}')

    if [ -z "$KERNEL_PKG" ]; then
        echo "ERROR: Tidak dapat mendeteksi kernel aktif."
        exit 1
    fi

    HEADER_PKG="${KERNEL_PKG}-headers"

    echo "Menginstall ${HEADER_PKG} ..."
    sudo pacman -Syu --needed "$HEADER_PKG"

    # Validasi ulang
    if [ ! -d "$KERNEL_BUILD_DIR" ]; then
        echo "ERROR: Kernel headers gagal terpasang."
        exit 1
    fi
fi

echo "Linux headers ditemukan. Melanjutkan build driver."

cd drivers/aic8800

make -C "$KERNEL_BUILD_DIR" M="$(pwd)"
sudo make install
sudo modprobe aic8800_fdrv

echo "Driver aic8800_fdrv berhasil dibuild dan dimuat."
