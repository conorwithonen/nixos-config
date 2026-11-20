{ inputs, pkgs, ... }:
{
  users.users.${currentSystemUsername} = {
    home = "/Users/${currentSystemUsername}";
    shell = pkgs.zsh;
  };
  # Required for some settings like homebrew to know what user to apply to.
  system.primaryUser = currentSystemUsername;

  # Apps every Mac gets. Machine-specific apps are in machines/*.nix.
  homebrew = {
    enable = true;
    casks  = [];
    brews = [];
  };


}
