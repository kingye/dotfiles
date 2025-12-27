#!/bin/bash
# script to find and close ghost windows

ghost_window_ids=$(aerospace list-windows --all | grep -e '.*|.*| $' | awk '{print $1}')

for id in $ghost_window_ids ; do
    aerospace close --window-id $id
done
