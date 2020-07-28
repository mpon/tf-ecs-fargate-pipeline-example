# tf-ecs-fargate-pipeline-example

This is a terraform configuration for deploying a sample Rails application [mpon/rails-blog-example](https://github.com/mpon/rails-blog-example) in Fargate.

- [x] VPC
- [x] ECS on Fargate
- [x] CodePipline
- [x] CodeBuild
- [x] CodeDeploy
- [x] RDS
- [x] ECS Scheduled Task

![structure](docs/aws.drawio.svg)

## Terraform Structure

```console
.
└── terraform
    ├── common # resources that exist throught account, like a iam, ecr registry etc.
    │   ├── main.tf # provider, terraform backend settings etc.
    │   ├── outputs.tf # for another env
    │   └── variables.tf # for constant variables
    ├── dev
    ├── stg
    ├── prod
    └── modules  # terraform module
```

## Requirements

- [aws-cli](https://aws.amazon.com/jp/cli/)
- [tfenv](https://github.com/tfutils/tfenv)

## Getting Started

### 0. environments

```bash
# This example use ap-northeast-1 region
export REGION=ap-northeast-1
# S3 bucket to be used by Terraform remote backend
export TF_VAR_remote_backend=<your s3 bucket>
# GitHub personal token to be used by github provider
export GITHUB_TOKEN=***********************
```

### 1. create remote backend

```bash
aws s3api create-bucket --bucket $TF_VAR_remote_backend --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION
aws s3api put-bucket-versioning --bucket $TF_VAR_remote_backend --versioning-configuration Status=Enabled
```

### 2. terraform apply(frist time)

```bash
cd terraform/common
make init
make plan
make apply
```

### 3. terraform apply(prod)

```bash
cd terraform/prod
make init
make plan
make apply # If you failed to apply, please retry
```
