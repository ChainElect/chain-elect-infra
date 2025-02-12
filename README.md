# 🚀 ChainElect Infrastructure

[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%203.svg)](https://www.digitalocean.com/?refcode=cc9395b29763&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)

## 📌 Overview

**ChainElect** is a **secure, blockchain-powered e-voting system** that ensures **transparency, integrity, and verifiability** in elections.  
This repository contains **Infrastructure as Code (IaC)** for deploying the **ChainElect backend, frontend, and database** on **DigitalOcean** using **Terraform** and **Ansible**.

## 🏗️ Infrastructure Setup

The infrastructure is **fully automated** using:

- **Terraform** → Manages DigitalOcean resources like Droplets, Load Balancer, VPC, and Database.
- **Ansible** → Configures servers, installs dependencies, and deploys the application.
- **GitHub Actions CI/CD** → Automates infrastructure deployment when updates are pushed.

## 📂 Repository Structure

```sh
chain-elect-infra/
│── terraform/             # Terraform configuration for DigitalOcean
│   ├── main.tf            # Defines resources (Droplets, Load Balancer, DB)
│   ├── variables.tf       # Input variables for Terraform
│   ├── provider.tf        # DigitalOcean provider configuration
│   ├── outputs.tf         # Terraform outputs (IP addresses, DB URIs)
│   ├── terraform.tfvars   # Stores sensitive Terraform variables (not committed)
│── ansible/               # Ansible playbooks for server provisioning
│   ├── setup.yaml         # Installs Docker, configures services
│   ├── inventory.ini      # Defines DigitalOcean hosts
│── ci-cd/                 # GitHub Actions for automatic deployments
│   ├── terraform-deploy.yaml  # CI/CD workflow to run Terraform
│── networking/            # Networking configurations (VPC, Firewall)
│── LICENSE                # Open-source licensing information
```

## 🌍 DigitalOcean Infrastructure

```
Component	Technology	Description
Compute	Droplets	Backend & Frontend servers
Networking	Load Balancer, VPC, Firewall	Secure application networking
Database	PostgreSQL	Stores user credentials & voting data
Storage	Block Storage	Data persistence for the database
Deployment	Docker, CI/CD	Automates deployment & scaling
```

## 🚀 Deployment Guide

1️⃣ Clone the Repository

```sh
git clone https://github.com/ChainElect/chain-elect-infra.git
cd chain-elect-infra
```

2️⃣ Set Up Terraform

```sh
cd terraform
terraform init
terraform validate
terraform apply -auto-approve
```

3️⃣ Set Up Ansible

```sh
cd ansible
ansible-playbook -i inventory.ini setup.yaml
```

4️⃣ Verify Deployment
• Check DigitalOcean Dashboard to confirm infrastructure is running.
• Use terraform output to get public IPs.

## 🔐 Environment Variables

	•	Check DigitalOcean Dashboard to confirm infrastructure is running.
	•	Use terraform output to get public IPs.
Before running Terraform, ensure you have the required secrets in GitHub Actions or your local environment:

```sh
export TF_VAR_do_token="your-digitalocean-api-token"
export TF_VAR_ssh_key_fingerprint="your-ssh-key-fingerprint"
```

## 🔄 Continuous Deployment (CI/CD)

    •	GitHub Actions automatically applies Terraform changes when updates are pushed.
    •	Docker images are built and deployed using CI/CD workflows.

## 📜 License

This project is licensed under the MIT License.
