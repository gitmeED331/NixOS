{
  inputs,
  lib,
  ...
}: let
  username = "topsykrets";
in {
  imports = [
    ./hardware-configuration.nix
    ./system.nix
    ./audio.nix
    ./locality.nix
    ./nautilus.nix
    ./login.nix
  ];

  nixpkgs.config.allowUnfree = true;
  
  #programs = {
  #  hyprland.enable = true;
  #  river.enable = true;
  #  hyprlock.enable = true;
  #  starship.enable = true;
  #  gnome.enable = true;
  #  sddm.enable = true;
  #  sddm.theme = "Nordic";
  #  sddm.themeVariant = "dark";
   #};

# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = "";
    initialPassword = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "scanner"
      "lp"
    ];

  };

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    users.${username} = {
      home.username = username;
      home.homeDirectory = "/home/${username}";
      imports = [
        ./Home-Manager/ags.nix
        #./Home-Manager/dconf.nix
        ./Home-Manager/git.nix
        ./Home-Manager/hyprland.nix
        ./Home-Manager/river.nix
        ./Home-Manager/packages.nix
        #./Home-Manager/starship.nix
        #./Home-Manager/theme.nix
        ./home.nix
      ];
    };
  };

#  specialisation = {
#    gnome.configuration = {
#      system.nixos.tags = ["Gnome"];
#      hyprland.enable = lib.mkForce false;
#      gnome.enable = true;
#    };
#  };
  
}