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
      programs = {
        hyprland = {
          enable = true;
          package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
          #package = inputs.hyprland.packages.${pkgs.system}.hyprland;
          xwayland.enable = true;
        };
        hyprlock.enable = true;
      };
      
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ];
      };

        home.packages = with pkgs; [
          grimblast
          swww
          satty
          playerctl
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

            screenarea = "grimbblast save area - | satty --filename - ";
            screenactive = "grimblast save active - | satty --filename - ";
            screenfull = "grimblast save full - | satty --filename - ";

            recordarea = ''wf-recorder -g "$(slurp)" -x yuv420p -c libx264 -f "$(satty --filename -)"'';
            recordfull = ''wf-recorder -x yuv420p -c libx264 -f "$(satty --filename -)"'';
          in {
            env = mapAttrsToList (name: value: "${name},${toString value}") {
              XDG_CURRENT_DESKTOP = "Hyprland";
              XDG_SESSION_DESKTOP = "Hyprland";
              XDG_SESSION_TYPE = "wayland";

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
              swallow_regex = "foot|footclient"; # windows for which swallow is applied

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
              # "$mod, space, exec, anyrun"
              "$mod, space, exec, "
              # Launches foot with a tmux sesison -> got it from https://discord.com/channels/601130461678272522/1136357112579108904
              "$mod, return, exec,wezterm "
              "CTRL,F,exec, floorp "

              "CTRL, D,exec, ferdium"

              #screenshot
              ", Print, exec, ${screenarea}"
              "$mod SHIFT, R, exec, grimblast --freeze save area - | satty -f- --early-exit --copy-command wl-copy --init-tool rectangle"
              "CTRL, Print, exec, grimblast --notify --cursor copysave output"
              "$mod SHIFT CTRL, R, exec, grimblast --notify --cursor copysave output"
              "ALT, Print, exec, grimblast --notify --cursor copysave screen"
              "$mod SHIFT ALT, R, exec, grimblast --notify --cursor copysave screen"

              #windows managment related
              "$mod, SEMICOLON, exit,"
              "$smod, f, fullscreen"
              "$mod, v, togglefloating"

              "$smod, q, hy3:killactive"

              "$mod, d, hy3:makegroup, h"
              "$mod, s, hy3:makegroup, v"
              # "$smod,s  ,exec, hyprlock"
              "$mod, TAB, hy3:makegroup, tab"
              "$mod, a, hy3:changefocus, raise"
              "$smod, a, hy3:changefocus, lower"
              "$mod, e, hy3:expand, expand"
              "$smod, e, hy3:expand, base"
              "$mod, r, hy3:changegroup, opposite"
              "$scmod, r, hy3:changegroup, toggletab "

              ",XF86AudioPlay,exec,${playerctl} play-pause"
              ",XF86AudioPrev,exec,${playerctl} previous"
              ",XF86AudioNext,exec,${playerctl} next"

              ",XF86AudioMute,exec,swayosd-client --output-volume mute-toggle"
              ",XF86AudioMicMute,exec,swayosd-client --input-volume mute-toggle"

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

            windowrule = [
              "center,^(leagueclientux.exe)$"
              "center,^(league of legends.exe)$"
              # "forceinput,^(league of legends.exe)$"
              "size 1600 900, ^(leaguecientux.exe)$"
            ];

            windowrulev2 = [
              "rounding 0, xwayland:1"
              "float, class:^(leagueclientux.exe)$,title:^(League of Legends)$"
              # "immediate, class:^(osu\!)$"
            ];
          };
        };
    };
}