variable "name" {
  type        = string
  description = "IAM Role and policy name"
  default     = "codepipeline-service-role"
}

variable "codepipeline_artifacts_bucket_arn" {
  type        = string
  description = "CodePipeline artifacts S3 bucket ARN"
}
