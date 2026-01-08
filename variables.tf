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

variable "deploy_docker_compose" {
  description = "Whether to deploy the Docker Compose file for Restate server"
  type        = bool
  default     = true
}

variable "docker_compose_path" {
  description = "Path where to deploy the Docker Compose file on the server"
  type        = string
  default     = "/opt/restate"
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ingress_endpoint" {
  description = "The ingress endpoint URL for Restate server"
  type        = string
  default     = null
}

# Kafka Integration Variables
variable "kafka_bootstrap_servers" {
  description = "Kafka bootstrap servers for Restate integration"
  type        = list(string)
  default     = []
}

variable "kafka_cluster_name" {
  description = "name for kafka subscriptions"
  type        = string
  default     = "kafka_cluster_name"
}

variable "enable_kafka_integration" {
  description = "Enable Kafka integration for Restate"
  type        = bool
  default     = false
}

variable "kafka_replication_factor" {
  description = "Kafka replication factor for Restate topics"
  type        = number
  default     = 3
}

variable "kafka_topic_prefix" {
  description = "Prefix for Kafka topics used by Restate"
  type        = string
  default     = "restate-events"
}