terraform {
  backend "local" {}
}

provider "digitalocean" {
  token = var.do_token
}
