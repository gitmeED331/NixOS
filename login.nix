{
  config,
  lib,
  pkgs,
  ...
}:
let
  hyprlandConf = pkgs.writeText "greetd-hyprland-config" '' exec-once = "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; hyprctl dispatch exit"  '';

  River = '' exec "/home/topsykrets/.config/river/startup.sh" '';
in
 {
  
  
  services = {
    greetd = {
      enable = true;
      settings = {
      #  initial_session = {
      #		command = "Hyprland";
      #		user = "topsykrets";
      #	};
	      default_session = {
		      command = "Hyprland -c ${hyprlandConf}";
        };
      };
    };
    # logind
    logind.extraConfig = ''
      HandlePowerKey=ignore
      HandleLidSwitch=suspend
      HandleLidSwitchExternalPower=ignore
    '';

    gnome = {
      gnome-keyring.enable = true;
    };
    hypridle.enable = true;
  };
  security = {
    polkit.enable = true;
    rtkit.enable = true;
    pam.services.hyprlock = {};
    pam.services.hyprlock.fprintAuth = false;
  };
  

  environment.etc."greetd/environments".text = ''
    deepin
    bash
    Hyprland
    River
  '';

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

}