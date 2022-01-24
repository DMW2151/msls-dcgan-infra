output "worker_ip_addr" {
  description = "Internal IP address of the VPC's Worker instance. Deployer can SSH into this instance via Jump."
  value       = aws_instance.worker.private_ip
}