# 🚀 REDCap Automated Deployment using Terraform & Ansible on AWS EC2

This is a hands-on DevOps lab project where I provisioned a complete 3-tier architecture on AWS using **Terraform** and automated the deployment of **REDCap**, a secure web app for research data collection, using **Ansible**.

The infrastructure includes:
- A **public subnet** with an Ansible Controller and Web Server
- A **private subnet** for a secured MariaDB Database Server
- Automated deployment of REDCap and configuration of Apache, PHP, MariaDB
- Application-to-database connectivity test
- A dummy cron job setup to simulate scheduled tasks

This project simulates real-world Infrastructure as Code (IaC) and Configuration Management in a structured, production-style format — designed for learning, portfolio presentation, and demonstration.
