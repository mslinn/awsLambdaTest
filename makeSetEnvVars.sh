#!/bin/bash

cat <<EOF > setEnvVars.sh
# Do not change this next line:
AWS_ACCOUNT_ID="$( aws sts get-caller-identity | jq -r .UserId )"

# Modify to another AWS region if you like:
AWS_REGION="$( aws configure get region )"

# Modify the following to suit your Lambda function

# Directory where the Lambda function resides:
AWS_LAMBDA_DIR=lambda

# Name of the Lambda function you wish to invoke.
# (See https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#API_CreateFunction_RequestParameters):
AWS_LAMBDA_NAME=BackendLambda

# Name of the zip file containing the Lambda function:
AWS_LAMBDA_ZIP=function.zip

# Runtime of the Lambda function:
AWS_LAMBDA_RUNTIME=python3.8

# Lambda entry point (AWS documentation calls this a handler).
# The first portion of the value is the name of the Python source code in the zip filecontaining the handler,
# and the second portion of the value is the name of the handler function in that file.
# For example, if the Python source code file is called echo.py and the handler is called handler, the value would be:
AWS_LAMBDA_HANDLER=echo.lambda_handler


# Do not change this next line:
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
