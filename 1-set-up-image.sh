#!/bin/bash
source config.txt

docker build -t $IMAGE_NAME .

REPOSITORY_REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)


CREATED_AT_STR=$(aws ecr describe-repositories --repository-names lattice-surgery-compiler-lambda-ecr | grep createdAt)

if [ -z CREATED_AT_STR ]; then
    aws ecr get-login-password --region $REPOSITORY_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REPOSITORY_REGION.amazonaws.com

    aws ecr create-repository --repository-name $ECR_REPOSITORY_NAME --image-scanning-configuration scanOnPush=true --image-tag-mutability MUTABLE
fi

docker tag  $IMAGE_NAME:latest $ACCOUNT_ID.dkr.ecr.$REPOSITORY_REGION.amazonaws.com/$ECR_REPOSITORY_NAME:latest
docker push $ACCOUNT_ID.dkr.ecr.$REPOSITORY_REGION.amazonaws.com/$ECR_REPOSITORY_NAME:latest

