# Nix Flake Template for Raspberry Pi Pico Development

This repo contains a Nix flake template for making a Raspberry Pi Pico firmware image.

Run `./scripts/dev-env-setup.sh` to generate your [JSON Compilation Database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) aka `compile_commands.json` file. This file helps [clangd](https://clangd.llvm.org/) (and other tools) find the correct include and library paths.

## Building and Flashing

To build:
- `nix build .` to ensure you are building from a clean slate
- `./scripts/build.sh` for speed (due to caching)

To flash:
1. Connect the Pico to your PC *while pressing the BOOTSEL button*. The Pico should show up as a USB mass storage / block device.
2. Mount the Pico to your filesystem.
3. Copy `result/main.uf2` to the Pico. The Pico should automatically reboot, and the mounted drive should automatically unmount.

You can also run `./scripts/flash.sh` (make sure to edit the disk label names).
