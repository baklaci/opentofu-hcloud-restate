variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "tailscale_api_key" {
  description = "Tailscale API key"
  type        = string
  sensitive   = true
}

variable "tailscale_tailnet" {
  description = "Tailscale tailnet name"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key in Hetzner Cloud"
  type        = string
}

variable "server_name" {
  description = "Name of the server instance"
  type        = string
}

variable "user_name" {
  description = "Name of the user account created as administrative on the server"
  type        = string
}

variable "private_ssh_key" {
  description = "Private key to access the server"
  type        = string
}