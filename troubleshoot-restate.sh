#!/bin/bash

# Restate Troubleshooting Script
# This script helps diagnose and fix common Restate deployment issues

set -e

COMPOSE_PATH="/opt/restate"
LOG_LINES=50

echo "=== Restate Troubleshooting Script ==="
echo "Compose path: $COMPOSE_PATH"
echo "Timestamp: $(date)"
echo

# Function to check if docker compose is available
check_docker_compose() {
    if docker compose version &> /dev/null; then
        echo "✓ Docker Compose is available"
        docker compose version
        return 0
    elif command -v "docker-compose" &> /dev/null; then
        echo "✓ Docker Compose (legacy) is available"
        docker-compose --version
        return 0
    else
        echo "✗ Docker Compose is not available"
        return 1
    fi
}

# Function to check service status
check_services() {
    echo "=== Service Status ==="
    cd "$COMPOSE_PATH"
    
    if sudo docker compose ps; then
        echo "✓ Services status retrieved"
    else
        echo "✗ Failed to get services status"
        return 1
    fi
    echo
}

# Function to show logs
show_logs() {
    echo "=== Recent Logs ==="
    cd "$COMPOSE_PATH"
    
    echo "--- etcd logs ---"
    sudo docker compose logs --tail=$LOG_LINES etcd || echo "Failed to get etcd logs"
    echo
    
    echo "--- restate logs ---"
    sudo docker compose logs --tail=$LOG_LINES restate || echo "Failed to get restate logs"
    echo
}

# Function to restart services
restart_services() {
    echo "=== Restarting Services ==="
    cd "$COMPOSE_PATH"
    
    echo "Stopping services..."
    sudo docker compose down
    
    echo "Removing orphaned containers..."
    sudo docker compose down --remove-orphans
    
    echo "Pulling latest images..."
    sudo docker compose pull
    
    echo "Starting services..."
    sudo docker compose up -d
    
    echo "Waiting for services to start..."
    sleep 15
    
    echo "Checking service status..."
    sudo docker compose ps
}

# Function to check etcd health
check_etcd_health() {
    echo "=== Checking etcd Health ==="
    
    # Wait for etcd to be ready
    echo "Waiting for etcd to be ready..."
    for i in {1..30}; do
        if sudo docker compose exec etcd etcdctl --endpoints=http://localhost:2379 endpoint health &>/dev/null; then
            echo "✓ etcd is healthy"
            
            # Check etcd status
            echo "etcd status:"
            sudo docker compose exec etcd etcdctl --endpoints=http://localhost:2379 endpoint status --write-out=table || echo "Failed to get etcd status"
            
            # Check etcd member list
            echo "etcd members:"
            sudo docker compose exec etcd etcdctl --endpoints=http://localhost:2379 member list --write-out=table || echo "Failed to get etcd members"
            
            return 0
        fi
        echo "Attempt $i/30: etcd not ready yet..."
        sleep 2
    done
    
    echo "✗ etcd health check failed"
    return 1
}

# Function to check restate health
check_restate_health() {
    echo "=== Checking Restate Health ==="
    
    # Wait for restate to be ready
    echo "Waiting for Restate to be ready..."
    for i in {1..60}; do
        if curl -f http://localhost:9070/health &>/dev/null; then
            echo "✓ Restate is healthy"
            return 0
        fi
        echo "Attempt $i/60: Restate not ready yet..."
        sleep 2
    done
    
    echo "✗ Restate health check failed"
    return 1
}

# Function to check docker environment
check_docker_environment() {
    echo "=== Checking Docker Environment ==="
    
    echo "Docker version:"
    docker --version || echo "✗ Docker not available"
    
    echo "Docker Compose version:"
    docker compose version || docker-compose --version || echo "✗ Docker Compose not available"
    
    echo "Available images:"
    docker images | grep -E "(restate|etcd)" || echo "No Restate/etcd images found"
    
    echo "Running containers:"
    docker ps --filter "name=restate" || echo "No Restate containers running"
    
    echo "All containers:"
    docker ps -a || echo "Failed to list containers"
    
    echo "Docker networks:"
    docker network ls | grep restate || echo "No Restate networks found"
    
    echo
}

# Main execution
main() {
    case "${1:-status}" in
        "status")
            check_docker_compose
            check_services
            ;;
        "logs")
            show_logs
            ;;
        "restart")
            restart_services
            ;;
        "health")
            check_etcd_health
            check_restate_health
            ;;
        "full")
            check_docker_compose
            check_docker_environment
            check_services
            show_logs
            check_etcd_health
            check_restate_health
            ;;
        "fix")
            echo "Attempting to fix Restate deployment..."
            restart_services
            check_etcd_health
            check_restate_health
            ;;
        "docker")
            check_docker_environment
            ;;
        *)
            echo "Usage: $0 [status|logs|restart|health|full|fix|docker]"
            echo "  status  - Show service status"
            echo "  logs    - Show recent logs"
            echo "  restart - Restart all services"
            echo "  health  - Check service health"
            echo "  docker  - Check Docker environment"
            echo "  full    - Run all checks"
            echo "  fix     - Attempt to fix issues"
            exit 1
            ;;
    esac
}

main "$@"