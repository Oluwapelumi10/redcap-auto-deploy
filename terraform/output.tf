# Show the public IP of the Ansible Controller
output "ansible_controller_ip" {
  value       = aws_instance.ansible_controller.public_ip
  description = "Public IP of the Ansible Controller"
}

# Show the public IP of the Web Server
output "web_server_ip" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP of the Web Server"
}

# Public IP of the DB Server (should be null since it’s private)
output "db_server_ip" {
  value       = aws_instance.db_server.public_ip
  description = "Public IP of the DB Server (should be empty since it's private)"
}

# Private IP of the Ansible Controller (for Ansible inventory)
output "ansible_controller_private_ip" {
  value       = aws_instance.ansible_controller.private_ip
  description = "Private IP of the Ansible Controller"
}

# Private IP of the Web Server (for internal DB connection)
output "web_server_private_ip" {
  value       = aws_instance.web_server.private_ip
  description = "Private IP of the Web Server"
}

# Private IP of the DB Server (used in Ansible and internal config)
output "db_server_private_ip" {
  value       = aws_instance.db_server.private_ip
  description = "Private IP of the DB Server"
}
