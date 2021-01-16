#################### REQUIRED parameters
# variable "private_subnets" {
#   description = "Private subnets to deploy Jenkins and the internal NLB"
#   type        = set(string)
# }

# variable "public_subnets" {
#   description = "Public subnets to deploy the load balancer"
#   type        = set(string)
# }

#################### General variables
variable "route53_zone_name" {
  description = "A Route53 zone name to use to create a DNS record for the Jenkins Master. Required for HTTPs."
  type        = string
  default     = ""
}

variable "fargate_platform_version" {
  description = "Fargate platform version to use. Must be >= 1.4.0 to be able to use Fargate"
  type        = string
  default     = "1.4.0"
}

variable "tags" {
  description = "Default tags to apply to the resources"
  type        = map(string)
  default = {
    Application   = "Jenkins"
    ServiceName   = "krd"
    Environment   = "develop"
    ApplicationID = "JNKS321"
    CostCentre    = "KRD-JNKS"
  }
}

#################### Jenkins variables
variable "master_cpu_memory" {
  description = "CPU and memory for Jenkins master. Note that all combinations are not supported with Fargate."
  type = object({
    memory = number
    cpu    = number
  })
  default = {
    memory = 2048
    cpu    = 1024
  }
}

variable "example_agent_cpu_memory" {
  description = "CPU and memory for the agent example. Note that all combinations are not supported with Fargate."
  type = object({
    memory = number
    cpu    = number
  })
  default = {
    memory = 2048
    cpu    = 1024
  }
}

variable "master_deployment_percentages" {
  description = "The Min and Max percentages of Master instance to keep when updating the service. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/update-service.html"
  type = object({
    min = number
    max = number
  })
  default = {
    min = 0
    max = 100
  }
}

variable "master_log_retention_days" {
  description = "Retention days for Master log group"
  type        = number
  default     = 14
}

variable "agents_log_retention_days" {
  description = "Retention days for Agents log group"
  type        = number
  default     = 5
}

variable "master_docker_image" {
  type        = string
  description = "Jenkins Master docker image to use"
  default     = "nashvan/jenkins-master:latest"
  # default     = "elmhaidara/jenkins-aws-fargate:latest"
  # default     = "jenkins/jenkins:lts"
} 

variable "example_agent_docker_image" {
  type        = string
  description = "Docker image to use for the example agent. See: https://hub.docker.com/r/jenkins/inbound-agent/"
  default     = "nashvan/jenkins-alpine-agent:latest"
  # default     = "elmhaidara/jenkins-alpine-agent-aws:latest"
  # default     = "jenkins/jenkins:lts"
}

variable "master_listening_port" {
  type        = number
  default     = 8080
  description = "Jenkins container listening port"
}

variable "master_jnlp_port" {
  type        = number
  default     = 50000
  description = "JNLP port used by Jenkins agent to communicate with the master"
}

variable "master_java_opts" {
  type        = string
  description = "JAVA_OPTS to pass to the JVM"
  default     = ""
}

variable "master_num_executors" {
  type        = number
  description = "Set this to a number > 0 to be able to build on master (NOT RECOMMENDED)"
  default     = 0
}

variable "master_docker_user_uid_gid" {
  type        = number
  description = "Jenkins User/Group ID inside the container. One should consider using access point."
  default     = 0 # root
}

variable "efs_performance_mode" {
  type        = string
  description = "EFS performance mode. Valid values: generalPurpose or maxIO"
  default     = "generalPurpose"
}

variable "efs_throughput_mode" {
  type        = string
  description = "Throughput mode for the file system. Valid values: bursting, provisioned. When using provisioned, also set provisioned_throughput_in_mibps"
  default     = "bursting"
}

variable "efs_provisioned_throughput_in_mibps" {
  type        = number
  description = "The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with throughput_mode set to provisioned."
  default     = null
}

variable "efs_burst_credit_balance_threshold" {
  type        = number
  description = "Threshold below which the metric BurstCreditBalance associated alarm will be triggered. Expressed in bytes"
  default     = 1154487209164 // half of the default credits
}

######

# variable "prefix_name" {
#   type        = string
#   description = "the prefix name for the resources"
# }

variable "cost_centre" {
  type        = string
  description = "Project cost centre tag value"
}

variable "application_id" {
  type        = string
  description = "Application ID tag value"
}

variable "service_name" {
  type        = string
  description = "Service name used to namespace the resources created in AWS"
  default     = "krd"
}

variable "app_name" {
  type        = string
  description = "Application name used to namespace the resources created in AWS"
  default     = "jenkins"
}

variable "environment" {
  type        = string
  description = "Environment name for namespacing the resources created in AWS"
  default     = "develop"
}

variable "owner" {
  default     = "Nash Support"
  type        = string
  description = "The resource owner to tag all the resources with"
}

variable "subject_alternative_names" {
  description = "A list of domains that should be SANs in the issued certificate"
  type        = list(string)
  default     = []
}