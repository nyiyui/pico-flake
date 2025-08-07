#!/usr/bin/env bash

run_build=1
connect_timeout=10

while [[ $# -gt 0 ]]; do
  case $1 in
    --no-build)
      run_build=0
      shift
      ;;
    --connect-timeout)
      connect_timeout="$2"
      shift
      shift
      ;;
    *)
      echo "unknown argument $1"
      echo "Usage: $0 [--no-build]"
      echo "  --no-build - do not run ./build.sh before flashing"
      exit 1
      ;;
  esac
done

set -eu

if [[ $run_build -eq 1 ]]; then
  ./build.sh
fi

connect_start=$SECONDS
echo "--- trying to find Pico... (timeout=$connect_timeout)"
while true; do
  if [ -b /dev/disk/by-label/RP2350 ]; then
    echo "--- found."
    break
  fi
  if (( SECONDS - connect_start >= connect_timeout )); then
    echo "--- timed out while trying to find Pico."
    exit 1
  fi
done
udisksctl mount -b /dev/disk/by-label/RP2350
cp ./build/pwm.uf2 /run/media/$USER/RP2350
echo "--- done."
