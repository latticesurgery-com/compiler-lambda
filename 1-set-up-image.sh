#!/bin/bash
source config.txt

docker build -t $IMAGE_NAME .

REPOSITORY_REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# TODO if repository does not exist
aws ecr get-login-password --region $REPOSITORY_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REPOSITORY_REGION.amazonaws.com

aws ecr create-repository --repository-name $ECR_REPOSITORY_NAME --image-scanning-configuration scanOnPush=true --image-tag-mutability MUTABLE
# endif

docker tag  $IMAGE_NAME:latest $ACCOUNT_ID.dkr.ecr.$REPOSITORY_REGION.amazonaws.com/$ECR_REPOSITORY_NAME:latest
docker push $ACCOUNT_ID.dkr.ecr.$REPOSITORY_REGION.amazonaws.com/$ECR_REPOSITORY_NAME:latest

