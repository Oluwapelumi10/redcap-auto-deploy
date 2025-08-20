# AWS region to deploy resources
variable "aws_region" {
  default = "eu-west-2"
}

# AMI for Ubuntu 24.04 (used for controller)
variable "ami_ubuntu_24" {
  description = "AMI for Ubuntu 24.04"
  default     = "ami-044415bb13eee2391" # eu-west-2
}

# AMI for Ubuntu 22.04 (used for web and db servers)
variable "ami_ubuntu_22" {
  description = "AMI for Ubuntu 22.04"
  default     = "ami-051fd0ca694aa2379" # eu-west-2
}

# EC2 instance type
variable "instance_type" {
  default = "t2.micro"
}

# Path to your public SSH key
variable "public_key_path" {
  description = "Path to your public SSH key"
  default     = "~/.ssh/id_rsa.pub"
}
