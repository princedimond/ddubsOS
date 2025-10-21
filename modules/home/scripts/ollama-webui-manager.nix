{ pkgs }:

pkgs.writeShellApplication {
  name = "ollama-webui-manager";
  
  runtimeInputs = with pkgs; [
    systemd        # for systemctl
    docker         # for docker commands
    curl           # for API testing
    coreutils      # for basic utilities (du, cut, etc.)
    gnugrep        # for grep
  ];
  
  text = ''
    # OpenWebUI + Ollama Container Management Script
    # Part of ddubsOS - AI/LLM Management Tools

    set -euo pipefail

    # Configuration
    OLLAMA_SERVICE="ollama-docker.service"
    OPENWEBUI_SERVICE="openwebui-docker.service"
    OLLAMA_CONTAINER="ollama"
    OPENWEBUI_CONTAINER="openwebui"
    OLLAMA_PORT="11434"
    OPENWEBUI_PORT="3000"
    DATA_DIR="/var/lib/openwebui-ollama"

    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color

    # Helper functions
    print_header() {
        echo -e "''${CYAN}========================================''${NC}"
        echo -e "''${CYAN} OpenWebUI + Ollama Manager''${NC}"
        echo -e "''${CYAN}========================================''${NC}"
    }

    print_success() {
        echo -e "''${GREEN}✓''${NC} $1"
    }

    print_error() {
        echo -e "''${RED}✗''${NC} $1"
    }

    print_warning() {
        echo -e "''${YELLOW}⚠''${NC} $1"
    }

    print_info() {
        echo -e "''${BLUE}ℹ''${NC} $1"
    }

    check_root() {
        if [[ $EUID -eq 0 ]]; then
            print_error "This script should not be run as root. Run as your regular user."
            exit 1
        fi
    }

    check_sudo() {
        if ! sudo -n true 2>/dev/null; then
            print_info "This operation requires sudo privileges"
            sudo -v
        fi
    }

    get_service_status() {
        local service=$1
        if systemctl is-active --quiet "$service"; then
            echo -e "''${GREEN}running''${NC}"
        elif systemctl is-failed --quiet "$service"; then
            echo -e "''${RED}failed''${NC}"
        else
            echo -e "''${YELLOW}stopped''${NC}"
        fi
    }

    get_container_status() {
        local container=$1
        if docker ps --format "table {{.Names}}" | grep -q "^''${container}$"; then
            echo -e "''${GREEN}running''${NC}"
        elif docker ps -a --format "table {{.Names}}" | grep -q "^''${container}$"; then
            echo -e "''${YELLOW}stopped''${NC}"
        else
            echo -e "''${RED}not found''${NC}"
        fi
    }

    show_status() {
        print_header
        echo
        echo -e "''${CYAN}Services Status:''${NC}"
        echo -e "  Ollama Service:    $(get_service_status $OLLAMA_SERVICE)"
        echo -e "  OpenWebUI Service: $(get_service_status $OPENWEBUI_SERVICE)"
        echo
        echo -e "''${CYAN}Containers Status:''${NC}"
        echo -e "  Ollama Container:    $(get_container_status $OLLAMA_CONTAINER)"
        echo -e "  OpenWebUI Container: $(get_container_status $OPENWEBUI_CONTAINER)"
        echo
        echo -e "''${CYAN}Access Points:''${NC}"
        echo -e "  Ollama API:  http://localhost:''${OLLAMA_PORT}"
        echo -e "  OpenWebUI:   http://localhost:''${OPENWEBUI_PORT}"
        echo
        echo -e "''${CYAN}Data Directory:''${NC}"
        echo -e "  Location: ''${DATA_DIR}"
        if [[ -d "$DATA_DIR" ]]; then
            echo -e "  Size: $(du -sh $DATA_DIR 2>/dev/null | cut -f1 || echo 'Unknown')"
        fi
    }

    start_services() {
        print_info "Starting OpenWebUI + Ollama services..."
        check_sudo
        
        if sudo systemctl start "$OLLAMA_SERVICE"; then
            print_success "Ollama service started"
        else
            print_error "Failed to start Ollama service"
            return 1
        fi
        
        sleep 2
        
        if sudo systemctl start "$OPENWEBUI_SERVICE"; then
            print_success "OpenWebUI service started"
        else
            print_error "Failed to start OpenWebUI service"
            return 1
        fi
        
        print_success "All services started successfully"
    }

    stop_services() {
        print_info "Stopping OpenWebUI + Ollama services..."
        check_sudo
        
        if sudo systemctl stop "$OPENWEBUI_SERVICE"; then
            print_success "OpenWebUI service stopped"
        else
            print_warning "OpenWebUI service may already be stopped"
        fi
        
        if sudo systemctl stop "$OLLAMA_SERVICE"; then
            print_success "Ollama service stopped"
        else
            print_warning "Ollama service may already be stopped"
        fi
        
        print_success "All services stopped"
    }

    restart_services() {
        print_info "Restarting OpenWebUI + Ollama services..."
        check_sudo
        
        sudo systemctl restart "$OLLAMA_SERVICE"
        print_success "Ollama service restarted"
        
        sleep 2
        
        sudo systemctl restart "$OPENWEBUI_SERVICE"
        print_success "OpenWebUI service restarted"
        
        print_success "All services restarted successfully"
    }

    show_logs() {
        local service=''${1:-"both"}
        
        case $service in
            "ollama"|"o")
                print_info "Showing Ollama logs (Ctrl+C to exit)..."
                sudo journalctl -u "$OLLAMA_SERVICE" -f
                ;;
            "webui"|"w"|"ui")
                print_info "Showing OpenWebUI logs (Ctrl+C to exit)..."
                sudo journalctl -u "$OPENWEBUI_SERVICE" -f
                ;;
            "both"|"")
                print_info "Showing both service logs (Ctrl+C to exit)..."
                sudo journalctl -u "$OLLAMA_SERVICE" -u "$OPENWEBUI_SERVICE" -f
                ;;
            *)
                print_error "Invalid log option. Use: ollama, webui, or both"
                return 1
                ;;
        esac
    }

    list_models() {
        print_info "Fetching available models from Ollama..."
        if docker exec "$OLLAMA_CONTAINER" ollama list 2>/dev/null; then
            print_success "Models listed successfully"
        else
            print_error "Failed to list models. Is Ollama running?"
            return 1
        fi
    }

    pull_model() {
        local model=''${1:-""}
        if [[ -z "$model" ]]; then
            print_error "Please specify a model to pull"
            echo "Usage: $0 pull <model_name>"
            echo "Example: $0 pull llama2"
            return 1
        fi
        
        print_info "Pulling model: $model"
        if docker exec -it "$OLLAMA_CONTAINER" ollama pull "$model"; then
            print_success "Model $model pulled successfully"
        else
            print_error "Failed to pull model $model"
            return 1
        fi
    }

    remove_model() {
        local model=''${1:-""}
        if [[ -z "$model" ]]; then
            print_error "Please specify a model to remove"
            echo "Usage: $0 remove <model_name>"
            return 1
        fi
        
        print_warning "This will permanently remove the model: $model"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if docker exec "$OLLAMA_CONTAINER" ollama rm "$model"; then
                print_success "Model $model removed successfully"
            else
                print_error "Failed to remove model $model"
                return 1
            fi
        else
            print_info "Operation cancelled"
        fi
    }

    test_connection() {
        print_info "Testing connections..."
        
        # Test Ollama API
        if curl -s "http://localhost:$OLLAMA_PORT/api/version" > /dev/null; then
            local version
            version=$(curl -s "http://localhost:$OLLAMA_PORT/api/version" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
            print_success "Ollama API responding (version: $version)"
        else
            print_error "Ollama API not responding"
        fi
        
        # Test OpenWebUI
        if curl -s -I "http://localhost:$OPENWEBUI_PORT" | head -1 | grep -q "200 OK"; then
            print_success "OpenWebUI responding"
        else
            print_error "OpenWebUI not responding"
        fi
    }

    show_help() {
        print_header
        echo
        echo -e "''${CYAN}Usage:''${NC}"
        echo "  $0 <command> [options]"
        echo
        echo -e "''${CYAN}Commands:''${NC}"
        echo "  status              Show service and container status"
        echo "  start               Start all services"
        echo "  stop                Stop all services"
        echo "  restart             Restart all services"
        echo "  logs [service]      Show logs (ollama, webui, or both)"
        echo "  models              List downloaded models"
        echo "  pull <model>        Pull/download a model"
        echo "  remove <model>      Remove a model"
        echo "  test                Test API connections"
        echo "  help                Show this help message"
        echo
        echo -e "''${CYAN}Examples:''${NC}"
        echo "  $0 status"
        echo "  $0 start"
        echo "  $0 logs ollama"
        echo "  $0 pull llama2"
        echo "  $0 remove llama2"
        echo
        echo -e "''${CYAN}Access:''${NC}"
        echo "  OpenWebUI: http://localhost:$OPENWEBUI_PORT"
        echo "  Ollama API: http://localhost:$OLLAMA_PORT"
    }

    # Main script logic
    main() {
        check_root
        
        case "''${1:-help}" in
            "status"|"s")
                show_status
                ;;
            "start")
                start_services
                ;;
            "stop")
                stop_services
                ;;
            "restart"|"r")
                restart_services
                ;;
            "logs"|"log"|"l")
                show_logs "''${2:-both}"
                ;;
            "models"|"list"|"ls")
                list_models
                ;;
            "pull"|"download"|"d")
                pull_model "''${2:-}"
                ;;
            "remove"|"rm"|"delete")
                remove_model "''${2:-}"
                ;;
            "test"|"check"|"ping")
                test_connection
                ;;
            "help"|"h"|"--help"|"-h")
                show_help
                ;;
            *)
                print_error "Unknown command: $1"
                echo "Run '$0 help' for usage information."
                exit 1
                ;;
        esac
    }

    # Run main function with all arguments
    main "$@"
  '';
  
  meta = with pkgs.lib; {
    description = "Management script for OpenWebUI and Ollama containers";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
