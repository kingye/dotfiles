#!/bin/bash
# This script is used to synchronize files between a local directory and a remote server using rsync.
rsync -azP --delete --exclude-from='.gitignore' ./ 10.239.116.32:projects/c21-networkcalculation-srv
