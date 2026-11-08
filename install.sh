#!/bin/sh
set -eu
umask 077

if [ -z "${HOME:-}" ]; then
    printf '%s\n' 'install.sh: HOME is not set' >&2
    exit 1
fi

: "${XDG_CONFIG_HOME:=$HOME/.config}"
repo_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
bin_dir=$HOME/.local/bin
config_dir=$XDG_CONFIG_HOME/canta-pm

mkdir -p "$bin_dir" "$config_dir"
cp "$repo_dir/bin/canta-pm" "$bin_dir/canta-pm"
chmod 755 "$bin_dir/canta-pm"

if [ -e "$config_dir/packages.tsv" ]; then
    printf '%s\n' "Preserved existing manifest: $config_dir/packages.tsv"
else
    cp "$repo_dir/config/packages.tsv" "$config_dir/packages.tsv"
    chmod 600 "$config_dir/packages.tsv"
    printf '%s\n' "Installed manifest: $config_dir/packages.tsv"
fi

printf '%s\n' "Installed executable: $bin_dir/canta-pm"
