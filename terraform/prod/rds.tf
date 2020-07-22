resource "aws_db_instance" "db" {
  identifier                   = "rails-blog"
  allocated_storage            = 20
  max_allocated_storage        = 1000
  storage_type                 = "gp2"
  engine                       = "postgres"
  engine_version               = "12.3"
  instance_class               = "db.t2.micro"
  username                     = "postgres"
  password                     = "password" # !!! DO NOT USE production usecase
  parameter_group_name         = "default.postgres12"
  vpc_security_group_ids       = [aws_security_group.db.id]
  copy_tags_to_snapshot        = true
  performance_insights_enabled = true
  skip_final_snapshot          = true
}
