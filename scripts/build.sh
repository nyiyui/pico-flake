#!/usr/bin/env bash

set -eux

mkdir -p build
cd build
cmake -GNinja ..
ninja
