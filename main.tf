module "basic_tailscale_server" {
  source = "sprantic/tailscale-server/hcloud"
  version = "v1.1.0"
  server_name       = var.server_name
  username          = var.user_name
  image             = "ubuntu-24.04"
  server_type       = "cx23"
  location          = "nbg1"
  ssh_keys          = [var.ssh_key_name]
  tailscale_api_key = var.tailscale_api_key
  tailscale_tailnet = var.tailscale_tailnet
}

# Create directory for Restate on the server
resource "null_resource" "create_restate_directory" {
  count = var.deploy_docker_compose ? 1 : 0
  
  depends_on = [module.basic_tailscale_server]
  
  connection {
    type        = "ssh"
    host        = var.server_name
    user        = var.user_name
    private_key = file(var.ssh_private_key_path)
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${var.docker_compose_path}",
      "sudo mkdir -p ${var.docker_compose_path}/config",
      "sudo chown -R ${var.user_name}:${var.user_name} ${var.docker_compose_path}"
    ]
  }
}

# Deploy Docker Compose file to the server
resource "null_resource" "deploy_docker_compose" {
  count = var.deploy_docker_compose ? 1 : 0
  
  depends_on = [resource.null_resource.create_restate_directory]
  
  connection {
    type        = "ssh"
    host        = var.server_name
    user        = var.user_name
    private_key = file(var.ssh_private_key_path)
  }
  
  provisioner "file" {
    content = templatefile("${path.module}/docker-compose.yml", {
      ingress_endpoint = var.ingress_endpoint != null ? var.ingress_endpoint : "http://${var.server_name}:8080"
      kafka_enabled = var.enable_kafka_integration
      kafka_servers = join(",", var.kafka_bootstrap_servers)
      kafka_replication_factor = var.kafka_replication_factor
      kafka_topic_prefix = var.kafka_topic_prefix
    })
    destination = "${var.docker_compose_path}/docker-compose.yml"
  }
  
  
  provisioner "file" {
    content = templatefile("${path.module}/restate.toml", {
      ingress_endpoint = var.ingress_endpoint != null ? var.ingress_endpoint : "http://${var.server_name}:8080"
      kafka_enabled = var.enable_kafka_integration
      kafka_servers = var.kafka_bootstrap_servers
      kafka_cluster_name = var.kafka_cluster_name
      kafka_replication_factor = var.kafka_replication_factor
      kafka_topic_prefix = var.kafka_topic_prefix
    })
    destination = "${var.docker_compose_path}/restate.toml"
  }
  
  provisioner "file" {
    source      = "${path.module}/troubleshoot-restate.sh"
    destination = "${var.docker_compose_path}/troubleshoot-restate.sh"
  }
  
  provisioner "file" {
    source      = "${path.module}/verify-restate.sh"
    destination = "${var.docker_compose_path}/verify-restate.sh"
  }
  
  provisioner "file" {
    source      = "${path.module}/test-service.js"
    destination = "${var.docker_compose_path}/test-service.js"
  }
  
  provisioner "file" {
    source      = "${path.module}/package.json"
    destination = "${var.docker_compose_path}/package.json"
  }
  
  provisioner "remote-exec" {
    inline = [
      "cd ${var.docker_compose_path}",
      "sudo usermod -aG docker ${var.user_name}",
      "chmod +x troubleshoot-restate.sh",
      "chmod +x verify-restate.sh",
      "sudo docker compose down || true",
      "sudo docker compose pull",
      "sleep 5",
      "sudo docker compose up -d",
      "echo 'Waiting for services to start...'",
      "sleep 20",
      "echo 'Running health check...'",
      "./troubleshoot-restate.sh health || echo 'Initial health check failed - services may still be starting'",
      "echo 'Running verification...'",
      "./verify-restate.sh health || echo 'Initial verification failed - services may still be starting'"
    ]
  }
}
