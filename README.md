# 🚀 REDCap Automated Deployment using Terraform & Ansible on AWS

This is a hands-on DevOps lab project where I automated the deployment of a REDCap server infrastructure using **Terraform** and **Ansible** on **AWS EC2 instances**. The goal was to replicate a real-world setup used in NHS environments, enabling modular and repeatable infrastructure builds with full automation.

> ✅ Fully automated from provisioning to REDCap configuration.
> ✅ Based on real infrastructure used in research and clinical environments.
> ✅ Built for learning and showcasing DevOps automation

---

## ⚙️ Tools & Technologies Used

| Tool              | Purpose                                             |
| ----------------- | --------------------------------------------------- |
| Terraform         | Provision EC2, VPC, subnets, and security groups    |
| Ansible           | Configure software on EC2 (Apache, MariaDB, REDCap) |
| AWS EC2 (Ubuntu)  | Host REDCap app and database                        |
| Apache Web Server | Serve the REDCap frontend                           |
| MariaDB           | REDCap database backend                             |
| SSH               | Remote login and secure configuration               |
| Git & GitHub      | Version control and documentation                   |
| Postfix + CRON    | Email simulation and task automation                |

---

## 🗂 Project Folder Structure

```bash
redcap-auto-deploy/
├── terraform/              # Infrastructure as Code
│   ├── main.tf             # VPC, Subnet, Route Table, IGW, EC2
│   ├── variables.tf        # Variables like AMI, instance type
│   ├── output.tf           # Outputs like IP addresses
│   ├── terraform.tfstate   # State tracking
│   └── terraform.tfstate.backup
│
├── redcap-ansible/         # Configuration management
│   ├── inventory.ini       # Ansible inventory
│   ├── site.yml            # Entry point for Ansible playbooks
│   └── roles/
│       ├── web/            # Web server setup
│       │   ├── tasks/main.yml
│       │   └── templates/
│       │       ├── 000-default.conf.j2
│       │       ├── database.php.j2
│       │       ├── check_db.php.j2
│       │       └── cron.sh.j2
│       └── database/       # MariaDB setup
│           └── tasks/main.yml
│
├── redcap-build/           # REDCap app package
│   ├── redcap10.0.26.zip   # Application zip
│   └── redcap/             # Unzipped dummy frontend
│
├── README.md ✅
└── LICENSE (optional)
```

---

## 🗺 Architecture Diagram

![REDCap Infra Diagram](images/archi-diagram.png)

* **Terraform** provisions a VPC, public/private subnets, internet gateway, route table, and 3 EC2 instances.
* **Ansible** configures the web server, database server, and controller.
* The web server is publicly accessible, database is private.
* All communication between nodes is done over SSH.

---

## 🎯 Project Goal

Automate the provisioning and configuration of REDCap — a research-focused application — using IaC and config management tools. The project simulates NHS deployment models using production-style practices.

---

## ✅ Pre-Requisites

* AWS Account
* Access Key & Secret Key configured
* SSH Key pair created and stored locally
* Terraform & Ansible installed on local machine
* Basic Git knowledge

---

🚀 Deployment Phase
This phase covers the deployment of our infrastructure and configuration of the REDCap environment using Terraform and Ansible on AWS EC2 instances.
✅ We used Terraform to provision 3 EC2 instances inside a custom VPC
✅ Used SSH from local machine to connect to the Ansible controller
✅ Ran Ansible playbook to configure Apache, MariaDB, PHP, and REDCap app
✅ Verified the setup with test PHP pages and connection scripts
✅ Fully automated REDCap deployment across web and DB servers
🔧 Step 1: Deploy Infrastructure with Terraform
We navigated to the terraform/ directory and ran the following commands:
cd terraform
terraform init         # Initialize Terraform and download AWS provider
terraform validate     # Validate syntax of .tf files
terraform plan         # Review what will be created
terraform apply        # Provision resources on AWS
📸 Screenshot: terraform-output.png
This step provisions:
1 Ansible Controller (Public Subnet)
1 Web Server (Public Subnet)
1 Database Server (Private Subnet)
Internet Gateway, Route Table, Security Groups
🔐 Step 2: SSH into the Ansible Controller
After deployment, we SSH into the Ansible controller to begin configuration:
ssh -i ~/.ssh/id_rsa ubuntu@<controller_public_ip>
📸 Screenshot: redcapuser-ssh.png
⚙️ Step 3: Install Ansible on Controller EC2
sudo apt update -y
sudo apt install ansible -y
ansible --version
📸 Screenshots:
ansible-install.png
ansible-version.png
📦 Step 4: Transfer REDCap Project Files
We copied our local redcap-ansible/ folder (with roles, playbook, templates) to the controller EC2 using scp:
scp -i ~/.ssh/id_rsa -r redcap-ansible ubuntu@<controller_ip>:~/
📸 Screenshot: copy-zip-to-controller.png
