# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# Configure the Tailscale Provider
provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailscale_tailnet
}

module "terraform-hcloud-restate" {
  source = "../"
  server_name          = var.server_name
  user_name            = var.user_name
  tailscale_api_key    = var.tailscale_api_key
  tailscale_tailnet    = var.tailscale_tailnet
  ssh_key_name         = var.ssh_key_name
  ssh_private_key_path = var.private_ssh_key
}

output "server_ip_address" {
  description = "The public IPv4 address of the created server"
  value       = module.terraform-hcloud-restate.server_ip_address
}

output "server_name" {
  description = "The name of the created server"
  value       = module.terraform-hcloud-restate.server_name
}

output "ingress_endpoint" {
  description = "The configured ingress endpoint for the Restate server"
  value       = module.terraform-hcloud-restate.ingress_endpoint
}

output "admin_endpoint" {
  description = "The admin endpoint for the Restate server"
  value       = module.terraform-hcloud-restate.admin_endpoint
}