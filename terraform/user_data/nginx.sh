#!/bin/bash

###############################################################################
# Noninteractive APT settings to avoid prompts
###############################################################################
export DEBIAN_FRONTEND=noninteractive

# Keep existing config files if there's a conflict
apt-get update -y
apt-get upgrade -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold"

###############################################################################
# Install required packages (Nginx + Certbot)
###############################################################################
apt-get install -y nginx certbot python3-certbot-nginx

systemctl enable nginx
systemctl start nginx

###############################################################################
# Obtain SSL Certificates for chainelect.org
###############################################################################
# Single-line command so it doesn't parse incorrectly
certbot --nginx \
  -d chainelect.org \
  -d www.chainelect.org \
  -d api.chainelect.org \
  --agree-tos \
  --no-eff-email \
  -m your_email@domain.com \
  --non-interactive

###############################################################################
# Write Custom Nginx Config
###############################################################################
cat > /etc/nginx/sites-available/chainelect.conf <<EOF
server {
    listen 80;
    server_name chainelect.org www.chainelect.org api.chainelect.org;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name chainelect.org www.chainelect.org;

    ssl_certificate     /etc/letsencrypt/live/chainelect.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/chainelect.org/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://${FRONTEND_IP}:80;
        proxy_http_version 1.1;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

server {
    listen 443 ssl;
    server_name api.chainelect.org;

    ssl_certificate     /etc/letsencrypt/live/chainelect.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/chainelect.org/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://${BACKEND_IP}:5001;
        proxy_http_version 1.1;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        add_header 'Access-Control-Allow-Origin' 'https://chainelect.org' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization' always;
    }
}
EOF

# Remove the default config and enable our new site
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/chainelect.conf /etc/nginx/sites-enabled/chainelect.conf

# Test and reload
nginx -t
systemctl reload nginx