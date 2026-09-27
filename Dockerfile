# syntax=docker/dockerfile:1
FROM qemux/qemu:latest

ENV BOOT="https://iso.omarchy.org/omarchy-4.0.4.iso"
ENV RAM_SIZE="8G"
ENV CPU_CORES="4"
ENV DISK_SIZE="128G"
ENV BOOT_MODE="uefi"
ENV TPM="N"

VOLUME ["/storage"]
EXPOSE 8006
