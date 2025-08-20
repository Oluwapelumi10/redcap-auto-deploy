# AWS region to deploy your infrastructure
variable "aws_region" {
  description = "The AWS region to deploy resources"
  default     = "eu-west-2"
}

# Ubuntu 24.04 AMI for Ansible controller
variable "ami_ubuntu_24" {
  description = "Ubuntu 24.04 AMI ID for the Ansible Controller"
  default     = "ami-044415bb13eee2391"
}

# Ubuntu 22.04 AMI for web server and DB server
variable "ami_ubuntu_22" {
  description = "Ubuntu 22.04 AMI ID for Web and DB servers"
  default     = "ami-051fd0ca694aa2379"
}

# Instance type (EC2 size)
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

# Path to your public SSH key
variable "public_key_path" {
  description = "Path to your public SSH key"
  default     = "~/.ssh/id_rsa.pub"
}
