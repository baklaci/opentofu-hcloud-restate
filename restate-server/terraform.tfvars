# Hetzner Cloud API token
# Get this from: https://console.hetzner.cloud/projects
#set to env with the name TF_VAR_hcloud_token for a more secure approach.
# hcloud_token = ""


# SSH key name in Hetzner Cloud
# Upload your SSH key first at: https://console.hetzner.cloud/projects
ssh_key_name = "id_rsa.pub"

# Tailscale API key
# Get this from: https://login.tailscale.com/admin/settings/keys
# set to env with the name TF_VAR_tailscale_api_key for a more secure approach.
# tailscale_api_key = ""

# Tailscale tailnet name
# This is usually your organization name or email domain
tailscale_tailnet = "tailscale.name"

# Server name for the Restate instance
server_name = "test"

# Username for the administrative account on the server
user_name = "admin"

# Optional: Override the ingress endpoint (defaults to http://{server_name}:8080)
# ingress_endpoint = "http://example-restate:8080"

private_ssh_key = "~/.ssh/id_rsa"
