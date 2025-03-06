#!/bin/sh

set -e

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

# Get the current task definition
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
aws ecs update-service \
  --region $INPUT_REGION \
  --cluster $INPUT_CLUSTER \
  --service $INPUT_SERVICE \
  --task-definition $TASK_DEFINITION_ARN \
  --force-new-deployment

echo "Deployment initiated successfully"
