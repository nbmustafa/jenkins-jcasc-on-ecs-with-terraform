output "jenkins_public_url" {
  value = module.ecs_jenkins.jenkins_public_url
}

output "master_log_group" {
  value = module.ecs_jenkins.master_log_group
}

output "agents_log_group" {
  value = module.ecs_jenkins.agents_log_group
}

output "jenkins_credentials" {
  value = module.ecs_jenkins.jenkins_credentials
}

output "master_config_on_s3" {
  value = module.ecs_jenkins.master_config_on_s3
}