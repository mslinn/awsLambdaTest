# Step 4: Debugging

If you wish to type along and have not already performed the instructions on the previous page [REST API]](REST.md) or [HTTP API](HTTP.md) please do so now.

Debugging is the same for the HTTP and REST APIs.
This document discusses how to set up an IntelliJ IDEA run configuration for debugging.


## Event Payloads
Lamdba functions always require JSON input.
API Gateway converts requests into base64, then converts an `application/x-www-form-urlencoded` request to a JSON payload, which is then sent to the Lambda function.
This is even true for the `x-www-form-urlencoded` data POSTed via `curl` with the `-d` option.
The Lambda function always receives a JSON payload inside an `event` object.

More information on Lambda payloads sent by the HTTP and REST APIs may be found
[here](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vs-rest.html).


## Updating Lambda Functions
To update the Lambda function that we defined [earlier](LAMBDA.md), recreate `$AWS_LAMBDA_ZIP` and then call `update-function-code`:

```script
$ aws lambda update-function-code \
  --function-name $AWS_LAMBDA_NAME \
  --zip-file fileb://$AWS_LAMBDA_ZIP
```

Output is:

```json
{
    "FunctionName": "$AWS_LAMBDA_NAME",
    "FunctionArn": "$AWS_LAMBDA_ARN",
    "Runtime": "$AWS_LAMBDA_RUNTIME",
    "Role": "$AWS_ROLE_ARN",
    "Handler": "addSubscriberAwsLambda.lambda_handler",
    "CodeSize": 1491007,
    "Description": "",
    "Timeout": 3,
    "MemorySize": 128,
    "LastModified": "2020-10-07T18:05:17.356+0000",
    "CodeSha256": "fDcOeBsHCo0QNVGpLUFaElBZUDuhDm365bF+QL0dNqE=",
    "Version": "$LATEST",
    "TracingConfig": {
        "Mode": "PassThrough"
    },
    "RevisionId": "5e895712-f86d-4194-8f91-bc16b15df7a2",
    "State": "Active",
    "LastUpdateStatus": "Successful"
}
```

## All Done!
