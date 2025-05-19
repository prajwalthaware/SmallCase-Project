output "deployment_status" {
  description = "Deployment completion status"
  value       = "Infrastructure deployment completed successfully"
}

output "application_access" {
  description = "Access information for the deployed application"
  value       = "Your application is available at: http://${module.compute.instance_public_ip}"
}
