# Nix Flake Template for Raspberry Pi Pico Development

This repo contains a Nix flake template for making a Raspberry Pi Pico firmware image.

## Building and Flashing

To build:
```
nix build .
```

To flash:
1. Connect the Pico to your PC *while pressing the BOOTSEL button*. The Pico should show up as a USB mass storage / block device.
2. Mount the Pico to your filesystem.
3. Copy `result/main.uf2` to the Pico. The Pico should automatically reboot, and the mounted drive should automatically unmount.
