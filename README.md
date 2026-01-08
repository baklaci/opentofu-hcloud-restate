# Opentofu Hetzner Cloud Restate Module

This Opentofu module deploys a Restate server on Hetzner Cloud with Tailscale integration. Clone of [terraform-hcloud-restate](https://github.com/sprantic/terraform-hcloud-restate)

## Overview

This module creates:

- A Hetzner Cloud server with Ubuntu 22.04
- Tailscale integration for secure networking
- Docker Compose setup with Restate and etcd
- Automated deployment and health checking

## Quick Start

1. Edit `restate-server/terraform.tfvars` with your values:

   - Hetzner Cloud API token
   - Tailscale API key and tailnet
   - SSH key name and path
   - Server configuration

2. Deploy:
   ```bash
   cd restate-server
   tofu init
   tofu plan
   tofu apply
   <!-- tofu destroy -->
   ```

## Configuration

### Required Variables

- `hcloud_token`: Hetzner Cloud API token
- `tailscale_api_key`: Tailscale API key
- `tailscale_tailnet`: Your Tailscale tailnet name
- `ssh_key_name`: SSH key name in Hetzner Cloud
- `server_name`: Name for the server instance
- `user_name`: Administrative user name
- `private_ssh_key`: Path to SSH private key

### Optional Variables

- `deploy_docker_compose`: Whether to deploy Docker Compose (default: true)
- `docker_compose_path`: Deployment path on server (default: "/opt/restate")
- `ssh_private_key_path`: SSH private key path (default: "~/.ssh/id_rsa")
- `ingress_endpoint`: The ingress endpoint URL for Restate server (default: "http://{server_name}:8080")

## Troubleshooting

### Common Issues and Solutions

#### 1. Restate Server Connection Issues

**Problem**: Restate server fails to connect to etcd metadata store.

**Symptoms**:

- Logs show "Failed to join the cluster 'single-node'"
- Connection errors to `127.0.0.1:5122` or similar
- Server keeps restarting

**Solution**: The module includes several fixes:

- Proper service dependency management
- Health checks for etcd before starting Restate
- Explicit configuration file to override defaults
- Extended startup timeouts

#### 2. Using the Troubleshooting Script

```
Outputs:

admin_endpoint = "http://test:9070"
ingress_endpoint = "http://test:8080"
server_ip_address = "46.224.203.77"
server_name = "test"
```

`sudo ssh -i ~/.ssh/id_ed25519 'root@test'`

A troubleshooting script is automatically deployed to `/opt/restate/troubleshoot-restate.sh`:

```bash
# Check service status
./troubleshoot-restate.sh status

# View recent logs
./troubleshoot-restate.sh logs

# Check service health
./troubleshoot-restate.sh health

# Restart services
./troubleshoot-restate.sh restart

# Run all checks
./troubleshoot-restate.sh full

# Attempt automatic fix
./troubleshoot-restate.sh fix
```

#### 3. Manual Troubleshooting

If the automatic fixes don't work:

1. **Check Docker Compose status**:

   ```bash
   cd /opt/restate
   sudo docker compose ps
   ```

2. **View logs**:

   ```bash
   sudo docker compose logs etcd
   sudo docker compose logs restate
   ```

3. **Restart services**:

   ```bash
   sudo docker compose down
   sudo docker compose up -d
   ```

4. **Check etcd health**:

   ```bash
   sudo docker compose exec etcd etcdctl --endpoints=http://localhost:2379 endpoint health
   ```

5. **Check Restate health**:
   ```bash
   curl http://localhost:9070/health
   ```

#### 4. Network Issues

If services can't communicate:

1. **Check Docker network**:

   ```bash
   sudo docker network ls
   sudo docker network inspect restate_restate-network
   ```

2. **Verify container connectivity**:
   ```bash
   sudo docker compose exec restate ping etcd
   ```

#### 5. Configuration Issues

The module deploys a custom `restate.toml` configuration file that:

- Explicitly sets the etcd address
- Configures proper timeouts
- Sets cluster parameters
- Configures the ingress endpoint based on server name

If you need to modify the configuration:

1. Edit `/opt/restate/restate.toml`
2. Restart services: `sudo docker compose restart restate`

## Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Restate       │    │      etcd       │
│   Server        │◄──►│  (Metadata)     │
│   :8080, :9070  │    │     :2379       │
└─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────┐
│   Tailscale     │
│   Network       │
└─────────────────┘
```

## Services

- **Restate Server**: Main application server
  - Port 8080: Ingress API
  - Port 9070: Admin API
- **etcd**: Metadata store for cluster coordination
  - Port 2379: Client API
- **Tailscale**: Secure networking overlay

## Files Deployed

- `docker-compose.yml`: Service definitions
- `restate.toml`: Restate configuration
- `troubleshoot-restate.sh`: Troubleshooting script

## Security

- Server is accessible via Tailscale network
- SSH access with key-based authentication
- Docker containers run with restart policies
- Health checks ensure service availability

## Monitoring

Check service health:

```bash
# Restate health endpoint
curl http://your-server:9070/health

# Via Tailscale
curl http://your-tailscale-hostname:9070/health
```

## Support

For issues:

1. Run the troubleshooting script
2. Check the logs
3. Verify network connectivity
4. Review the configuration files

## License

This module is provided as-is for educational and development purposes.
