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

if [ -z "$INPUT_ROLE" ]; then
  echo "INPUT_ROLE is not set. Quitting."
  exit 1
fi

echo "Assuming IAM role..."
OIDC_TOKEN=$(curl -sSf -H "Authorization: Bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL" | jq -er '.value')

# Valider le jeton
if [ -z "$OIDC_TOKEN" ]; then
  echo "❌ Failed to obtain OIDC token"
  exit 1
fi

# Utiliser le rôle directement via OIDC sans credentials manuels
aws configure set web_identity_token_file <(echo "$OIDC_TOKEN")
aws configure set role_arn "$INPUT_ROLE"
aws configure set role_session_name "GitHubActions"

# Les appels AWS suivants utiliseront automatiquement le rôle
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
