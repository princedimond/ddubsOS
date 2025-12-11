{
  pkgs,
  lib,
  ...
}: let
  settings = import ./settings.nix {inherit pkgs lib;};
  rules = import ./rules.nix {inherit pkgs;};
  autostart = import ./autostart.nix {inherit pkgs;};

  q = s: "\"${s}\"";
  indent = level: s: builtins.concatStringsSep "\n" (map (l: (builtins.concatStringsSep "" (builtins.genList (_: " ") (level * 2))) + l) (lib.splitString "\n" s));

  renderEnvironment = env: let
    lines = lib.mapAttrsToList (k: v: "  ${k} ${q v}") env;
  in
    "environment {\n" + (lib.concatStringsSep "\n" lines) + "\n}";

  renderInput = i: let
    kb = i.keyboard or {};
    tp = i.touchpad or {};
    kbBlock =
      if kb ? xkb && kb.xkb ? layout
      then ''
        keyboard {
          xkb {
            layout ${q kb.xkb.layout}
          }
        }
      ''
      else "";
    tpLines = [
      (
        if (tp.tap or false)
        then "tap"
        else ""
      )
      (
        if (tp.dwt or false)
        then "dwt"
        else ""
      )
      (
        if (tp ? accelSpeed)
        then "accel-speed ${toString tp.accelSpeed}"
        else ""
      )
      (
        if (tp ? accelProfile)
        then "accel-profile ${q tp.accelProfile}"
        else ""
      )
      (
        if (tp ? scrollMethod)
        then "scroll-method ${q tp.scrollMethod}"
        else ""
      )
      (
        if (tp ? tapButtonMap)
        then "tap-button-map ${q tp.tapButtonMap}"
        else ""
      )
      (
        if (tp ? scrollFactor)
        then "scroll-factor ${toString tp.scrollFactor}"
        else ""
      )
    ];
    tpBlock =
      if (lib.any (s: s != "") tpLines)
      then ''
        touchpad {
          ${lib.concatStringsSep "\n          " (lib.filter (s: s != "") tpLines)}
        }
      ''
      else "";
    ffm =
      if (i.focusFollowsMouse or false)
      then "\n  focus-follows-mouse"
      else "";
  in
    "input {\n" + (indent 1 (lib.concatStringsSep "\n" (lib.filter (s: s != "") [kbBlock tpBlock]))) + ffm + "\n}";

  renderOverview = o: let
    zoom =
      if o ? zoom
      then "  zoom ${toString o.zoom}\n"
      else "";
    backdrop =
      if o ? backdropColor
      then "  backdrop-color ${q o.backdropColor}\n"
      else "";
  in
    "overview {\n" + zoom + backdrop + "}";

  renderOutputs = outs:
    lib.concatStringsSep "\n\n" (map (o: ''
        output ${q o.name} {
          mode ${q o.mode}
          scale ${toString o.scale}
        }
      '')
      outs);

  renderLayout = l: let
    gaps =
      if l ? gaps
      then "  gaps ${toString l.gaps}\n"
      else "";
    bg =
      if l ? backgroundColor
      then "  background-color ${q l.backgroundColor}\n"
      else "";
    dcw =
      if l ? defaultColumnWidth
      then "  default-column-width { proportion ${toString l.defaultColumnWidth.proportion}; }\n"
      else "";
    fr =
      if l ? focusRing && (l.focusRing.enable or false) == false
      then "  focus-ring { off; }\n"
      else "";
    border =
      if l ? border
      then ''
        border {
          width ${toString l.border.width}
          active-color ${q l.border.activeColor}
          inactive-color ${q l.border.inactiveColor}
        }
      ''
      else "";
    shadow =
      if l ? shadow
      then ''
        shadow {
          on
          softness ${toString l.shadow.softness}
          spread ${toString l.shadow.spread}
          offset x=${toString l.shadow.offset.x} y=${toString l.shadow.offset.y}
          color ${q l.shadow.color}
        }
      ''
      else "";
    struts =
      if l ? struts
      then ''
        struts {
          left ${toString l.struts.left}
          right ${toString l.struts.right}
          top ${toString l.struts.top}
          bottom ${toString l.struts.bottom}
        }
      ''
      else "";
  in
    "layout {\n" + gaps + bg + dcw + fr + (indent 1 border) + (indent 1 shadow) + (indent 1 struts) + "}";

  renderCursor = c: let
    theme =
      if c ? xcursorTheme
      then "  xcursor-theme ${q c.xcursorTheme}\n"
      else "";
    size =
      if c ? xcursorSize
      then "  xcursor-size ${toString c.xcursorSize}\n"
      else "";
    hwt =
      if c ? hideWhenTyping && c.hideWhenTyping
      then "  hide-when-typing\n"
      else "";
    hideMs =
      if c ? hideAfterInactiveMs
      then "  hide-after-inactive-ms ${toString c.hideAfterInactiveMs}\n"
      else "";
  in
    "cursor {\n" + theme + size + hwt + hideMs + "}";

  renderSpawn = spawns:
    lib.concatStringsSep "\n" (map (cmd: "spawn-at-startup " + (lib.concatStringsSep " " (map q cmd))) spawns);

  renderSwitchEvents = events: let
    lines = lib.concatStringsSep "\n" (map (e: "  ${e.event} {spawn " + (lib.concatStringsSep " " (map q e.spawn)) + ";}") events);
  in
    "switch-events {\n" + lines + "\n}";

  generatedKdl = lib.concatStringsSep "\n\n" (lib.filter (s: s != "") [
    (
      if settings.hotkeyOverlay.skipAtStartup
      then ''        hotkey-overlay { 
          skip-at-startup 
        }''
      else ""
    )
    (renderEnvironment settings.environment)
    (renderInput settings.input)
    (renderOverview settings.overview)
    (renderOutputs settings.outputs)
    (renderLayout settings.layout)
    (renderSpawn autostart.spawnAtStartup)
    (renderSwitchEvents settings.switchEvents)
    (renderCursor settings.cursor)
    (
      if (settings.preferNoCsd or false)
      then "prefer-no-csd"
      else ""
    )
    (
      if settings ? screenshotPath
      then "screenshot-path " + q settings.screenshotPath
      else ""
    )
    settings.animationsText
    "config-notification {\n  disable-failed\n}"
    ("binds {\n" + settings.bindsText + "\n}")
    rules.windowRulesKdl
    rules.layerRulesKdl
  ]);
in {
  imports = [./waybar-niri.nix];

  home.packages = with pkgs; [
    niri
    waybar
    udiskie
    xwayland-satellite
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
    swww
    wl-clipboard
    mate.mate-polkit
  ];

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps.enable = true;
    portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-wlr pkgs.xdg-desktop-portal-gtk];
      configPackages = [pkgs.niri];
    };

    # Render Niri config from Nix modules
    configFile."niri/config.kdl".text = generatedKdl;
  };

  home.sessionVariables = {
    QS_HAS_NIRI = "1";
    WALLPAPER_BACKEND = "swww";
  };
}
