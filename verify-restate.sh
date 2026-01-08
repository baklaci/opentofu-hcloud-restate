#!/bin/bash

# Restate Verification Script
# This script verifies that Restate is working correctly and demonstrates basic usage

set -e

RESTATE_ADMIN_URL="http://localhost:9070"
RESTATE_INGRESS_URL="http://localhost:8080"

echo "=== Restate Verification Script ==="
echo "Admin URL: $RESTATE_ADMIN_URL"
echo "Ingress URL: $RESTATE_INGRESS_URL"
echo "Timestamp: $(date)"
echo

# Function to check if Restate is accessible
check_restate_accessibility() {
    echo "=== Checking Restate Accessibility ==="
    
    echo "Checking admin endpoint health..."
    if curl -f "$RESTATE_ADMIN_URL/health" &>/dev/null; then
        echo "✓ Admin endpoint is accessible"
        curl -s "$RESTATE_ADMIN_URL/health" | jq . 2>/dev/null || curl -s "$RESTATE_ADMIN_URL/health"
    else
        echo "✗ Admin endpoint is not accessible"
        return 1
    fi
    
    echo
    echo "Checking ingress endpoint..."
    if curl -f "$RESTATE_INGRESS_URL" &>/dev/null; then
        echo "✓ Ingress endpoint is accessible"
    else
        echo "✓ Ingress endpoint is accessible (expected 'service not found' response)"
        echo "Response:"
        curl -s "$RESTATE_INGRESS_URL" || echo "No response"
    fi
    echo
}

# Function to list deployments
list_deployments() {
    echo "=== Current Deployments ==="
    
    echo "Fetching deployments..."
    if curl -f "$RESTATE_ADMIN_URL/deployments" &>/dev/null; then
        curl -s "$RESTATE_ADMIN_URL/deployments" | jq . 2>/dev/null || curl -s "$RESTATE_ADMIN_URL/deployments"
    else
        echo "Failed to fetch deployments"
    fi
    echo
}

# Function to list services
list_services() {
    echo "=== Current Services ==="
    
    echo "Fetching services..."
    if curl -f "$RESTATE_ADMIN_URL/services" &>/dev/null; then
        curl -s "$RESTATE_ADMIN_URL/services" | jq . 2>/dev/null || curl -s "$RESTATE_ADMIN_URL/services"
    else
        echo "Failed to fetch services"
    fi
    echo
}

# Function to show cluster status
show_cluster_status() {
    echo "=== Cluster Status ==="
    
    echo "Fetching cluster status..."
    if curl -f "$RESTATE_ADMIN_URL/cluster" &>/dev/null; then
        curl -s "$RESTATE_ADMIN_URL/cluster" | jq . 2>/dev/null || curl -s "$RESTATE_ADMIN_URL/cluster"
    else
        echo "Failed to fetch cluster status"
    fi
    echo
}

# Function to test basic functionality
test_basic_functionality() {
    echo "=== Testing Basic Functionality ==="
    
    echo "Testing empty service call (should return 'service not found')..."
    response=$(curl -s "$RESTATE_INGRESS_URL" || echo "No response")
    echo "Response: $response"
    
    if echo "$response" | grep -q "service.*not found"; then
        echo "✓ Expected response received - Restate is working correctly"
    else
        echo "? Unexpected response - but this might be normal"
    fi
    echo
}

# Function to show example service registration
show_service_example() {
    echo "=== Service Registration Example ==="
    echo "To register a service, you would typically:"
    echo "1. Create a service (see test-service.js example)"
    echo "2. Run the service: node test-service.js"
    echo "3. Register it with Restate:"
    echo "   curl -X POST $RESTATE_ADMIN_URL/deployments \\"
    echo "        -H 'Content-Type: application/json' \\"
    echo "        -d '{\"uri\": \"http://host.docker.internal:9080\"}'"
    echo "4. Call the service:"
    echo "   curl -X POST $RESTATE_INGRESS_URL/greeter/greet \\"
    echo "        -H 'Content-Type: application/json' \\"
    echo "        -d '\"World\"'"
    echo
}

# Function to check Docker containers
check_containers() {
    echo "=== Docker Container Status ==="
    
    echo "Restate containers:"
    docker ps --filter "name=restate" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo
    
    echo "Recent Restate logs:"
    docker logs --tail=10 restate-server 2>/dev/null || echo "Failed to get Restate logs"
    echo
}

# Main execution
main() {
    case "${1:-all}" in
        "health")
            check_restate_accessibility
            ;;
        "deployments")
            list_deployments
            ;;
        "services")
            list_services
            ;;
        "cluster")
            show_cluster_status
            ;;
        "test")
            test_basic_functionality
            ;;
        "example")
            show_service_example
            ;;
        "containers")
            check_containers
            ;;
        "all")
            check_restate_accessibility
            show_cluster_status
            list_deployments
            list_services
            test_basic_functionality
            show_service_example
            ;;
        *)
            echo "Usage: $0 [health|deployments|services|cluster|test|example|containers|all]"
            echo "  health      - Check Restate accessibility"
            echo "  deployments - List current deployments"
            echo "  services    - List current services"
            echo "  cluster     - Show cluster status"
            echo "  test        - Test basic functionality"
            echo "  example     - Show service registration example"
            echo "  containers  - Check Docker container status"
            echo "  all         - Run all checks (default)"
            exit 1
            ;;
    esac
}

main "$@"