{ host,
  config,
  pkgs,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) enableGlances;
  # Catppuccin Mocha themed Glances configuration
  glancesConfig = pkgs.writeText "glances.conf" ''
    [global]
    # Refresh time
    refresh=2
    # Should Glances check if a newer version is available on PyPI ?
    check_update=false
    # Display additional information
    history_size=28800

    [colors]
    # Catppuccin Mocha color scheme for terminal interface
    # Text colors
    default_color=BLUE
    default_color2=WHITE
    default_color3=GREEN

    # Status colors based on Catppuccin Mocha palette
    # OK status - Green
    ok_color=GREEN
    # Warning status - Yellow/Peach
    warning_color=YELLOW
    # Critical status - Red
    critical_color=RED

    # CPU colors
    cpu_user_color=BLUE
    cpu_system_color=MAGENTA
    cpu_iowait_color=CYAN

    # Memory colors
    mem_used_color=BLUE
    mem_available_color=GREEN
    mem_cached_color=CYAN

    # Network colors
    net_rx_color=GREEN
    net_tx_color=RED

    # Disk colors
    disk_read_color=GREEN
    disk_write_color=RED

    [cpu]
    # CPU thresholds
    user_careful=50
    user_warning=70
    user_critical=90
    system_careful=50
    system_warning=70
    system_critical=90

    [memory]
    # Memory thresholds
    careful=50
    warning=70
    critical=90

    [load]
    # Load average thresholds
    careful=70
    warning=100
    critical=500

    [network]
    # Hide loopback interface
    hide=lo

    [diskio]
    # Hide loop devices
    hide=loop.*

    [fs]
    # Hide certain filesystems
    hide=/boot.*,/snap.*

    [sensors]
    # Temperature thresholds
    temperature_core_careful=60
    temperature_core_warning=70
    temperature_core_critical=80

    [docker]
    # Docker monitoring
    disable=False
    max_name_size=20

    [webapp]
    # Web interface settings
    title="System Monitor - Catppuccin Mocha"
    # Use hostname instead of IP
    username=""

    [ip]
    # Hide Docker internal networks and show host network info
    disable=False
    # Show public IP and local network info
    public=True

    [system]
    # Hostname and system info display
    disable=False
  '';

  # Custom CSS for Catppuccin Mocha theme (to be injected via nginx)
  catppuccinCSS = ''
    /* Catppuccin Mocha Color Palette */
    :root {
      --ctp-rosewater: #f5e0dc;
      --ctp-flamingo: #f2cdcd;
      --ctp-pink: #f5c2e7;
      --ctp-mauve: #cba6f7;
      --ctp-red: #f38ba8;
      --ctp-maroon: #eba0ac;
      --ctp-peach: #fab387;
      --ctp-yellow: #f9e2af;
      --ctp-green: #a6e3a1;
      --ctp-teal: #94e2d5;
      --ctp-sky: #89dceb;
      --ctp-sapphire: #74c7ec;
      --ctp-blue: #89b4fa;
      --ctp-lavender: #b4befe;
      --ctp-text: #cdd6f4;
      --ctp-subtext1: #bac2de;
      --ctp-subtext0: #a6adc8;
      --ctp-overlay2: #9399b2;
      --ctp-overlay1: #7f849c;
      --ctp-overlay0: #6c7086;
      --ctp-surface2: #585b70;
      --ctp-surface1: #45475a;
      --ctp-surface0: #313244;
      --ctp-base: #1e1e2e;
      --ctp-mantle: #181825;
      --ctp-crust: #11111b;
    }

    /* Global styles */
    body {
      background-color: var(--ctp-base) !important;
      color: var(--ctp-text) !important;
      font-family: 'JetBrains Mono', 'Fira Code', 'Source Code Pro', monospace !important;
    }

    /* Header and navigation */
    .navbar, .navbar-default {
      background-color: var(--ctp-mantle) !important;
      border-color: var(--ctp-surface0) !important;
    }

    .navbar-brand, .navbar-nav > li > a {
      color: var(--ctp-text) !important;
    }

    .navbar-nav > li > a:hover {
      background-color: var(--ctp-surface0) !important;
      color: var(--ctp-lavender) !important;
    }

    /* Panel styling */
    .panel {
      background-color: var(--ctp-surface0) !important;
      border-color: var(--ctp-surface1) !important;
    }

    .panel-heading {
      background-color: var(--ctp-surface1) !important;
      border-color: var(--ctp-surface2) !important;
      color: var(--ctp-text) !important;
    }

    .panel-body {
      background-color: var(--ctp-surface0) !important;
      color: var(--ctp-text) !important;
    }

    /* Table styling */
    .table {
      color: var(--ctp-text) !important;
    }

    .table > tbody > tr > td {
      border-color: var(--ctp-surface1) !important;
    }

    .table-striped > tbody > tr:nth-of-type(odd) {
      background-color: var(--ctp-surface1) !important;
    }

    /* Progress bars */
    .progress {
      background-color: var(--ctp-surface1) !important;
    }

    .progress-bar {
      background-color: var(--ctp-blue) !important;
    }

    .progress-bar-success {
      background-color: var(--ctp-green) !important;
    }

    .progress-bar-warning {
      background-color: var(--ctp-peach) !important;
    }

    .progress-bar-danger {
      background-color: var(--ctp-red) !important;
    }

    /* Status colors */
    .text-success, .glyphicon-ok-sign {
      color: var(--ctp-green) !important;
    }

    .text-warning, .glyphicon-warning-sign {
      color: var(--ctp-peach) !important;
    }

    .text-danger, .glyphicon-exclamation-sign {
      color: var(--ctp-red) !important;
    }

    .text-info {
      color: var(--ctp-sky) !important;
    }

    /* Buttons */
    .btn-default {
      background-color: var(--ctp-surface1) !important;
      border-color: var(--ctp-surface2) !important;
      color: var(--ctp-text) !important;
    }

    .btn-default:hover {
      background-color: var(--ctp-surface2) !important;
      color: var(--ctp-lavender) !important;
    }

    /* Chart styling */
    .nvd3 .nv-axis text {
      fill: var(--ctp-text) !important;
    }

    .nvd3 .nv-axis path {
      stroke: var(--ctp-overlay0) !important;
    }

    /* Custom metric colors */
    .cpu-user { color: var(--ctp-blue) !important; }
    .cpu-system { color: var(--ctp-mauve) !important; }
    .cpu-iowait { color: var(--ctp-teal) !important; }
    .mem-used { color: var(--ctp-blue) !important; }
    .mem-available { color: var(--ctp-green) !important; }
    .mem-cached { color: var(--ctp-teal) !important; }
    .net-rx { color: var(--ctp-green) !important; }
    .net-tx { color: var(--ctp-red) !important; }
    .disk-read { color: var(--ctp-green) !important; }
    .disk-write { color: var(--ctp-red) !important; }

    /* Footer */
    .footer {
      background-color: var(--ctp-mantle) !important;
      color: var(--ctp-subtext0) !important;
    }
  '';

  # CSS file to be served separately
  catppuccinCSSFile = pkgs.writeText "catppuccin.css" catppuccinCSS;

  # Nginx configuration for themed proxy
  nginxConfig = pkgs.writeText "glances-proxy.conf" ''
    server {
        listen 61210;
        server_name localhost;

        # Serve the custom CSS file
        location /catppuccin.css {
            root /usr/share/nginx/html;
            add_header Content-Type text/css;
            add_header Access-Control-Allow-Origin *;
        }

        location / {
            proxy_pass http://127.0.0.1:61211;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Inject CSS link into HTML head
            sub_filter '</head>' '<link rel="stylesheet" type="text/css" href="/catppuccin.css"></head>';
            sub_filter_once on;
            sub_filter_types text/html;
        }

        # WebSocket support for real-time updates
        location /ws {
            proxy_pass http://127.0.0.1:61211;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
        }
    }
  '';
