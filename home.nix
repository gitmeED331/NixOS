{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = true;
    systemd.variables = ["--all"];
  };

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  xresources.properties = {
    "Xcursor.size" = 16;
    #"Xft.dpi" = 172;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
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
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Liberation Mono";
      size = 10;
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    # theming
    adwaita-icon-theme

    # apps
    enpass
    keepassxc

    # archive
    zip
    xz
    unzip
    p7zip

    # web browser
    vivaldi
    vivaldi-ffmpeg-codecs

    # coding
    vscode
    lsd
    gawk
    terminator

    # comms
    vesktop
    signal-desktop
    threema-desktop
    zoom-us

    # utils
    git
    wget
    htop
    #udiskie
    xdg-desktop-portal-hyprland
    light
    xdg-utils
    rofi
    wl-clipboard
    hyprpicker
    swww
    slurp
    grim
    grimblast
    wf-recorder
    cliphist

    # drivers
    hplipWithPlugin
    openrazer-daemon

    # office
    libreoffice-fresh
    cryptomator
    pcloud
    nautilus
    lxqt.pcmanfm

    # security
    hyprlock
    protonvpn-gui
    greetd.regreet
    greetd.greetd
    seahorse
    polkit_gnome
  ];

  programs.git = {
    enable = true;
    userName = "topsykrets";
    userEmail = "topsykrets@proton.me";
  };

  # add the home manager module
  programs.ags = {
    enable = true;
    # configDir = ../ags;

    # additional packages to add to gjs's runtime
    extraPackages = with inputs.ags.packages.${pkgs.system}; 
      [
          battery
          io
          notifd
          wireplumber
          hyprland
          river
          apps
          bluetooth
          network
          mpris
          tray
          cava
          auth
          greet
          pkgs.fzf
      ];
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}
