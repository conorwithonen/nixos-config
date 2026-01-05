{
  pkgs,
  ...
}:
{
  imports = [
    ./users/conor
  ];
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # ============================================================================
  # SECURITY
  # ============================================================================

  security.sudo.wheelNeedsPassword = false;

  # ============================================================================
  # NETWORKING
  # ============================================================================

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];  # SSH

  # ============================================================================
  # SERVICES
  # ============================================================================

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };
  # ============================================================================
  # TIMEZONES AND LOCALES
  # ============================================================================
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ============================================================================
  # PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    git
    vim
    neovim
    jq
    python3
    pkgs.awscli2
  ];
}