in {
  # Glances monitoring server service with catppuccin mocha theme
  systemd.services.glances-server = {
    description = "Glances monitoring server in Docker (Catppuccin Mocha themed)";
    after = ["docker.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker}/bin/docker run -d --name=glances-server --restart=always --network=host --privileged -v /var/run/docker.sock:/var/run/docker.sock:ro -v ${glancesConfig}:/etc/glances/glances.conf:ro nicolargo/glances:ubuntu-latest-full glances -w -C /etc/glances/glances.conf --port 61211";
      ExecStop = "${pkgs.docker}/bin/docker stop glances-server";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f glances-server";
    };

    # Ensure docker is available
    requires = ["docker.service"];
  };

  # Nginx proxy for themed web interface
  systemd.services.glances-proxy = {
    description = "Nginx proxy for themed Glances web interface";
    after = ["glances-server.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker}/bin/docker run -d --name=glances-proxy --restart=always --network=host -v ${nginxConfig}:/etc/nginx/conf.d/default.conf:ro -v ${catppuccinCSSFile}:/usr/share/nginx/html/catppuccin.css:ro nginx:alpine";
      ExecStop = "${pkgs.docker}/bin/docker stop glances-proxy";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f glances-proxy";
    };

    requires = ["glances-server.service" "docker.service"];
  };

  # Enable the services based on configuration variable
  systemd.services.glances-server.enable = enableGlances;
  systemd.services.glances-proxy.enable = enableGlances;
}
