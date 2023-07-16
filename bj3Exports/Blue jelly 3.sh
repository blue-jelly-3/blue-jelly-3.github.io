#!/bin/sh
echo -ne '\033c\033]0;Blue jelly 3\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Blue jelly 3.x86_64" "$@"
