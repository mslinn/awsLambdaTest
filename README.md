#  Fun With AWS Lambda, API Gateway and IAM

This documents how to invoke an unsigned Lambda via POST using two types of API Gateways: HTTP and REST.
This means that a public Lambda is defined, which does not require security credentials to be invoked. 
The Lambda function needs to have previously been created; these instructions do not describe how to do that.

The same Lambda function is invoked via both mechanisms, using the same data.
The first step is the same for both approaches.
Subsequent steps are explained separately.

If you want to type along:

1. Install [AWS CLI](https://aws.amazon.com/cli/) and [jq](https://stedolan.github.io/jq/download/).
2. Configure AWS CLI:
   ```script
   $ aws configure
   ```
2. Define an environment variable called `AWS_ACCOUNT_ID` by typing the following:

   ```script
   $ AWS_ACCOUNT_ID="$( aws sts get-caller-identity | jq -r .UserId )"
   ```

3. Store the AWS region in an environment variable called `AWS_REGION`.
   Set this to any [valid region](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/) that you like:

   ```script
   $ AWS_REGION=us-east-1
   ```

4. Save the name of the Lambda function you wish to invoke in an environment variable called `AWS_LAMBDA_NAME`; you can provide any valid name you like here:
   ```script
   $ AWS_LAMBDA_NAME=BackendLambda
   ```

5. Save the name of the zip file contaning the Lambda function in an environment variable called `AWS_LAMBDA_ZIP`:
   ```script
   $ AWS_LAMBDA_ZIP=function.zip  # Modify to suit your Lambda function
   ```

6. Save the runtime of the Lambda function in an environment variable called `AWS_LAMBDA_RUNTIME`:
   ```script
   $ AWS_LAMBDA_RUNTIME=python3.8  # Modify to suit your Lambda function
   ```

7. Save the entry point (AWS documentation calls this a `handler`) for the Lambda function in an environment variable called `AWS_LAMBDA_NAME`:
   ```script
   $ AWS_LAMBDA_HANDLER=index.handler  # Modify to suit your Lambda function
   ```

8. Compute the Lambda function's ARN and save in an environment variable called `AWS_LAMBDA_ARN`:
   ```script
   $ AWS_LAMBDA_ARN= "arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:function:$AWS_LAMBDA_NAME"
   ```


Step 2 will define additional environment variables.


## Step 1: Create a Lambda Function
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

2. Create a Lambda function:

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


## Step 2) Creating an API Gateway API

Separate instructions are given for the simpler [HTTP API](HTTP_API.md) and the more flexible [REST API](REST_API.md).
