{ config, lib, pkgs, currentSystemUsername, ... }: {
  home-manager.users.${currentSystemUsername}.programs.thunderbird.enable = false;
  imports = [
    ./darwin-shared.nix
  ];

  # Set in Sept 2024 as part of the macOS Sequoia release.
  system.stateVersion = 5;

  # This makes it work with the Determinate Nix installer
  ids.gids.nixbld = 30000;

  # Desktop apps. Shared apps are in users/conor/darwin.nix.
  homebrew = {
    brews = [];
    casks = [];
    taps = [];
  };
}
