#!/bin/bash
source config.txt

set -eo pipefail
ARTIFACT_BUCKET=$(cat bucket-name.txt)
aws cloudformation package  --template-file template.yml --s3-bucket $ARTIFACT_BUCKET --output-template-file out.yml
aws  cloudformation deploy  --template-file out.yml --stack-name $STACK_NAME --capabilities CAPABILITY_NAMED_IAM
