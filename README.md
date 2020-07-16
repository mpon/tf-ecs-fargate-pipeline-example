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

## Getting Started

### 1. create remote backend

```bash
REMOTE_BACKEND=<your bucket>
REGION=<your region>
aws s3api create-bucket --bucket $REMOTE_BACKEND --region $REGION --create-bucket-configuration LocationConstraint=$REGION
aws s3api put-bucket-versioning --bucket $REMOTE_BACKEND --versioning-configuration Status=Enabled
```
