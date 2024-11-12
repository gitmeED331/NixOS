{ config, lib, pkgs, ... }:

{

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
    supportedFilesystems = ["ntfs"];
    loader = {
      timeout = 2;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

 programs = {
    direnv.enable = true;
    dconf.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # mtr.enable = true;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking = {
    useDHCP = lib.mkDefault true;
    # interfaces = {
      # enp1s0.useDHCP = lib.mkDefault true;
      # wlp2s0.useDHCP = lib.mkDefault true;
    # };
  };

  # nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  hardware = {    
    bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings.General.Experimental = true; # for gnome-bluetooth percentage
    };

    sane ={
      enable = true;
      extraBackends = [ pkgs.hplipWithPlugin ];
    };
  };

  networking ={
    hostName = "Dragon"; # Define your hostname.
    networkmanager.enable = true; # Enable networking
    #  wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    
    firewall = rec {
      enable = true;
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };
    
    
  # Configure network proxy if necessary
  # proxy = {
      # default = "http://user:password@proxy:port/";
      # noProxy = "127.0.0.1,localhost,internal.domain";
  # };
  };

 environment = {
    sessionVariables = {
        XDG_SESSION_TYPE = "wayland";
        NIXOS_OZONE_WL = "1";
        
        TERM = "terminator";

        QT_QPA_PLATFORM = "wayland";
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland";
        OZONE_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";

        KDE_SESSION_VERSION = 6;
        MOZ_ENABLE_WAYLAND = 1;
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
                
        QT_QPA_PLATFORMTHEME = "qt6ct";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;

        # Scale
        QT_AUTO_SCREEN_SCALE_FACTOR = 1;
        GDK_SCALE = 1;

        _JAVA_AWT_WM_NONEREPARENTING = 1;
    };
    systemPackages = with pkgs; [
      git
      wget
      curl
      bluez
      blueman
      gvfs
      ntfs3g
      gdk-pixbuf
      avahi
      swayosd
      polkit_gnome
      greetd.greetd
      greetd.gtkgreet
    ];
  };

xdg.portal.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
    };

    # openssh.enable = true;
    printing.enable = true;
    flatpak.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    blueman.enable = true;
    thermald.enable = true;
    libinput.enable = true;
    xserver.enable = true;
  
  };

  programs = {
    auto-cpufreq = {
      enable = true;
      settings = {
        charger = {
          governor = "performance";
          turbo = "auto";
        };
        battery = {
          governor = "powersave";
          turbo = "auto";
        };
      };
    };
    
    
    light.enable = true;
  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = {
    stateVersion = "24.05"; # Did you read the comment?
    # autoUpgrade.enable = true;
    # autoUpgrade.allowReboot = true;
  };
}
