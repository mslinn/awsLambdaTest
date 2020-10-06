#  Fun With AWS Lambda, API Gateway and IAM

## Step 1: Create a Lambda Function

A. Create an IAM role which will act as a Lambda execution role.
We need to allow the Lambda service to assume this role in the trust policy.
This role will specify which AWS resources does the Lambda function has access to
(assuming Lambda is not accessing any other AWS resources.)

```script
$ aws iam create-role --role-name lambda-ex \
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

B. Create a Lambda function:

```
$ aws lambda create-function \
  --function-name BackendLambda \
	--zip-file fileb://function.zip \
	--handler index.handler \
	--runtime python3.8 \
	--role arn:aws:iam::123456789012:role/lambda-ex
```

Note that `function.zip` is a Lambda deployment package and has the required codes and dependencies.
If `function.zip` is not found in the current directory, then the `zip-file` parameter value should be adjusted.
More information about Lambda Deployment package for Python is available
[here](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html).
Here is a sample Python 3.8 Lambda function that merely prints the incoming event:

```python
import json

def lambda_handler(event, context):
    print(event)
    return {
        'message': 'Lambda has received your message !'
    }
```

[This documentation](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-awscli.html)
explains in detail the steps required for creating the lambda function via the command line.


## Step 2: Creating an API Gateway API

Assuming that STEP 1 created a Lambda function with ARN
`arn:aws:lambda:us-east-1:123456789012:function:BackendLambda`:

A.  Call the `create-rest-api` command to create an API called `LambdaREST`:
```script
$ aws apigateway create-rest-api \
  --name "LambdaREST"
	--region us-east-1
```

Output:
```json
{
    "id": "te6si5ach7",
    "name": "LambdaREST",
    "createdDate": "2020-10-05T11:23:49+05:30",
    "apiKeySource": "HEADER",
    "endpointConfiguration": {
        "types": [
            "EDGE"
        ]
    }
}
```

B. Call the `get-resources` command to get the `root` resource id:
```script
$aws apigateway get-resources \
  --rest-api-id te6si5ach7 \
	--region us-east-1
```

Output:

```json
{
    "items": [
        {
            "path": "/",
            "id": "krznpq9xpg"
        }
    ]
}
```

C. Call `create-resource` to create an API Gateway Resource at `path-part demo`:
```script
$ aws apigateway create-resource \
  --rest-api-id te6si5ach7 \
	--region us-east-1 \
	--parent-id krznpq9xpg \
	--path-part demo
```

Output:

```json
{
    "path": "/demo",
    "pathPart": "demo",
    "id": "2jf6xt",
    "parentId": "krznpq9xpg"
}
```

D. Call `put-method` to create an API method request for `POST /demo`
```script
$ aws apigateway put-method \
  --rest-api-id te6si5ach7 \
	--resource-id 2jf6xt \
	--http-method POST \
	--authorization-type NONE
```

Output:
```json
{
    "apiKeyRequired": false,
    "httpMethod": "POST",
    "authorizationType": "NONE"
}
```

E. Call `put-method-response` to set up the `200 OK` response to the method request of POST `/demo`.

```script
$ aws apigateway put-method-response \
  --rest-api-id te6si5ach7 \
	--resource-id 2jf6xt \
	--http-method POST \
	--status-code 200
```

Output:
```json
{
    "statusCode": "200"
}
```

F. Call `put-integration` to set up the integration of the `POST /demo` method with a Lambda function named `BackendLambda`.
The function responds with "Lambda has received your message !" as specified in the Lambda code.

```scriptvalue2
$ aws apigateway put-integration \
  --rest-api-id te6si5ach7 \
	--resource-id 2jf6xt \
	--http-method POST \
	--type AWS \
	--integration-http-method POST \
	--uri 'arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:BackendLambda/invocations'
```

Output:
```json
{
    "type": "AWS",
    "httpMethod": "POST",
    "uri": "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:BackendLambda/invocations",
    "passthroughBehavior": "WHEN_NO_MATCH",
    "timeoutInMillis": 29000,
    "cacheNamespace": "2jf6xt",
    "cacheKeyParameters": []
}
```

G. Call `put-integration-response` to set up the integration response to pass the Lambda function output to the client as the `200 OK` method response
```script
$ aws apigateway put-integration-response \
  --region us-east-1 \
	--rest-api-id te6si5ach7 \
	--resource-id 2jf6xt \
	--http-method POST \
	--status-code 200 \
	--selection-pattern ""
```

Output:
```json
{
    "selectionPattern": "",
    "statusCode": "200"
}
```

H. Call `create-deployment` to deploy the API to the `test` stage:
```script
$ aws apigateway create-deployment \
  --rest-api-id te6si5ach7 \
	--stage-name test
```

Now after deploying the api, your invocation URL should be
[`https://te6si5ach7.execute-api.us-east-1.amazonaws.com/test/demo`](https://te6si5ach7.execute-api.us-east-1.amazonaws.com/test/demo).
This URL can be used to make a `POST` request to invoke the Lambda.
But before that, we will need to allow API Gateway to invoke Lambda or else the requests will fail with `InternalServerError`.

Detailed steps on creating an API and integrating it with the Lambda backend are
[here](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-custom-integrations.html). 

## Step 3: Allowing Lambda To Be Invoked by API Gateway Using Lambda's Resource-Based Policy

```script
$ aws lambda add-permission \
  --function-name BackendLambda \
	--action lambda:InvokeFunction \
	--statement-id lambdaperms \
	--principal apigateway.amazonaws.com \
	--source-arn "arn:aws:execute-api:us-east-1:394654164621:ira0fio9af/*/POST/*" \
	--output text
```

Now you can make `POST` requests to the API gateway's invocation URL like this:
```
curl \
  -d 'param1=value1' \
  -d 'param2=value2' \
  https://<rest-api-id>.execute-api.us-east-1.amazonaws.com/test/demo/
```
