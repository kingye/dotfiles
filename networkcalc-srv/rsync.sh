#!/bin/bash
# This script is used to synchronize files between a local directory and a remote server using rsync
rsync -azP --delete \
    --exclude='node_modules' \
    --exclude='gen' \
    --exclude='out' \
    --exclude=.git \
    ./ 10.239.116.147:projects/c21-networkcalculation-srv


