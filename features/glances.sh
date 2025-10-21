#!/usr/bin/env bash
# Glances feature module for zcli
# Requires DOCKER_BIN (pinned) and optionally IP_BIN for IP detection

glances_main() {
	# drop primary if present
	if [ "${1-}" = "glances" ]; then shift; fi
	if [ "$#" -lt 1 ]; then
		echo "Error: glances command requires a subcommand." >&2
		echo "Usage: zcli glances [start|stop|restart|status|logs]" >&2
		return 1
	fi

	local sub="$1"
	shift
	case "$sub" in
	start)
		echo "Starting Glances server..."
		if command -v glances-server >/dev/null 2>&1; then
			glances-server start
		else
			echo "Error: glances-server script not found. Make sure glances-server.nix is enabled in your configuration." >&2
			return 1
		fi
		;;
	stop)
		echo "Stopping Glances server..."
		if command -v glances-server >/dev/null 2>&1; then
			glances-server stop
		else
			echo "Error: glances-server script not found. Make sure glances-server.nix is enabled in your configuration." >&2
			return 1
		fi
		;;
	restart)
		echo "Restarting Glances server..."
		if command -v glances-server >/dev/null 2>&1; then
			glances-server restart
		else
			echo "Error: glances-server script not found. Make sure glances-server.nix is enabled in your configuration." >&2
			return 1
		fi
		;;
	status)
		echo "Glances Server Status:"
		echo "==================="
		if command -v glances-server >/dev/null 2>&1; then
			if "$DOCKER_BIN" ps --filter name=glances-server --format "{{.Names}}" | grep -q glances-server; then
				echo "✔ Glances server is running"
				echo ""
				echo "Container Status:"
				glances-server status
				echo ""
				echo "Access URLs:"
				echo "  Local:    http://localhost:61210"
				echo "  Local:    http://127.0.0.1:61210"
				local local_ip
				local_ip=$("$IP_BIN" route get 1.1.1.1 2>/dev/null | grep -Po 'src \K\S+' 2>/dev/null || echo "Unable to detect")
				if [ "$local_ip" != "Unable to detect" ]; then
					echo "  Network:  http://$local_ip:61210"
				fi
				local hostname_fqdn
				hostname_fqdn=$(hostname -f 2>/dev/null || hostname 2>/dev/null || echo "")
				if [ -n "$hostname_fqdn" ] && [ "$hostname_fqdn" != "localhost" ]; then
					echo "  Hostname: http://$hostname_fqdn:61210"
				fi
			else
				echo "✗ Glances server is not running"
				echo "Run 'zcli glances start' to start it"
			fi
		else
			echo "Error: glances-server script not found. Make sure glances-server.nix is enabled in your configuration." >&2
			return 1
		fi
		;;
	logs)
		echo "Showing Glances server logs..."
		if command -v glances-server >/dev/null 2>&1; then
			glances-server logs
		else
			echo "Error: glances-server script not found. Make sure glances-server.nix is enabled in your configuration." >&2
			return 1
		fi
		;;
	*)
		echo "Error: Invalid glances subcommand '$sub'" >&2
		echo "Usage: zcli glances [start|stop|restart|status|logs]" >&2
		return 1
		;;
	esac
}
