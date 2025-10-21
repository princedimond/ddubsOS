{ pkgs }:
pkgs.writeShellScriptBin "glances-server" ''
  # Glances server management script
  
  # Debug: Show what command was received (uncomment for debugging)
  # echo "Debug: Received command: '$1'"
  
  case "''${1:-help}" in
    start)
      echo "Starting glances server..."
      # Stop and remove existing container if it exists
      ${pkgs.docker}/bin/docker stop glances-server 2>/dev/null || true
      ${pkgs.docker}/bin/docker rm -f glances-server 2>/dev/null || true
      # Start new container
      ${pkgs.docker}/bin/docker run -d --name=glances-server --restart=always -p 61210:61208 --privileged -v /var/run/docker.sock:/var/run/docker.sock:ro nicolargo/glances:ubuntu-latest-full glances -w
      echo "Glances server started on port 61210"
      echo "Access web interface at: http://localhost:61210"
      ;;
    stop)
      echo "Stopping glances server..."
      ${pkgs.docker}/bin/docker stop glances-server
      ${pkgs.docker}/bin/docker rm -f glances-server
      echo "Glances server stopped"
      ;;
    restart)
      echo "Restarting glances server..."
      ${pkgs.docker}/bin/docker stop glances-server 2>/dev/null || true
      ${pkgs.docker}/bin/docker rm -f glances-server 2>/dev/null || true
      ${pkgs.docker}/bin/docker run -d --name=glances-server --restart=always -p 61210:61208 --privileged -v /var/run/docker.sock:/var/run/docker.sock:ro nicolargo/glances:ubuntu-latest-full glances -w
      echo "Glances server restarted"
      ;;
    status)
      echo "Glances Server Status:"
      echo "==================="
      
      # Check if container is running
      if ${pkgs.docker}/bin/docker ps --filter name=glances-server --format "{{.Names}}" | grep -q glances-server; then
        echo "✔ Glances server is running"
        echo ""
        echo "Container Status:"
        ${pkgs.docker}/bin/docker ps --filter name=glances-server --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        echo "Access URLs:"
        echo "  Local:    http://localhost:61210"
        echo "  Local:    http://127.0.0.1:61210"
        
        # Get current local IP address
        local_ip=$(ip route get 1.1.1.1 2>/dev/null | grep -Po 'src \K\S+' 2>/dev/null || echo "Unable to detect")
        if [ "$local_ip" != "Unable to detect" ]; then
          echo "  Network:  http://$local_ip:61210"
        fi
        
        # Try to get hostname for additional access option
        hostname_fqdn=$(hostname -f 2>/dev/null || hostname 2>/dev/null || echo "")
        if [ -n "$hostname_fqdn" ] && [ "$hostname_fqdn" != "localhost" ]; then
          echo "  Hostname: http://$hostname_fqdn:61210"
        fi
      else
        echo "✗ Glances server is not running"
        echo "Run 'glances-server start' to start it"
      fi
      ;;
    logs)
      echo "Showing glances server logs..."
      ${pkgs.docker}/bin/docker logs -f glances-server
      ;;
    help|--help|-h)
      echo "Glances Server Management Script"
      echo ""
      echo "Usage: glances-server {start|stop|restart|status|logs|help}"
      echo ""
      echo "Commands:"
      echo "  start    - Start the glances server container"
      echo "  stop     - Stop and remove the glances server container"
      echo "  restart  - Restart the glances server container"
      echo "  status   - Show container status"
      echo "  logs     - Show container logs (follow mode)"
      echo "  help     - Show this help message"
      echo ""
      echo "The server runs on port 61210 and can be accessed at http://localhost:61210"
      ;;
    stat*)
      echo "Error: Did you mean 'status'? Unknown command '$1'"
      echo "Usage: glances-server {start|stop|restart|status|logs|help}"
      echo "Run 'glances-server help' for more information"
      exit 1
      ;;
    *)
      echo "Error: Unknown command '$1'"
      echo "Usage: glances-server {start|stop|restart|status|logs|help}"
      echo "Run 'glances-server help' for more information"
      exit 1
      ;;
  esac
''
