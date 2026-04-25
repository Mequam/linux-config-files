#!/bin/bash

git submodule update --init --recursive

# apply patches to the repo
./custom/patch.sh
