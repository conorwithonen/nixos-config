# /run/current-system/sw/bin/bash

cp -p configuration.nix /etc/nixos/configuration.nix

nixos-rebuild switch
