terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# VPC Network
resource "digitalocean_vpc" "voting_vpc" {
  name   = "voting-vpc"
  region = var.region
}

# Backend Droplet (Cheapest Plan)
resource "digitalocean_droplet" "backend" {
  image    = "ubuntu-22-04-x64"
  name     = "chain-elect-backend"
  region   = var.region
  size     = "s-1vcpu-1gb"
  vpc_uuid = digitalocean_vpc.voting_vpc.id
  ssh_keys = [var.ssh_key_fingerprint]
}

# Frontend Droplet (Cheapest Plan)
resource "digitalocean_droplet" "frontend" {
  image    = "ubuntu-22-04-x64"
  name     = "chain-elect-frontend"
  region   = var.region
  size     = "s-1vcpu-1gb"
  vpc_uuid = digitalocean_vpc.voting_vpc.id
  ssh_keys = [var.ssh_key_fingerprint]
}

# PostgreSQL Database
resource "digitalocean_database_cluster" "postgres" {
  name       = "chainelect-db"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1
}

# Storage Volume for PostgreSQL
resource "digitalocean_volume" "db_volume" {
  region = var.region
  name   = "db-storage"
  size   = 20 # GB
}

# Load Balancer
resource "digitalocean_loadbalancer" "lb" {
  name   = "voting-lb"
  region = var.region
  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"
    target_port    = 80
    target_protocol = "http"
  }
  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"
    target_port    = 443
    target_protocol = "https"
  }
  healthcheck {
    port     = 80
    protocol = "http"
    path     = "/health"
  }
}

# Firewall
resource "digitalocean_firewall" "fw" {
  name = "voting-firewall"
  droplet_ids = [
    digitalocean_droplet.backend.id,
    digitalocean_droplet.frontend.id
  ]
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["your-ip-address/32"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0"]
  }
}