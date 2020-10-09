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


## Modifying the Lambda Code

It is normal in the software development process to need to modify the program code.
I [described how to do](LAMBDA.md#updating-lambda-function-code) that previously.

## All Done!
