#!/bin/sh
set -e
cd $(dirname $(realpath $0))

echo cd $(dirname $(realpath $0))

echo git submodule update --init --recursive

for file in .*; do
	[ "$file" = "." -o "$file" = ".." ] && continue
	[ "$file" = ".git" -o "$file" = ".gitignore" -o "$file" = ".gitmodules" ] && continue
	[ -e "$HOME"/"$file" ] && echo \# "$HOME"/"$file" already exists && continue
	echo ln -s "$(realpath "$file")" "$HOME"/"$(basename "$file")"
done

echo "dconf load /org/gnome/settings-daemon/plugins/media-keys/ < gnome-keybindings.dconf"
echo "dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal.dconf"

echo ln -s "$(realpath prezto)" "$HOME"/.zprezto
