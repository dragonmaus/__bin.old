#!/bin/sh

cd "$(xdg-user-dir BACKGROUNDS)"

current=$(readlink .current)

random=$current
while [[ "$random" = "$current" ]]
do
  random=$(find -L .current-res -type f 2> /dev/null | sort -R | head -1)
done

ln -fns "$random" .current

[[ "$1" = -s ]] && exec set-wallpaper .current
