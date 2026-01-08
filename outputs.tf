output "server_ip_address" {
  description = "The public IPv4 address of the created server"
  value       = module.basic_tailscale_server.ip_address
}

output "server_name" {
  description = "The name of the created server"
  value       = var.server_name
}

output "ingress_endpoint" {
  description = "The configured ingress endpoint for the Restate server"
  value       = var.ingress_endpoint != null ? var.ingress_endpoint : "http://${var.server_name}:8080"
}

output "admin_endpoint" {
  description = "The admin endpoint for the Restate server"
  value       = "http://${var.server_name}:9070"
}