# Hyprspace is a hyprland plugin that provides a workspaces overview SUPER + TAB .
{ pkgs, ... }: {
  wayland.windowManager.hyprland = {
    plugins = [ pkgs.hyprlandPlugins.hyprspace ];
    settings = {
      plugin = {
        overview = {
          panelColor = "rgba(00000000)";
          panelBorderColor = "rgba(E0E0E0FF)";
          workspaceActiveBackground = "rgba(E0E0E0FF)";
          workspaceInactiveBackground = "rgba(0F0F0FFF)";
          workspaceActiveBorder = "rgba(E0E0E0FF)";
          workspaceInactiveBorder = "rgba(E0E0E033)";
          panelBorderWidth = 10;
          panelHeight = 275;
          reservedArea = 70;
          gapsIn = 10;
          gapeOut = 10;
          onBottom = false;
          centerAligned = true;
          hideBackgroundLayers = false;
          hideOverlayLayers = true;
          hideRealLayers = false;
          drawActiveWorkspace = true;
          affectStrut = false;
          dragAlpha = 1;
          showEmptyWorkspace = false;
          showSpecialWorkspace = false;
          hideTopLayers = true;
          showNewWorkspace = true;
          exitOnClick = true;
          exitOnSwitch = true;
        };
      };
    };
  };
}
