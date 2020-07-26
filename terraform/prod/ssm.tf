/*
  You have to update value from console or cli.
  ex: aws ssm update --name /prod/SECRET_KEY_BASE --value super_special_secret
*/
resource "aws_ssm_parameter" "secret_key_base" {
  name   = "/${local.env}/SECRET_KEY_BASE"
  type   = "SecureString"
  key_id = "alias/aws/ssm"
  value  = "super_secret_token"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "database_url" {
  name   = "/${local.env}/DATABASE_URL"
  type   = "SecureString"
  key_id = "alias/aws/ssm"

  # TODO: database user and password should be updated 
  value = "postgres://postgres:password@${aws_db_instance.db.endpoint}/blog_${local.env}"
}
