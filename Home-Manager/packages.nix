{
  pkgs,
  ...
}: {
  
   # List packages installed in system profile. To search, run:
  # $ nix search wget
home.packages = with pkgs; [
    # environments
    hyprland
    river

    # theming
    linearicons-free
    icon-library
    line-awesome
    arc-icon-theme
    morewaita-icon-theme
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
    kitty

    # comms
    vesktop
    signal-desktop
    threema-desktop
    zoom-us

    # utils
    htop
    udiskie
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
    kdePackages.kdeconnect-kde
    pavucontrol
    bat

    # drivers
    hplipWithPlugin
    openrazer-daemon

    # office
    libreoffice-fresh
    # cryptomator.override {version = 1.14.0;}
    pcloud
    pcmanfm
    thunderbird
    imagemagick
    pdfstudio2023
    softmaker-office
    synology-drive-client

    # security
    hyprlock
    protonvpn-gui
    seahorse
    
  ];



}
