variable "service_name" {
  default     = "krd"
  type        = string
  description = "The service name that all resources will be tagged with"
}

variable "app_name" {
  default     = "jenkins"
  type        = string
  description = "The app name that all resources will be tagged with"
}

variable "environment" {
  type    = string
  default = "develop"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable environment_name {
  type    = string
  default = "develop"
}