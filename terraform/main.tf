# Set up AWS provider
provider "aws" {
  region = var.aws_region
}

# Upload your SSH key so you can connect to EC2s securely via SSH
resource "aws_key_pair" "redcap_key" {
  key_name   = "redcap-key"
  public_key = file(var.public_key_path)
}

# Create a virtual private cloud (VPC) — this is like your isolated network in AWS
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "redcap-vpc" }
}

# Public subnet — this is where the controller and web servers will live (they can access internet)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2"
  tags = { Name = "redcap-public-subnet" }
}

# Private subnet — the database server will live here, hidden from public internet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2"
  tags = { Name = "redcap-private-subnet" }
}

# Internet Gateway — allows traffic from the internet to access your public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "redcap-igw" }
}

# Route table for the public subnet — lets resources in that subnet talk to the internet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  # Allow any traffic to go through the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "redcap-public-rt" }
}

# Attach the route table to the public subnet
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security group to allow web and SSH traffic (for controller and web servers)
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP/HTTPS access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22   # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere
  }

  ingress {
    from_port   = 80   # HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443  # HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic (all allowed)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the DB — only allows internal access from web/controller
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Database security group"
  vpc_id      = aws_vpc.main.id

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow controller/web servers to SSH into the DB server
resource "aws_security_group_rule" "db_ssh_from_controller_web" {
  type                     = "ingress"
  security_group_id        = aws_security_group.db_sg.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.allow_ssh_http.id
}

# Allow the web server to talk to MariaDB (port 3306) on the DB
resource "aws_security_group_rule" "db_allow_from_web" {
  type              = "ingress"
  security_group_id = aws_security_group.db_sg.id
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.web_server.private_ip}/32"]
}

# Ansible Controller (public subnet, can SSH and control other servers)
resource "aws_instance" "ansible_controller" {
  ami                         = var.ami_ubuntu_24
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.redcap_key.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http.id]
  tags = { Name = "Ansible-Controller" }
}

# Web Server (public subnet so REDCap web is reachable)
resource "aws_instance" "web_server" {
  ami                         = var.ami_ubuntu_22
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.redcap_key.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http.id]
  tags = { Name = "REDCap-Web" }
}

# Database Server (private subnet, no internet exposure — for security)
resource "aws_instance" "db_server" {
  ami                         = var.ami_ubuntu_22
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.redcap_key.key_name
  subnet_id                   = aws_subnet.private_subnet.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  tags = { Name = "REDCap-DB" }
}
