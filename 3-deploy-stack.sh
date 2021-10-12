#!/bin/bash
source config.txt

set -eo pipefail

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws cloudformation deploy --template-file template.yml --stack-name $STACK_NAME --capabilities CAPABILITY_NAMED_IAM --parameter-overrides EcrRepositoryName=$ECR_REPOSITORY_NAME,AccountId=$ACCOUNT_ID
