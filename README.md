# GitHub Action for AWS ECS Deployment

This action updates an ECS task definition with a new Docker image and triggers a service deployment.

## Usage

```yaml
- name: Deploy to ECS
  uses: TheCloudConnectors/action-ecs@v1.0
  with:
    cluster: 'your-cluster-name'
    service: 'your-service-name'
    task-definition: 'your-task-definition-family'
    image: 'your-image-uri'
    region: 'us-east-2'  # Optional
```

## Required Inputs

| Input                | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `cluster`            | Name of the ECS cluster                                                    |
| `service`            | Name of the service to update                                              |
| `task-definition`    | Task definition family name (without version number)                       |
| `image`              | Full Docker image URI (e.g., account.dkr.ecr.region.amazonaws.com/repo:tag) |
| `region`             | AWS region (default: us-east-2)                                            |

## Complete Example

```yaml
name: Deploy to ECS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
    - name: Deploy to ECS
      uses: TheCloudConnectors/action-ecs@v1.0
      with:
        cluster: 'prod-cluster'
        service: 'api-service'
        task-definition: 'api-task'
        image: '123456789.dkr.ecr.us-east-2.amazonaws.com/repository:1.0.0'
```

## Prerequisites

1. **AWS Permissions**:  
   The AWS user must have these permissions:
   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": [
                   "ecs:DescribeTaskDefinition",
                   "ecs:RegisterTaskDefinition",
                   "ecs:UpdateService"
               ],
               "Resource": "*"
           }
       ]
   }
   ```

2. **Dependencies**:
   - AWS CLI installed
   - jq installed in the Docker image

## How It Works

1. Fetches current task definition
2. Updates the container image
3. Registers new task definition version
4. Updates service with new task definition
5. Triggers force deployment

## Local Testing

```bash
docker build -t action-ecs .
docker run --rm \
  -e INPUT_CLUSTER=prod_cluster \
  -e INPUT_SERVICE=api-service \
  -e INPUT_TASK_DEFINITION=api-task \
  -e INPUT_IMAGE=123456789.dkr.ecr.us-east-2.amazonaws.com/repository:1.0.0 \
  -e AWS_ACCESS_KEY_ID= \
  -e AWS_SECRET_ACCESS_KEY="" \
  -e AWS_REGION=us-east-2 \
  action-ecs
  
```

---

**Note**: Always test with non-production environments first. Maintain proper IAM role permissions following least privilege principles.