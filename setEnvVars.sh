AWS_LAMBDA_DIR=lambda
AWS_LAMBDA_NAME=BackendLambda
AWS_LAMBDA_ZIP=function.zip
AWS_LAMBDA_RUNTIME=python3.8
AWS_LAMBDA_HANDLER=echo.lambda_handler
AWS_LAMBDA_ARN="arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:function:$AWS_LAMBDA_NAME"

# Discussed in HTTP_API.md and REST_API.md:
AWS_APIG_PATH_PART=demo   # Part of the URL path to invoke the Lambda function

# Discussed in HTTP_API.md:
AWS_APIG_TARGET_ARN="arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:function:$AWS_LAMBDA_NAME"
AWS_APIG_NAME=LambdaHTTP

# Discussed in REST_API.md:
AWS_REST_NAME=LambdaREST  # Name of the REST API can be anything
AWS_APIG_STAGE=test       # Usually called dev, prod or test
