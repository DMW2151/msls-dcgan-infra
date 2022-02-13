output "api_ip_addr" {
  description = "Internal IP address of the VPC's API instance. Deployer can SSH tunnel into this instance."
  value       = aws_instance.api.private_ip
}