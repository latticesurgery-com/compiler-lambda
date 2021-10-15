#!/bin/bash
source config.txt

docker build -t $IMAGE_NAME .

REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

CREATED_AT_STR=$(aws ecr describe-repositories --repository-names lattice-surgery-compiler-lambda-ecr | grep createdAt)

if [ -z $CREATED_AT_STR ]; then

    aws ecr create-repository --repository-name $ECR_REPOSITORY_NAME --image-scanning-configuration scanOnPush=true --image-tag-mutability MUTABLE
fi


REPO_LOCATION=$($ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPOSITORY_NAME:latest)

docker tag  $IMAGE_NAME:latest $REPO_LOCATION
docker push $REPO_LOCATION


LAMBDA_NAME=$(aws lambda list-functions --output text | grep -o -m 1 lattice-surgery-compiler-lambda-CompilerLambda-[a-zA-Z0-9]* | head  -n 1)

if [ ! -z $LAMBDA_NAME ]; then
    echo "Updating the lambda's function code"
    aws lambda update-function-code --function-name arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_NAME --image-uri $REPO_LOCATION
fi
