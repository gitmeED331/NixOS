{
  config,
  pkgs,
  inputs,
  ...
}: {

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
    warn-dirty = false;
  };

  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };
    
    kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
  
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
 home = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      QT_XCB_GL_INTEGRATION = "none"; # kde-connect
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
      BAT_THEME = "base16";
      GOPATH = "${config.home.homeDirectory}/.local/share/go";
      GOMODCACHE = "${config.home.homeDirectory}/.cache/go/pkg/mod";
    };

    sessionPath = [
      "$HOME/.local/bin"
    ];
  };

  xresources.properties = {
    "Xcursor.size" = 16;
    #"Xft.dpi" = 172;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Liberation Mono";
      size = 10;
    };
    
    gtk3.bookmarks = let
      home = config.home.homeDirectory;
      in [
        "file://${home}/Documents"
        "file://${home}/Music"
        "file://${home}/Pictures"
        "file://${home}/Videos"
        "file://${home}/Downloads"
        "file://${home}/Desktop"
        "file://${home}/Work"
        "file://${home}/Projects"
        "file://${home}/Vault"
        "file://${home}/School"
        "file://${home}/.config Config"
      ];
  };

  programs.home-manager.enable = true;
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

#  home.packages = with pkgs; [
#    # theming
#    linearicons-free
#    icon-library
#    line-awesome
#    arc-icon-theme
#    
#    # apps
#    enpass
#    keepassxc
#
#    # archive
#    zip
#    xz
#    unzip
#    p7zip
#
#    # web browser
#    vivaldi
#    vivaldi-ffmpeg-codecs
#
#    # coding
#    vscode
#    lsd
#    gawk
#    terminator
#
#    # comms
#    vesktop
#    signal-desktop
#    threema-desktop
#    zoom-us
#
#    # utils
#    git
#    wget
#    htop
#    udiskie
#    xdg-desktop-portal-hyprland
#    light
#    xdg-utils
#    rofi
#    wl-clipboard
#    hyprpicker
#    swww
#    slurp
#    grim
#    grimblast
#    wf-recorder
#    cliphist
#    kdePackages.kdeconnect-kde
#
#    # drivers
#    hplipWithPlugin
#    openrazer-daemon
#
#    # office
#    libreoffice-fresh
#    # cryptomator.override {version = 1.14.0;}
#    pcloud
#    pcmanfm
#    thunderbird
#    imagemagick
#    pdfstudio2023
#    softmaker-office
#    synology-drive-client
#
#    # security
#    hyprlock
#    protonvpn-gui
#    seahorse
#  ];

 # programs.ags = {
 #   enable = true;
 #   # configDir = ../ags;
#
 #   # additional packages to add to gjs's runtime
 #   extraPackages = with inputs.ags.packages.${pkgs.system}; [
 #     battery
 #     powerprofiles
 #     io
 #     notifd
 #     wireplumber
 #     hyprland
 #     river
 #     apps
 #     bluetooth
 #     network
 #     mpris
 #     tray
 #     cava
 #     auth
 #     greet
 #     pkgs.fzf
 #   ];
 # };
}