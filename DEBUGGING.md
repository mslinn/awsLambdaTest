# Step 4: Debugging

Debugging is the same for the HTTP and REST APIs.
This document discusses how to set up an IntelliJ IDEA run configuration for debugging.


## Enable CloudWatch Logging

This optional step makes it easier to figure out problems.
See the [API Gateway Developer Guide](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-logging.html) for more information on enabling [CloudWatch logging](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html) 
for a particular API Gateway stage.

```script
$ aws logs create-log-group --log-group-name log-group1
```

For HTTP APIs:
```script
$ aws apigatewayv2 update-stage --api-id $AWS_APIG_HTTP_ID \
    --stage-name '$default' \
    --access-log-settings '{"DestinationArn": "arn:aws:logs:region:account-id:log-group:log-group1", "Format": "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"}'
```

For REST APIs:
```script
$ aws apigatewayv2 update-stage --api-id $AWS_APIG_REST_ID \
    --stage-name $AWS_APIG_STAGE \
    --access-log-settings '{"DestinationArn": "arn:aws:logs:region:account-id:log-group:log-group1", "Format": "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"}'
```


## Event Payloads
Lamdba functions always require JSON input.
API Gateway converts requests into base64, then converts an `application/x-www-form-urlencoded` request to a JSON payload, which is then sent to the Lambda function.
This is even true for the `x-www-form-urlencoded` data POSTed via `curl` with the `-d` option.
The Lambda function always receives a JSON payload inside an `event` object.

More information on Lambda payloads sent by the HTTP and REST APIs may be found
[here](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vs-rest.html).


## Modifying the Lambda Code

It is normal in the software development process to need to modify the program code.
I [described how to do](LAMBDA.md#updating-lambda-function-code) that previously.

## All Done!
