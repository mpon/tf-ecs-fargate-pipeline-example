# tf-ecs-fargate-pipeline-example

This is a terraform configuration for deploying a sample Rails application [mpon/rails-blog-example](https://github.com/mpon/rails-blog-example) in Fargate.

This repository is just an example, but we are aiming for a level that can be used even for production operations, and  to complete the CI/CD only with AWS services, also without using shell like `sed` to replace image tag.

You can use this repository to try creating your own AWS infrastructure!

- [x] VPC
- [x] ECS on Fargate
- [x] ECS Application Auto Scaling by Target Tracking Scaling Policies
- [x] ECS Scheduled Task
- [x] CodePipline triggerd by GitHub
- [x] CodeBuild
- [x] CodeDeploy with B/G Deployments
- [x] RDS

![structure](docs/aws.drawio.svg)
![pipeline](docs/pipeline.drawio.svg)
![ecs](docs/ecs.png)
![scheduled_task](docs/scheduled_task.png)
![codepipeline](docs/codepipeline.png)

## Terraform Structure

```console
.
└── terraform
    ├── common # resources that exist throught account, like a iam, ecr registry etc.
    │   ├── main.tf # provider, terraform backend settings etc.
    │   ├── outputs.tf # to use value from another terraform.state
    │   └── variables.tf # for constant variables
    ├── dev # development environments
    ├── stg # staging environments
    ├── prod # production environments
    └── modules  # terraform module
```

## Requirements

- [aws-cli](https://aws.amazon.com/jp/cli/)
- [tfenv](https://github.com/tfutils/tfenv)

## Getting Started

### 0. environments

```bash
# You can set any region
export AWS_DEFAULT_REGION=ap-northeast-1

# S3 bucket to be used by Terraform remote backend
export TF_VAR_remote_backend=<your s3 bucket>

# GitHub personal token to be used by github provider
export GITHUB_TOKEN=***********************

# Configure aws-cli.
# We have not confirmed the minimum policy, it works AdministratorAccess at least.
# NOTE: In production environments, you have to reduce policy.
aws configure
```

### 1. create remote backend

```bash
aws s3api create-bucket --bucket $TF_VAR_remote_backend --region $AWS_DEFAULT_REGION \
    --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
aws s3api put-bucket-versioning --bucket $TF_VAR_remote_backend --versioning-configuration Status=Enabled
```

### 2. terraform apply(common)

We have to create ECR, IAM, and so on first. This output value will be used by another environments.

```bash
cd terraform/common
make init
make plan
make apply
```

### 3. terraform apply staging and production

Next, create some environments. If you would fail to apply, please retry once or twice.

```bash
cd terraform/stg # also terraform/prod
make init
make plan
make apply
```

Then, it shows ALB DNS name in terminal, you can access it.
At the same time, CodePipeline will be started and deploy rails application after a while.

## Clean up

```bash
cd terraform/stg
terraform destroy
cd terraform/prod
terraform destroy
cd terraform/common
terraform destroy
```

## Deploy pipeline

### staging

1. push `staging` branch in [mpon/rails-blog-example](https://github.com/mpon/rails-blog-example)
2. start staging CodePipeline
3. start CodeBuild
4. build docker image and push ECR
5. migrate database
6. sync assets
7. get files to deploy ECS from S3 (taskdef, appspec)
8. start CodeDeploy B/G Deployments

### production

1. push `master` branch in [mpon/rails-blog-example](https://github.com/mpon/rails-blog-example)
2. start production CodePipeline
3. start CodeBuild
4. build docker image and push ECR
5. migrate database
6. sync assets
7. get files to deploy ECS from S3 (taskdef, appspec)
8. start CodeDeploy B/G Deployments

## Note for using in production

- Use HTTPS listener
- Set enable_deletion_protection of ALB to true
- Set force_destroy of S3 bucket to false
- Change RDS username/password
- Change resource name using random_pet that makes it unique in this example
