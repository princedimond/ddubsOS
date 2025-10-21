{ ... }:
{
  services.udiskie = {
    enable = true;
    # Optional niceties:
    # automount = true;   # udiskie defaults to automounting removable drives
    # notify = true;      # desktop notifications on mount/unmount
    # tray = true;        # show a tray icon if your DE supports it
  };
}

