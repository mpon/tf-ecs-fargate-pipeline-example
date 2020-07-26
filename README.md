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

## Getting Started

### 1. create remote backend

```bash
# This example use ap-northeast-1 region
export REMOTE_BACKEND=<your bucket>
aws s3api create-bucket --bucket $REMOTE_BACKEND --region ap-northeast-1 \
    --create-bucket-configuration LocationConstraint=ap-northeast-1
aws s3api put-bucket-versioning --bucket $REMOTE_BACKEND --versioning-configuration Status=Enabled
```

### 2. terraform apply(frist time)

```bash
cd terraform/common
export REMOTE_BACKEND=<your bucket>
make init
make plan
make apply
```

### 3. terraform apply(prod)

```bash
cd terraform/prod
export REMOTE_BACKEND=<your bucket>
make init
make plan
make apply # If you failed to apply, please retry
```

