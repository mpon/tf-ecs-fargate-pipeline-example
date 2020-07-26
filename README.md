# tf-ecs-fargate-pipeline-example

Example to create ECS Fargate infrastructures

- VPC
- Public Subnet
- Private Subnet
- RDS
- ElastiCache
- Elasticsearch
- ECS on Fargate
- ECS Scheduled Task
- CodePipline
- CodeBuild
- CodeDeploy

## Structure

```console
.
└── terraform
    ├── common # resource throught account like a iam, ecr registry etc.
    │   ├── main.tf # provider, terraform  backend settings etc.
    │   ├── outputs.tf # for another env
    │   └── variables.tf # for constant variables
    ├── dev/stg/prod # each environments
    └── modules  # terraform module
```

## Requirements

- [aws-cli](https://aws.amazon.com/jp/cli/)
- [tfenv](https://github.com/tfutils/tfenv)

## Getting Started

### 0. environments

```bash
export REGION=ap-northeast-1 # This example use ap-northeast-1 region
export TF_VAR_remote_backend=<your s3 bucket>
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
