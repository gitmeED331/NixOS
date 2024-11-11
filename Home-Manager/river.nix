{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.display.river;
in {
  options.display.river.enable = lib.mkEnableOption "river wm";

  config = lib.mkIf cfg.enable {
    os = {
      # services.displayManager.sessionPackages = let
      #   session = pkgs.stdenvNoCC.mkDerivation {
      #     name = "river-wayland-session";
      #     src = pkgs.writeTextDir "entry" ''
      #       Desktop Entry]
      #       Name=River
      #       Comment=A dynamic tiling Wayland compositor
      #       Exec=river
      #       Type=Application
      #     '';
      #     dontBuild = true;

      #     installPhase = ''
      #       mkdir -p $out/share/wayland-sessions
      #       cp entry $out/share/wayland-sessions/river.desktop
      #     '';
      #     passthru.providedSessions = ["river"];
      #   };
      # in [session];

      programs.river = {
        enable = true;
        extraPackages = with pkgs; [
          wl-clipboard
          grim
          slurp
          grimblast
          satty
        ];
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ];
      };
    };

    hm = let
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };

      screenarea = "grimblast save area - | satty --filename - ";
      screenactive = "grimblast save active - | satty --filename - ";
      screenfull = "grimblast save full - | satty --filename - ";

      recordarea = ''wf-recorder -g "$(slurp)" -x yuv420p -c libx264 -f "${satty --filename -}"'';
      recordfull = ''wf-recorder -x yuv420p -c libx264 -f "${satty --filename -}"'';
    in {

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
      };

      home.pointerCursor = {
        gtk.enable = true;
        name = cursor.name;
        package = cursor.package;
        size = cursor.size;
        x11 = {
          defaultCursor = cursor.name;
          enable = true;
        };
      };

      wayland.windowManager.river = let
        layout = "rivertile";
      in {
        enable = true;
        xwayland.enable = true;
        settings = let
          main = "Super";
          ssm = "Super+Shift";
          sas = "Super+Alt+Shift";
          sam = "Super+Alt";
          scm = "Super+Control";
          scam = "Super+Control+Alt";
        in {
          default-layout = "${layout}";
          output-layout = "${layout}";
          border-width = 2;
          declare-mode = [
            "locked"
            "normal"
          ];
          map = {
            normal = {
              "${ssm} Q" = "close";
              "Super Return" = "spawn ${config.defaults.terminal}";
              "${main} E" = "spawn pcmanfm";
              "${main} W" = "spawn vivaldi";

              "${main} SPACE" = ''spawn "ags toggle launcher"'';
              "${sam} SPACE" = ''spawn "rofi -show combi"'';

              "${main} V" = ''spawn "ags toggle cliphist"'';
              "${sam} W" = ''spawn "ags toggle wallpapers"'';
              "${main} X" = ''spawn "ags toggle dashboard"'';
              "${ssm} Escape" = ''spawn "ags toggle sessioncontrols"'';
              "${main} L" = ''spawn "ags -i lockscreen -c ~/.config/ags/Lockscreen"'';

              #screenShots Not Done yet
              "Print" = ''spawn "${screenarea}"'';
              "${main} Print" = "spawn ${screenfull}";
              "${ssm} Print" = "spawn ${screenactive}";
              "${main} S" = "spawn ${recordarea}";
              "${ssm} S" = "spawn ${recordfull}";
              "${ssm} S" = "spawn killall wf-recorder";
              
              "${ssm} F" = "toggle-fullscreen";
              "${main} Z" = "zoom";
              "${main} F" = "toggle-float";
              "${main} J" = "focus-view previous";
              "${main} K" = "focus-view next";
              "${ssm} Period" = "send-to-output next";
              "${ssm} Comma" = "send-to-output previous";

              # move viewss
              "${sam} H" = "move left 100";
              "${sam} J" = "move down 100";
              "${sam} K" = "move up 100";
              "${sam} L" = "move right 100";

              # snap vies to screen edges
              "${scam} H" = "snap left";
              "${scam} J" = "snap down";
              "${scam} K" = "snap up";
              "${scam} L" = "snap right";

              # resize views
              "${sas} H" = "resize horizontal -100";
              "${sas} J" = "resize vertical 100";
              "${sas} K" = "resize vertical -100";
              "${sas} L" = "resize horizontal 100";

              #increase and decrease the main ratio of rivertile
              "${main} L" = ''send-layout-cmd ${layout} "main-ratio -0.05"'';
              "${main} H" = ''send-layout-cmd ${layout} "main-ratio +0.05"'';

              #increment/decrement the main count of rivertile(1)
              "${ssm} H" = ''send-layout-cmd ${layout} "main-count +1"'';
              "${ssm} L" = ''send-layout-cmd ${layout} "main-count -1"'';
            };
          };
          spawn = [
            ''${layout}''
            "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store #Stores only text data"
            "${pkgs.bash} startup.sh"
            "ags run"
            "udiskie --tray"
          ];

          rule-add = {
            "-app-id" = {
              "'vivaldi'" = "ssd";
            };
          };

          xcursor-theme = "phinger-cursors";
          set-repeat = "50 300";
          focus-follows-cursor = "normal";

          map-pointer = {
            normal = {
              "Super BTN_LEFT" = "move-view";
              "Super BTN_RIGHT" = "resize-view";
            };
          };
        };

        extraSessionVariables = {          
          XDG_CURRENT_DESKTOP = "river";
          XDG_SESSION_DESKTOP = "river";
        };

        extraConfig = ''
                    for i in $(seq 1 9)
                     do
                      tags=$((1 << ($i - 1)))
                    # Super+[1-9] to focus tag [0-8]
                       riverctl map normal Super $i set-focused-tags $tags
                    # Super+Shift+[1-9] to tag focused view with tag [0-8]
                       riverctl map normal Super+Shift $i set-view-tags $tags
                    # Super+Control+[1-9] to toggle focus of tag [0-8]
                       riverctl map normal Super+Control $i toggle-focused-tags $tags
                    # Super+Shift+Control+[1-9] to toggle tag [0-8] of focused view
                      riverctl map normal Super+Shift+Control $i toggle-view-tags $tags
                      done
                    # Super+0 to focus all tags
                    # Super+Shift+0 to tag focused view with all tags
                      all_tags=$(((1 << 32) - 1))
                      riverctl map normal Super 0 set-focused-tags $all_tags
                      riverctl map normal Super+Shift 0 set-view-tags $all_tags

                                   # Super+{Up,Right,Down,Left} to change layout orientation
                      riverctl map normal Super Up    send-layout-cmd rivertile "main-location top"
                      riverctl map normal Super Right send-layout-cmd rivertile "main-location right"
                      riverctl map normal Super Down  send-layout-cmd rivertile "main-location bottom"
                      riverctl map normal Super Left  send-layout-cmd rivertile "main-location left"

                              function focus_tag_map
              {
                  if [[ $(command -v river-bnf) ]]
                  then
                      riverctl map "$1" "$2" "$3" spawn "river-bnf $4"
                  else
                      riverctl map "$1" "$2" "$3" set-focused-tags "$4"
                  fi
              }

              for i in $(seq 1 9)
              do
                  tagmask=$(( 1 << ($i - 1) ))
                  focus_tag_map normal Super $i $tagmask
              done

                  ${layout} -view-padding 2 -outer-padding 2 &

        '';
      };
    };
  };
}