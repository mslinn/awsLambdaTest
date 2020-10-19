# Create IAM Role for the Lambda and the Lambda Itself

If you wish to type along and have not already performed the instructions on the [previous page](LAMBDA.md) please do so now.

The instructions on this page create values for the following environment variables in `setEnvVars`: `AWS_ROLE_ARN`.


## Resuming Your Work

If you are resuming these instructions in a new shell, load the environment variables from `setEnvVars`:

```script
$ source setEnvVars
```


## Create an IAM Role for the Lambda Function
For API Gateway / Lambda integration 2-way permissions are required:

1) The API Gateway should have permission to invoke the lambda function, which is provided by the
[service-linked role](https://docs.aws.amazon.com/IAM/latest/UserGuide/using-service-linked-roles.html)
`AWSServiceRoleForAPIGateway`.

2) The Lambda function should allow API Gateway to invoke the Lambda function via a resource-based policy.

3) The Lambda function requires a Lambda Execution Role to access other AWS services, described below.

4) By default, Lambda functions do not have permission to write to Amazon CloudWatch Logs.
   To add logging permission to a Lambda function, add the `AWSLambdaBasicExecutionRole`
   managed policy to the Lambda's execution role.

The instructions on this page are required for both the HTTP and the REST APIs.

1) Create an IAM role which will act as a Lambda execution role.
   We need to allow the Lambda service to assume this role in the trust policy.
   This role will specify which AWS resources the Lambda function can access.
   These instructions assume the Lambda function does not need to access any other AWS resources.

   ```script
   $ ./capture aws iam create-role --role-name $AWS_LAMBDA_ROLE_NAME \
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

2. `.Role.Arn` contains the IAM ARN that is needed in the next step.
   Save it in an environment variable called `AWS_ROLE_ARN` in `setEnvVars` and re-source the file.

   ```script
   $ ./extract .Role.Arn AWS_ROLE_ARN
   arn:aws:iam::031372724784:role/lambda-ex

   $ source setEnvVars
   ```


## Create the AWS Lambda Function
Create a Lambda function from the Python program like this:

```script
$ aws lambda create-function \
  --function-name $AWS_LAMBDA_NAME \
  --zip-file fileb://$AWS_LAMBDA_ZIP \
  --handler $AWS_LAMBDA_HANDLER \
  --runtime $AWS_LAMBDA_RUNTIME \
  --role "$AWS_ROLE_ARN"
```

Note that `$AWS_LAMBDA_ZIP` is the Lambda deployment package we created on the previous page, and has the required Python program and dependencies.
If `$AWS_LAMBDA_ZIP` is not found in the current directory, then the `zip-file` parameter value should be adjusted.

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
