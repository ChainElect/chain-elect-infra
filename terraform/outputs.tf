output "backend_ip" {
  value = digitalocean_droplet.backend.ipv4_address
}

output "frontend_ip" {
  value = digitalocean_droplet.frontend.ipv4_address
}

output "database_uri" {
  value = digitalocean_database_cluster.postgres.uri
  sensitive = true
}