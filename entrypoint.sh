#!/bin/sh

set -euo pipefail

if [ -z "$INPUT_CLUSTER" ]; then
  echo "INPUT_CLUSTER is not set. Quitting."
  exit 1
fi

if [ -z "$INPUT_SERVICE" ]; then
  echo "INPUT_SERVICE is not set. Quitting."
  exit 1
fi

if [ -z "$INPUT_TASK_DEFINITION" ]; then
  echo "INPUT_TASK_DEFINITION is not set. Quitting."
  exit 1
fi

if [ -z "$INPUT_IMAGE" ]; then
  echo "INPUT_IMAGE is not set. Quitting."
  exit 1
fi

if [ -z "$INPUT_REGION" ]; then
  INPUT_REGION="us-east-2"
fi

# Nouvelle vérification pour le rôle ARN
if [ -z "$INPUT_ROLE_ARN" ]; then
  echo "INPUT_ROLE_ARN is not set. Quitting."
  exit 1
fi

echo "Assuming role $INPUT_ROLE_ARN..."
CREDENTIALS=$(aws sts assume-role \
  --role-arn "$INPUT_ROLE_ARN" \
  --role-session-name "ECSTaskDeployment" \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text)

AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | awk '{print $1}')
AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | awk '{print $2}')
AWS_SESSION_TOKEN=$(echo $CREDENTIALS | awk '{print $3}')

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

echo "Fetching current task definition..."
TASK_DEFINITION=$(aws ecs describe-task-definition \
  --region $INPUT_REGION \
  --task-definition $INPUT_TASK_DEFINITION \
  | jq '.taskDefinition | del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .registeredAt, .registeredBy, .compatibilities)')

# Update the image URI in the task definition
echo "Updating image URI to: $INPUT_IMAGE"
TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$INPUT_IMAGE" '.containerDefinitions[0].image = $IMAGE')

# Register the new task definition
echo "Registering new task definition..."
TASK_DEFINITION_ARN=$(aws ecs register-task-definition \
  --region $INPUT_REGION \
  --cli-input-json "$TASK_DEFINITION" \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)

echo "New task definition registered: $TASK_DEFINITION_ARN"

# Update the service with the new task definition
echo "Updating service to use new task definition..."
if ! aws ecs update-service \
  --region $INPUT_REGION \
  --cluster $INPUT_CLUSTER \
  --service $INPUT_SERVICE \
  --task-definition $TASK_DEFINITION_ARN \
  --force-new-deployment
then
  echo "Service update failed"
  exit 1
fi

echo "Service updated successfully"
