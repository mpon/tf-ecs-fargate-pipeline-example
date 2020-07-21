variable "cluster_name" {
  type        = string
  description = "ECS cluster name"
}

variable "service_name" {
  type        = string
  description = "ECS service name"
}

variable "role_arn" {
  type        = string
  description = "ECS service linkerd role arn to execute app autoscaling"
}

variable "max_capacity" {
  type        = number
  description = "number of max containers"
}

variable "min_capacity" {
  type        = number
  description = "number of min containers"
}

variable "cpu_target_value" {
  type        = number
  description = "CPU target value for scale out/in"
}
