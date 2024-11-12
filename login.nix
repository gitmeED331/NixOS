{
  config,
  lib,
  pkgs,
  ...
}:
let
  greetConf = pkgs.writeText "greetd-sway-config" '' 
	exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; swaymsg exit"
	bindsym Mod4+shift+e exec swaynag\
	-t warning \
	-m "What do you want to do?" \
	-b 'Power Off' 'systemctl poweroff' \
	-b 'Reboot' 'systemctl reboot'
  '';
in
 {
  
  
  services = {
    greetd = {
      enable = true;
      settings = rec {
       # initial_session = {
      	#	command = "river";
      	#	user = "topsykrets";
#     	};
	default_session = {
		command = "${pkgs.sway}/bin/sway -c ${greetConf}";
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
	Hyprland
	river
	bash
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
