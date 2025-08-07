#!/usr/bin/env bash

mkdir -p build
(cd build && cmake -G Ninja ..)
cp build/compile_commands.json .
