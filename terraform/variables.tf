variable "do_token" {
  type        = string
  description = "Your DigitalOcean API token"
}

variable "region" {
  type        = string
  default     = "ams3"
  description = "Region where resources will be created"
}

variable "ssh_key_fingerprint" {
  type        = string
  description = "Fingerprint of the SSH key for droplet access"
}

variable "jwt_secret" {
  description = "JWT secret for signing tokens"
  type        = string
}

variable "db_url" {
  description = "Database connection string"
  type        = string
}

variable "hashing_algorithm" {
  description = "Algorithm used for hashing"
  type        = string
  default     = "HS256"
}

variable "frontend_origin" {
  description = "Frontend URL that is allowed to access the backend"
  type        = string
}

variable "sentry_dsn" {
  description = "Sentry DSN for error tracking"
  type        = string
}

variable "node_env" {
  description = "Node environment (production, development, etc.)"
  type        = string
  default     = "production"
}

variable "port" {
  description = "backend port"
  type        = string
  default     = "5001"
}
