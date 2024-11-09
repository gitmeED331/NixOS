# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
	<home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

	# gnome keyring
	services.gnome.gnome-keyring.enable = true;
	security.polkit.enable = true;

	security.pam.services.hyprlock = { };
	security.pam.services.hyprlock.fprintAuth = false;


  networking.hostName = "Dragon"; # Define your hostname.
#  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
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

 services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "hyprland";
	user = "topsykrets";
      };
default_session = initial_session;
    };
  };
 
  environment.etc."greetd/environments".text = ''
    deepin
    bash
    hyprland
    river
  '';

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.topsykrets = {
    isNormalUser = true;
    description = "";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

home-manager.users.topsykrets = { pkgs, ... }: {
  home.packages = [ pkgs.atool pkgs.httpie ];
  programs.bash.enable = true;

	imports = [
	  /home/topsykrets/.config/NixOS/home.nix
	];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";
};

  # install apps 
  # programs.firefox.enable = true;


programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;
    #hyprlock.enable = true;
    #portalPackage.enable = true;
    
  };
# services.hypridle.enable = true;
# programs.iio-hyprland.enable = true;
# environmentals
#  environment.sessionVariables.NIXOS_OZONE_WL = "1";


programs.river.enable = true;
#programs.river.extraPackages.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
	git
	wget
	curl
	hplipwithplugin
#	vivaldi
#	vivaldi-ffmpeg-codecs
#	vscode
#	terminator
#	vesktop
#	udiskie
#	signal-desktop
#	cryptomator
#	threema-desktop
#	zoom-us
#	libreoffice-fresh
#	pcloud
#	`protonvpn-gui
#	greetd.regreet
#	greetd.greetd	
#	xdg-desktop-portal-hyprland
#	hyprlock
#	light
#	xdg-utils
#	gnome.seahorse
#	rofi
#	wl-clipboard
#	hyprpicker
#	swww
#	slurp
#	grim
#	grimblast
#	wf-recorder
#	polkit_gnome
#	gnome.nautilus
#	cliphist
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

}