{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;

    # Plugins come from nixpkgs and are placed on the packpath automatically
    plugins = with pkgs.vimPlugins; [
      kanagawa-nvim
      (nvim-treesitter.withPlugins (p: [
        p.nix
        p.lua
        p.hcl
        p.terraform
        p.yaml
        p.json
        p.bash
        p.markdown
      ]))
      telescope-nvim
      plenary-nvim
    ];

    # Available on nvim's PATH only (not globally)
    extraPackages = with pkgs; [
      ripgrep
      fd
      nil                    # nix LSP
      terraform-ls
      lua-language-server
    ];
    extraLuaConfig = builtins.readFile ./init.lua;
  };

  # Live-editable symlink: Lua changes apply without a rebuild.
  # Adjust the path to wherever the repo is checked out.
  xdg.configFile."nvim/lua".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/nixos-config/hosts/users/conor/nvim/lua";
}
