{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  light = "${pkgs.light}/bin/light";

  inherit (lib) mkEnableOption mkIf mkMerge mapAttrsToList;
in {
  options.hyprland = {
    enable = lib.mkEnableOption "Hyprland";
  };

  config = lib.mkIf config.hyprland.enable {        
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ];
        config.common.default = "*";
      };

        home.packages = with pkgs; [
          wl-clipboard
          swww
          grim
          slurp
          playerctl
          kitty
        ];

        wayland.windowManager.hyprland = {
          enable = true;
          xwayland.enable = true;
          plugins = [];
          package = inputs.hyprland.packages.${pkgs.system}.hyprland;
          systemd = {
            enable = true;
            variables = ["--all"];
          };

          extraConfig = ''

              plugin {
                
              }
          '';
          settings = let
            pactl = "${pkgs.pulseaudio}/bin/pactl";
            # pamixer = "${pkgs.pamixer}/bin/pamixer";

            #stolen from fufexan

            screenarea = ''grim -g "$(slurp)" "$(xdg-user-dir PICTURES)/Pictures/Screen/Screenshot-area_$(date +%y-%m-%d_%H%M-%S).png"'';
            screenfull = ''grim "$(xdg-user-dir PICTURES)/Pictures/Screenshot-full_$(date +%y-%m-%d_%H%M-%S).png"'';

            recordarea = ''wf-recorder -g "$(slurp)" -x yuv420p -c libx264 -f "$(xdg-user-dir PICTURES)/Screenrecording-area_$(date +%y-%m-%d_%H%M-%S).mp4"'';
            recordfull = ''wf-recorder -x yuv420p -c libx264 -f "$(xdg-user-dir PICTURES)/Screenrecording-full_$(date +%y-%m-%d_%H%M-%S).mp4"'';
          in {
            env = mapAttrsToList (name: value: "${name},${toString value}") {
              XDG_CURRENT_DESKTOP = "Hyprland";
              XDG_SESSION_DESKTOP = "Hyprland";

              HYPRLAND_NO_SD_NOTIFY = 1;
              
              HYPRCURSOR_THEME = "HyprBibataModernClassic";
              HYPRCURSOR_SIZE = 16;

              XCURSOR_THEME = "Bibata_Modern_Classic";
              XCURSOR_SIZE = 16;
            };

            monitor = [
              "eDP-1,preferred,0x0, 1"
              ",preferred,auto, 1, mirror, eDP-1"
            ];

            exec-once = [
              # "${pkgs.foot}/bin/foot --server"
              "hypridle"
              "swww-daemon && swww restore"
              "udiskie --tray"
              "ags run"

              # "hyprlock"
              "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store"
              # "./scripts/dynamic-borders.sh"
              "sleep 10"
              "keepassxc"
              #"ente_auth"
              # "cryptomator"
              "signal-desktop --start-in-tray"
              "synology-drive"
              #"filen-desktop"
              "pcloud"
              "kdeconnect-indicator"

              "sleep 2"
              "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

            ];

            general = {
              gaps_in = 1;
              gaps_out = 2;
              border_size = 1;

              allow_tearing = true;

              layout = "dwindle";
              # "col.active_border" =  "rgba(33ccffee) rgba(00ff99ee) 45deg";
            };

            binds = {
              workspace_back_and_forth = true;
              allow_workspace_cycles = true;
            };
            xwayland = {
              force_zero_scaling = true;
            };

            decoration = {
              rounding = 1;
              drop_shadow = true;
              shadow_range = 5;
              shadow_render_power = 2;
              # "col.shadow" = "rgba(00000044)";
              # shadow_offset = "0 0";
              blur = {
                enabled = true;
                size = 5;
                passes = 4;
                ignore_opacity = true;
                # xray = true;
                new_optimizations = true;
                # noise = 0.03;
                # contrast = 1.0;
              };
            };

            dwindle = {
              pseudotile = 0;
              force_split = 2;
              preserve_split = 1;
              default_split_ratio = 1.3;
            };

            master = {
              new_on_top = false;
              no_gaps_when_only = false;
              orientation = "top";
              mfact = 0.6;
              always_center_master = false;
            };

            animation = {
              bezier = [
                "easeOutCirc, 0, 0.55, 0.45, 1"
                "easeOutCubic, 0.33, 1, 0.68, 1"
                "easeinoutsine, 0.37, 0, 0.63, 1"
                "linear, 0, 0, 1, 1"
                "md3_standard, 0.2, 0, 0, 1"
                "md3_decel, 0.05, 0.7, 0.1, 1"
                "md3_accel, 0.3, 0, 0.8, 0.15"
                "overshot, 0.05, 0.9, 0.1, 1.1"
                "crazyshot, 0.1, 1.5, 0.76, 0.92 "
                "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
                "fluent_decel, 0.1, 1, 0, 1"
                "easeInOutCirc, 0.85, 0, 0.15, 1"
                "easeOutCirc, 0, 0.55, 0.45, 1"
                "easeOutExpo, 0.16, 1, 0.3, 1"
                "softAcDecel, 0.26, 0.26, 0.15, 1"
              ];

              animation = [
                "windows, 1,7,hyprnostretch, slide"
                #STOLEN FROM :https://discord.com/channels/961691461554950145/1162860692978794627
              ];
            };

            input = {
              follow_mouse = 0;
              force_no_accel = 1;

              kb_layout = "us";
              kb_options = "grp:alt_shift_toggle, ctrl:nocaps";

              sensitivity = 0.5;

              touchpad = {
                natural_scroll = 0;
              };
            };

            misc = {
              disable_autoreload = true;

              enable_swallow = true; # hide windows that spawn other windows

              disable_splash_rendering = true;
              mouse_move_enables_dpms = true;
              key_press_enables_dpms = true;
              disable_hyprland_logo = true;
            };

            "$mod" = "SUPER";
            "$smod" = "SHIFT+$mod";
            "$amod" = "ALT+$mod";
            "$cmod" = "CONTROL+$mod";
            "$scmod" = "CONTROL+SHIFT+$mod";

            bind = [
              "$mod, 1 , workspace, 1"
              "$mod, 2, workspace, 2"
              "$mod, 3, workspace,  3"
              "$mod, 4, workspace,  4"
              "$mod, 5, workspace,  5"
              "$mod, 6, workspace,  6"
              "$mod, 7, workspace,  7"
              "$mod, 8, workspace,  8"
              "$mod, 9, workspace,  9"
              "$mod, 0, workspace, 10"

              # move window to another workspace
              "$smod, 1, movetoworkspace, 1"
              "$smod, 2, movetoworkspace, 2"
              "$smod, 3, movetoworkspace, 3"
              "$smod, 4, movetoworkspace, 4"
              "$smod, 5, movetoworkspace, 5"
              "$smod, 6, movetoworkspace, 6"
              "$smod, 7, movetoworkspace, 7"
              "$smod, 8, movetoworkspace, 8"
              "$smod, 9, movetoworkspace, 9"
              "$smod, 0, movetoworkspace, 10"

              # change workspace with scroll
              "$mod, mouse_down, workspace, e-1"
              "$mod, mouse_up, workspace, e+1"

              #Programs related
              "$mod, R, exec, ags toggle launcher"
              "$cmod, R, exec, rofi -show combi"
              
              "$mod, return, exec, terminator"
              "$mod, W, exec, vivaldi"
              "$mod, E, exec, pcmanfm"
              
              "$scmod, R, exec , ags -q; ags"
              "$mod, ESCAPE, exec, ags toggle sessioncontrols"
              "$mod, L, exec, ags -i lockscreen -c ~/.config/ags/Lockscreen" # hyprlock
              "$mod, V, exec, ags toggle cliphist"
              "$mod, space, exec, ags toggle dashboard"
              "$amod, W, exec, ags toggle wallpapers"

              "$smod, Z,exec,hyprpicker -a -n"

              #screenshot
              ", Print, exec, ${screenarea}"
              "CTRL, Print, exec, ${screenfull}"
              "$mod, Print, exec, ${recordarea}"
              "$smod, Print, exec, ${recordfull}"
              "$scmod, Print, exec, pkill wf-recorder"

              #"$mod SHIFT, R, exec, grimblast --freeze save area - | satty -f- --early-exit --copy-command wl-copy --init-tool rectangle"
              #"CTRL, Print, exec, grimblast --notify --cursor copysave output"
              #"$mod SHIFT CTRL, R, exec, grimblast --notify --cursor copysave output"
              #"ALT, Print, exec, grimblast --notify --cursor copysave screen"
              #"$mod SHIFT ALT, R, exec, grimblast --notify --cursor copysave screen"

              #windows managment related
              "$mod, SEMICOLON, exit,"
              "$smod, f, fullscreen"
              "$mod, f, togglefloating"
              "$amod, p, pin"

              "$mod, q, killactive"

              "$mod, d, makegroup, h"
              "$mod, s, makegroup, v"
              "$mod, TAB, makegroup, tab"
              "$mod, a, changefocus, raise"
              "$smod, a, changefocus, lower"
              "$mod, e, expand, expand"
              "$smod, e, expand, base"
              "$mod, r, changegroup, opposite"
              "$scmod, r, changegroup, toggletab "

              ", XF86AudioPlay, exec, ${playerctl} play-pause"
              ", XF86AudioPrev, exec, ${playerctl} previous"
              ", XF86AudioNext, exec, ${playerctl} next"

              ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
              ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"

              ", XF86MonBrightnessUp, exec, light -A 10"
              ", XF86MonBrightnessDown, exec, light -U 10"

              # WORKSPACE MOVEMENT
              "${builtins.concatStringsSep "\n" (builtins.genList (
                  x: let
                    ws = let
                      c = (x + 1) / 10;
                    in
                      builtins.toString (x + 1 - (c * 10));
                  in ''
                    bind = $mod, ${ws}, workspace, ${toString (x + 1)}
                    bind = $modSHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
                  ''
                )
                10)}"

              #change focus keys
              "$mod, left, movefocus, h"
              "$mod, right, movefocus, l"
              "$mod, up, movefocus, k"
              "$mod, down, movefocus, j"

              #resize submad prolly
            ];
            binde = [
              ",XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5% && ${pactl} get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print substr($5, 1, length($5)-1)}' > $WOBSOCK"
              ",XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5% && ${pactl} get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print substr($5, 1, length($5)-1)}' > $WOBSOCK"
            ];

            bindm = [
              "$mod,mouse:272,movewindow"
              "$mod,mouse:273,resizewindow"
            ];

            workspace = [
              "special,on-created-empty:[pseudo]"
              "special,on-created-empty:[float] konsole"
              # "special:special,on-created-empty:[master]"
              # "special:passes,on-created-empty:[pseudo]"

              "1,monitor:eDP-1,persistent:true"
              # "special:passess,persistent:true"
            ];

            windowrule = [
              "center,^(leagueclientux.exe)$"
              "center,^(league of legends.exe)$"
              # "forceinput,^(league of legends.exe)$"
              "size 1600 900, ^(leaguecientux.exe)$"
              # Zoom
              "float, ^(zoom)$"
              # Bluetooth, network manager
              "float,^(blueman-manager)$"
              "float,^(nm-connection-editor)$"
              "float,^(org.pulseaudio.pavucontrol)$"
              "float, ^(org.gnome.Settings)$"
            ];

            windowrulev2 = [
              "suppressevent maximize fullscreen, class:(.*)"
              "windowrulev2 = noblur, class:(.*)"
              "rounding 0, xwayland:1"
              # --------- Utilities --------
              "float, class:(lxqt-sudo)"

              "float, class:(org.kde.polkit-kde-authentication-agent-1)"
              "float,class:^(udiskie)$"
              "float,class:(org.kde.kdeconnect.daemon), title:(Messages — KDE Connect Daemon)"

              # scratchpads
              #"float,class:^(scratchpad)$"
              #"size 1280 720,class:^(scratchpad)$"
              #"center,class:^(scratchpad)$"
              #"workspace special silent,class:^(scratchpad)$"


              # Action Windows
              "float, title:(Open File)"
              "float, title:(Save File)"
              "float, title:(Choose a directory)"

              # ------- App specific ---------
              # swayimg
              "float, class:(swayimg)"
              "size 400 400, class:(swayimg)"

              # Web Browsers
              #"float, class:(vivaldi-stable), title:(Vivaldi Settings*)"
              "workspace special:special, initialClass:(vivaldi-stable), initialTitle:(Vivaldi - Vivaldi)"
              "float, class:(vivaldi), title:(Print)"
              "workspace special:special, initialClass:(floorp), initialTitle:(Ablaze Floorp)"
              "workspace special:special, initialClass:(LibreWolf), initialTitle:(LibreWolf)"

              # Signal
              "float, class:^(signal)$"
              "size 1000 600, class:^(signal)$"

              # Simplex-chat
              "float, class:^(chat-simplex-desktop-MainKt)$"
              "size 900 500, class:^(chat-simplex-desktop-MainKt)$"

              # Enpass
              "workspace special:passes, class:(Enpass), title:(Enpass)"
              "pseudo, class:(Enpass), title:(enpass)"
              "workspace unset, title:(Enpass Assistant)"
              "float, class:(enpass), title:(Enpass Assistant)"
              "workspace unset, silent, class:^(ente_auth)$"

              # Keepass
              "workspace special:passes, class:^(org.keepassxc.KeePassXC)$"
              "pseudo, class:^(org.keepassxc.KeePassXC)$"
              "minsize: 900 500, class:^(org.keepassxc.KeePassXC)$"
              "workspace unset, class:(org.keepassxc.KeePassXC), title:(KeePassXC - Browser Access Request)"
              "float, class:(org.keepassxc.KeePassXC), title:(KeePassXC - Browser Access Request)"
              "workspace unset, class:(org.keepassxc.KeePassXC), title:(Generate Password)"
              "float, class:(org.keepassxc.KeePassXC), title:(Generate Password)"

              # Geany
              #"pseudo, class:(geany)"
              #"pin, class:(geany)"

              # pcmanfm-qt
              "float, class:(pcmanfm-qt), title:(File Properties)"
              "float, class:(pcmanfm-qt), title:(Preferences)"
              "float, class:(pcmanfm-qt), title:(Copy Files)"
              "float, class:(pcmanfm-qt), title:(Delete Files)"
              "float, class:(pcmanfm-qt), title:(Choose an Application)"

              # gwenview
              "float, class:(gwenview)"

              # Dragon (Video Player)
              "float, class:^(org.kde.dragonplayer)$"
              "center, class:^(org.kde.dragonplayer)$"
              "size 1280 720, class:^(org.kde.dragonplayer)$"
              "idleinhibit always, class:^(org.kde.dragonplayer)$"

              # Gnome Settings
              "center, class:^(org.gnome.Settings)$"
              "size 1280 720, class:^(org.gnome.Settings)$"

              # Cryptomator
              "float, initialClass:(org.cryptomator.launcher.Cryptomator*)"
              "float, class:(ente_auth)"

              # KDE
              "float, class:(org.kde.kmymoney)"

              # PDF Studio
              "float, class:(PDF Studio Pro)"

              # protonvpn
              "float, class:(protonvpn), title:(Proton VPN)"

              # Deezer
              "float, class:(Deezer)"
              "float, class:(deezer-enhanced)"
              "idleinhibit: always, class:(deezer-enhanced)"
              "size 1200 750, class:(deezer-enhanced)"

              # Electron apps
              "float, class:(electron), title:(Open Files)"

              # Kleopatra
              "float, class:^(org.kde.kleopatra)$"
              "float, class:^(Rofi)$"             
            ];
          };
        };
    };
}