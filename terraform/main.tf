# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Create an SSH key pair for EC2 instances
resource "aws_key_pair" "redcap_key" {
  key_name   = "redcap-key"
  public_key = file(var.public_key_path)
}

# Security group for web and controller servers (allows SSH, HTTP, HTTPS)
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP/HTTPS access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the database server
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Database security group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow SSH to DB only from web/controller security group
resource "aws_security_group_rule" "db_ssh_from_controller_web" {
  type                     = "ingress"
  security_group_id        = aws_security_group.db_sg.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.allow_ssh_http.id
}

# Allow MariaDB access to DB only from web server's private IP
resource "aws_security_group_rule" "db_allow_from_web" {
  type              = "ingress"
  security_group_id = aws_security_group.db_sg.id
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.web_server.private_ip}/32"]
}

# Ansible controller EC2 instance
resource "aws_instance" "ansible_controller" {
  ami                    = var.ami_ubuntu_24
  instance_type          = var.instance_type
  key_name               = aws_key_pair.redcap_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  tags = { Name = "Ansible-Controller" }
}

# Web server EC2 instance
resource "aws_instance" "web_server" {
  ami                    = var.ami_ubuntu_22
  instance_type          = var.instance_type
  key_name               = aws_key_pair.redcap_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  tags = { Name = "REDCap-Web" }
}

# Database server EC2 instance
resource "aws_instance" "db_server" {
  ami                    = var.ami_ubuntu_22
  instance_type          = var.instance_type
  key_name               = aws_key_pair.redcap_key.key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  tags = { Name = "REDCap-DB" }
}