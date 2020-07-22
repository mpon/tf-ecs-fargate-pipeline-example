output "assets_bucket" {
  value = aws_s3_bucket.assets
}

output "ecs_application_autoscaling_role_arn" {
  value = aws_iam_service_linked_role.ecs_application_autoscaling.arn
}

output "ecr_rails_blog_example_repository_url" {
  value = aws_ecr_repository.rails_blog_example.repository_url
}
