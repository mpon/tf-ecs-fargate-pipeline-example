variable "name" {
  type        = string
  description = "IAM Role and policy name"
  default     = "codebuild-service-role"
}

variable "subnet_arns" {
  type        = list(string)
  description = "subnet ARN list to run CodeBuild"
}

variable "assets_bucket_arn" {
  type        = string
  description = "upload bucket with asset:sync"
}

variable "codepipeline_artifacts_bucket_arn" {
  type        = string
  description = "CodePipeline artifacts S3 bucket ARN"
}

variable "codebuild_bucket_arn" {
  type        = string
  description = "Codebuild S3 bucket ARN"
}
