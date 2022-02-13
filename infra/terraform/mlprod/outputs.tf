output "jump_ip_addr" {
  description = "Public IP address of the Jump instance"
  value       = module.mlcore.jump_ip_addr
}

output "metrics_ip_addr" {
  description = "Internal IP address of the VPC's metrics instance. Deployer can SSH tunnel into this instance via jump."
  value       = module.stats-monitor.metrics_ip_addr
}

output "worker_ip_addr" {
  description = "Internal IP address of the VPC's worker instance. Deployer can SSH tunnel into this instance via jump."
  value       = module.train-prod.worker_ip_addr
}

output "api_ip_addr" {
  description = "Internal IP address of the VPC's worker instance. Deployer can SSH tunnel into this instance via jump."
  value       = module.imgs-api.api_ip_addr
}