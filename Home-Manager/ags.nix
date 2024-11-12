{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    bun
    dart-sass
    light
    swww
    grim
    slurp
    wf-recorder
    wl-clipboard
    swappy
    hyprpicker
    pavucontrol
    networkmanager
    gtk3
    gtk4
    gtk-session-lock
  ];
  
  programs.ags = {
    enable = true;
    configDir = ../ags;

    # additional packages to add to gjs's runtime
    extraPackages = with inputs.ags.packages.${pkgs.system}; [
      battery
      powerprofiles
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
}