#!/bin/bash

cat <<EOF > setEnvVars.sh
AWS_ACCOUNT_ID="$( aws sts get-caller-identity | jq -r .UserId )"
# Modify to another AWS region if you like:
AWS_REGION="$( aws configure get region )"

# Modify the following to suit your Lambda function:
AWS_LAMBDA_DIR=lambda
AWS_LAMBDA_NAME=BackendLambda
AWS_LAMBDA_ZIP=function.zip
AWS_LAMBDA_RUNTIME=python3.8
AWS_LAMBDA_HANDLER=echo.lambda_handler

# Do not change this:
AWS_LAMBDA_ARN="arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:function:$AWS_LAMBDA_NAME"

# Discussed in HTTP_API.md and REST_API.md; call it whatever you like:
AWS_APIG_PATH_PART=demo

# Discussed in HTTP_API.md
#   Do not change this:
AWS_APIG_TARGET_ARN="arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:function:$AWS_LAMBDA_NAME"
#   Call this whatever you like:
AWS_APIG_NAME=LambdaHTTP

# Discussed in REST_API.md; call them whatever you like:
AWS_REST_NAME=LambdaREST
AWS_APIG_STAGE=test
EOF
