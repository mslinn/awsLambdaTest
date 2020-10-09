# Create IAM Role for the AWS Lambda Function and Register the Lambda Function

If you wish to type along and have not already performed the instructions on the [previous page](LAMBDA.md) please do so now.

## Create an IAM Role for the Lambda Function
This step is common to both the REST and the HTTP APIs.

1) Create an IAM role which will act as a Lambda execution role.
   We need to allow the Lambda service to assume this role in the trust policy.
   This role will specify which AWS resources the Lambda function can access.
   These instructions assume the Lambda function does not need to access any other AWS resources.

   ```script
   $ AWS_LAMBDA_ROLE_NAME=lambda-ex
   $ aws iam create-role --role-name $AWS_LAMBDA_ROLE_NAME \
     --assume-role-policy-document '{
       "Version": "2012-10-17",
       "Statement": [
         { "Effect": "Allow",
           "Principal": { "Service": "lambda.amazonaws.com" },
           "Action": "sts:AssumeRole"
         }
       ]
     }'
   ```

   Output will be something like the following:
   ```json
   {
       "Role": {
           "Path": "/",
           "RoleName": "$AWS_LAMBDA_ROLE_NAME",
           "RoleId": "AROAQOTPVZIYJZ266OVNR",
           "Arn": "$AWS_ROLE_ARN",
           "CreateDate": "2020-10-07T16:00:16Z",
           "AssumeRolePolicyDocument": {
               "Version": "2012-10-17",
               "Statement": [
                   {
                       "Effect": "Allow",
                       "Principal": {
                           "Service": "lambda.amazonaws.com"
                       },
                       "Action": "sts:AssumeRole"
                   }
               ]
           }
       }
   }
   ```

   `.Role.Arn` contains the IAM ARN that is needed in the next step.
   Save it in an environment variable called `AWS_ROLE_ARN`.

   ```script
   $ AWS_ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/$AWS_LAMBDA_ROLE_NAME"
   ```

## Register an AWS Lambda Function
Create a Lambda function like this:

   ```script
   $ aws lambda create-function \
     --function-name $AWS_LAMBDA_NAME \
     --zip-file fileb://$AWS_LAMBDA_ZIP \
     --handler $AWS_LAMBDA_HANDLER \
     --runtime $AWS_LAMBDA_RUNTIME \
     --role "$AWS_ROLE_ARN"
   ```

   Note that `$AWS_LAMBDA_ZIP` is a Lambda deployment package and has the required codes and dependencies.
   If `$AWS_LAMBDA_ZIP` is not found in the current directory, then the `zip-file` parameter value should be adjusted.
   More information about Lambda deployment package for Python is available
   [here](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html).

   Here is a sample Python 3.8 Lambda function that merely prints the incoming event.
   It should be called `index.py` in order to match the suggested handler name (`index.handler`):

   ```python
   import json

   def handler(event, context):
       print(event)
       return {
           'message': 'Lambda has received your message !'
       }
   ```

   [This documentation](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-awscli.html)
   details the steps required for creating the lambda function via the command line.

   Output will be something like:
   ```json
   {
       "FunctionName": "$AWS_LAMBDA_NAME",
       "FunctionArn": "$AWS_LAMBDA_ARN",
       "Runtime": "$AWS_LAMBDA_RUNTIME",
       "Role": "$AWS_ROLE_ARN",
       "Handler": "$AWS_LAMBDA_HANDLER",
       "CodeSize": 1489388,
       "Description": "",
       "Timeout": 3,
       "MemorySize": 128,
       "LastModified": "2020-10-07T16:04:45.636+0000",
       "CodeSha256": "McJEQT1lxVrwFojdvBL3AXqXEDrujQfQS0psuIwEGvs=",
       "Version": "$LATEST",
       "TracingConfig": {
           "Mode": "PassThrough"
       },
       "RevisionId": "c9f55d79-2724-44b5-8338-0a7e84cb156f",
       "State": "Active",
       "LastUpdateStatus": "Successful"
   }
   ```

   This step created a Lambda function with the ARN specified by `$AWS_LAMBDA_ARN`.


## Next Step

Separate instructions are given for creating the simpler [HTTP API](HTTP_API.md) and the more flexible [REST API](REST_API.md).
