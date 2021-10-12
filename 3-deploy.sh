#!/bin/bash
source config.txt

set -eo pipefail

aws cloudformation deploy --template-file template.yml --stack-name $STACK_NAME --capabilities CAPABILITY_NAMED_IAM --parameter-overrides EcrRepositoryName=$ECR_REPOSITORY_NAME
