{
  pkgs,
  config,
  lib,
  ...
}: let
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  light = "${pkgs.light}/bin/light";

      screenarea = ''grim -g "$(slurp)" "$(xdg-user-dir PICTURES)/Pictures/Screen/Screenshot-area_$(date +%y-%m-%d_%H%M-%S).png"'';
      screenfull = ''grim "$(xdg-user-dir PICTURES)/Pictures/Screenshot-full_$(date +%y-%m-%d_%H%M-%S).png"'';

      recordarea = ''wf-recorder -g "$(slurp)" -x yuv420p -c libx264 -f "$(xdg-user-dir PICTURES)/Screenrecording-area_$(date +%y-%m-%d_%H%M-%S).mp4"'';
      recordfull = ''wf-recorder -x yuv420p -c libx264 -f "$(xdg-user-dir PICTURES)/Screenrecording-full_$(date +%y-%m-%d_%H%M-%S).mp4"'';
in {
  options.river.enable = lib.mkEnableOption "river";

  config = lib.mkIf config.river.enable {
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ];
        config.common.default = "*";
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
      };
      
      home.packages = with pkgs; [
        swww
        playerctl
        wl-clipboard
        grim
        slurp
        playerctl
        kitty
      ];
        
      home.pointerCursor = {
        gtk.enable = true;
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 16;
        x11 = {
          defaultCursor = "Bibata-Modern-Classic";
          enable = true;
        };
      };

      wayland.windowManager.river = let
        layout = "rivertile";
      in {
        enable = true;
        xwayland.enable = true;
          systemd = {
            enable = true;
            variables = ["--all"];
          };
        
        settings = let
          mod = "Super";
          mods = "Super+Shift";
          modas = "Super+Alt+Shift";
          moda = "Super+Alt";
          modc = "Super+Control";
          modca = "Super+Control+Alt";
          modsc = "Super+Shift+Control";
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
              "${mods} Q" = "close";
              "${mod} Return" = "spawn terminator";
              "${mod} E" = "spawn pcmanfm";
              "${mod} W" = "spawn vivaldi";

              "${mod} SPACE" = ''spawn "ags toggle launcher"'';
              "${moda} SPACE" = ''spawn "rofi -show combi"'';

              "${mod} V" = ''spawn "ags toggle cliphist"'';
              "${moda} W" = ''spawn "ags toggle wallpapers"'';
              "${mod} X" = ''spawn "ags toggle dashboard"'';
              "${mod} Escape" = ''spawn "ags toggle sessioncontrols"'';
              "${mod} L" = ''spawn "ags -i lockscreen -c ~/.config/ags/Lockscreen"'';

              #screenShots Not Done yet
              "Print" = ''spawn "${screenarea}"'';
              "CTRL Print" = ''spawn "${screenfull}"'';
              "${mod} Print" = ''spawn "${recordarea}"'';
              "${mods} Print" = ''spawn "${recordfull}"'';
              "${modsc} Print" = ''spawn "killall wf-recorder"'';
              
              "${mods} F" = "toggle-fullscreen";
              "${mod} Z" = "zoom";
              "${mod} F" = "toggle-float";
              "${mod} J" = "focus-view previous";
              "${mod} K" = "focus-view next";
              "${mods} Period" = "send-to-output next";
              "${mods} Comma" = "send-to-output previous";

              # move viewss
              "${moda} H" = "move left 100";
              "${moda} J" = "move down 100";
              "${moda} K" = "move up 100";
              "${moda} L" = "move right 100";

              # snap vies to screen edges
              "${modca} H" = "snap left";
              "${modca} J" = "snap down";
              "${modca} K" = "snap up";
              "${modca} L" = "snap right";

              # resize views
              "${modas} H" = "resize horizontal -100";
              "${modas} J" = "resize vertical 100";
              "${modas} K" = "resize vertical -100";
              "${modas} L" = "resize horizontal 100";

              #increase and decrease the main ratio of rivertile
              "${mod} L" = ''send-layout-cmd ${layout} "main-ratio -0.05"'';
              "${mod} H" = ''send-layout-cmd ${layout} "main-ratio +0.05"'';

              #increment/decrement the main count of rivertile(1)
              "${mods} H" = ''send-layout-cmd ${layout} "main-count +1"'';
              "${mods} L" = ''send-layout-cmd ${layout} "main-count -1"'';
            };
          };
          spawn = [
            "${layout}"
            "ags run"
            "${pkgs.swwww}/bin/swww-daemon && ${pkgs.swww}/bin/swww restore"
            "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store"
            "signal-desktop --start-in-tray"

            "udiskie --tray"
            "swayosd-server"
            "kdeconnect-indicator"

            "keepassxc"
            # "ente_auth"
            
            # "cryptomator"
            "pcloud"
            "filen-desktop"
            # "synology-drive"
          ];

         # rule-add = {
         #   "-app-id" = {
         #     "'vivaldi'" = "ssd";
         #   };
         # };

          # xcursor-theme = "phinger-cursors";
          # set-repeat = "50 300";
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
  }