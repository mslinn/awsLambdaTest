# Create IAM Role for the AWS Lambda Function and Register the Lambda Function

If you wish to type along and have not already performed the instructions on the [previous page](LAMBDA.md) please do so now.


## Create the AWS Lambda Function
Create an AWS Lambda function from the Python program like this:

```script
$ aws lambda create-function \
  --function-name $AWS_LAMBDA_NAME \
  --zip-file fileb://$AWS_LAMBDA_ZIP \
  --handler $AWS_LAMBDA_HANDLER \
  --runtime $AWS_LAMBDA_RUNTIME \
  --role "$AWS_ROLE_ARN"
```

Note that `$AWS_LAMBDA_ZIP` is the Lambda deployment package we created on the previous page, and has the required codes and dependencies.
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
