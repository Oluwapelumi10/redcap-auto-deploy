# Public IP of the Ansible controller
output "ansible_controller_ip" {
  value = aws_instance.ansible_controller.public_ip
}

# Public IP of the web server
output "web_server_ip" {
  value = aws_instance.web_server.public_ip
}

# Public IP of the database server
output "db_server_ip" {
  value = aws_instance.db_server.public_ip
}

# Private IP of the web server
output "web_server_private_ip" {
  value = aws_instance.web_server.private_ip
}

# Private IP of the database server
output "db_server_private_ip" {
  value = aws_instance.db_server.private_ip
}

# Private IP of the Ansible controller
output "ansible_controller_private_ip" {
  value = aws_instance.ansible_controller.private_ip
}