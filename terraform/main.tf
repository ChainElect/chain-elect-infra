###################################################
# Terraform Configuration
###################################################
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

###################################################
# VPC Network
###################################################
# resource "digitalocean_vpc" "vpc" {
#   name   = "dev-vpc"
#   region = var.region
# }

########################################
# Load Balancer
########################################
# resource "digitalocean_loadbalancer" "lb" {
#   name   = "dev-lb"
#   region = var.region

# For frontend traffic
# forwarding_rule {
#   entry_protocol  = "tcp"
#   entry_port      = 443
#   target_protocol = "tcp"
#   target_port     = 443
# }

# Health check (example)
# healthcheck {
#   protocol                 = "http"
#   port                     = var.port
#   path                     = "/health"
#   check_interval_seconds   = 10
#   response_timeout_seconds = 5
#   healthy_threshold        = 3
#   unhealthy_threshold      = 3
# }

# Attach both droplets
#   droplet_ids = [
#     digitalocean_droplet.droplet_nginx.id,
#   ]
# }

########################################
# 1) Nginx Droplet (Gateway)
########################################
resource "digitalocean_droplet" "droplet_nginx" {
  image    = "ubuntu-22-04-x64"
  name     = "dev-nginx"
  region   = var.region
  size     = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_key_fingerprint]

  user_data = templatefile("${path.module}/user_data/nginx.sh", {
    FRONTEND_IP = digitalocean_droplet.droplet_frontend.ipv4_address_private
    BACKEND_IP  = digitalocean_droplet.droplet_backend.ipv4_address_private
  })
}

########################################
# 2) Frontend Droplet
########################################
resource "digitalocean_droplet" "droplet_frontend" {
  image    = "ubuntu-22-04-x64"
  name     = "dev-frontend"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [var.ssh_key_fingerprint]

  user_data = file("${path.module}/user_data/frontend-cloud-config.yaml")
}

########################################
# 3) Backend Droplet
########################################
resource "digitalocean_droplet" "droplet_backend" {
  image    = "ubuntu-22-04-x64"
  name     = "dev-backend"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [var.ssh_key_fingerprint]

  # We'll do placeholder replacement in backend.sh
  user_data = templatefile(
    "${path.module}/user_data/backend-cloud-config.yaml",
    {
      PORT         = var.port,
      DB_URL       = var.db_url,
      JWT_SECRET   = var.jwt_secret,
      ALG          = var.hashing_algorithm,
      FRONT_ORIGIN = var.frontend_origin,
      SENTRY_DSN   = var.sentry_dsn,
      NODE_ENV     = var.node_env
    }
  )
}

###################################################
# PostgreSQL Database Cluster
###################################################
resource "digitalocean_database_cluster" "db" {
  name       = "dev-db"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1
}

###################################################
# Storage Volume for PostgreSQL (Optional)
###################################################
resource "digitalocean_volume" "db_volume" {
  region = var.region
  name   = "dev-db-volume"
  size   = 20
}
###################################################
# DigitalOcean Domain (No IP - Just registers the domain)
###################################################
resource "digitalocean_domain" "chainelect" {
  name = "chainelect.org" # No `ip_address` here
}

###################################################
# DNS Records (All managed explicitly)
###################################################
# Root domain (@)
resource "digitalocean_record" "root" {
  domain = digitalocean_domain.chainelect.name
  type   = "A"
  name   = "@"
  value  = digitalocean_droplet.droplet_nginx.ipv4_address
  ttl    = 300 # 5-minute TTL for faster updates
}

# www subdomain
resource "digitalocean_record" "www" {
  domain = digitalocean_domain.chainelect.name
  type   = "A"
  name   = "www"
  value  = digitalocean_droplet.droplet_nginx.ipv4_address
  ttl    = 300
}

# api subdomain
resource "digitalocean_record" "api" {
  domain = digitalocean_domain.chainelect.name
  type   = "A"
  name   = "api"
  value  = digitalocean_droplet.droplet_nginx.ipv4_address
  ttl    = 300
}
