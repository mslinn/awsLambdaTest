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

Output:
```json
{
    "Role": {
        "Path": "/",
        "RoleName": "lambda-ex",
        "RoleId": "AROAQOTPVZIYJZ266OVNR",
        "Arn": "arn:aws:iam::031372724784:role/lambda-ex",
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

B. Create a Lambda function:

```
$ aws lambda create-function \
  --function-name BackendLambda \
  --zip-file fileb://function.zip \
  --handler index.handler \
  --runtime python3.8 \
  --role arn:aws:iam::031372724784:role/lambda-ex
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

Output:
```json
{
    "FunctionName": "BackendLambda",
    "FunctionArn": "arn:aws:lambda:us-east-1:031372724784:function:BackendLambda",
    "Runtime": "python3.8",
    "Role": "arn:aws:iam::031372724784:role/lambda-ex",
    "Handler": "index.handler",
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


## Step 2: Creating an API Gateway API

Assuming that STEP 1 created a Lambda function with ARN
`arn:aws:lambda:us-east-1:031372724784:function:BackendLambda`:

A.  Call the `create-rest-api` command to create an API called `LambdaREST`:
```script
$ aws apigateway create-rest-api \
  --name "LambdaREST" \
  --region us-east-1
```

Output:
```json
{
    "id": "vjwf063rz8",
    "name": "LambdaREST",
    "createdDate": 1602086848,
    "apiKeySource": "HEADER",
    "endpointConfiguration": {
        "types": [
            "EDGE"
        ]
    }
}
```

B. Call the `get-resources` command to get the `root` resource id.
This will be passed to `create-resource` as the `parent-id` property,
and to `put-method`, `put-method-response`, `put-integration` and `put-integration-response` as the `resource-id` property.
It also forms the first subdomain of the REST invocation endpoint.
```script
$ aws apigateway get-resources \
  --rest-api-id vjwf063rz8 \
  --region us-east-1
```

Output:

```json
{
    "items": [
        {
            "id": "al6h0phbl7",
            "path": "/"
        }
    ]
}
```

C. Call `create-resource` to create an API Gateway Resource at `path-part demo`:
```script
$ aws apigateway create-resource \
  --rest-api-id vjwf063rz8 \
  --region us-east-1 \
  --parent-id al6h0phbl7 \
  --path-part demo
```

Output:

```json
{
    "id": "4423uo",
    "parentId": "al6h0phbl7",
    "pathPart": "demo",
    "path": "/demo"
}
```

D. Call `put-method` to create an API method request for `POST /demo`
```script
$ aws apigateway put-method \
  --rest-api-id vjwf063rz8 \
  --resource-id 4423uo \
  --http-method POST \
  --authorization-type NONE
```

Output:
```json
{
    "httpMethod": "POST",
    "authorizationType": "NONE",
    "apiKeyRequired": false
}
```

E. Call `put-method-response` to set up the `200 OK` response to the method request of POST `/demo`.

```script
$ aws apigateway put-method-response \
  --rest-api-id vjwf063rz8 \
  --resource-id 4423uo \
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
  --rest-api-id vjwf063rz8 \
  --resource-id 4423uo \
  --http-method POST \
  --type AWS \
  --integration-http-method POST \
  --uri 'arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:031372724784:function:BackendLambda/invocations'
```

Output:
```json
{
    "type": "AWS",
    "httpMethod": "POST",
    "uri": "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:031372724784:function:BackendLambda/invocations",
    "passthroughBehavior": "WHEN_NO_MATCH",
    "timeoutInMillis": 29000,
    "cacheNamespace": "4423uo",
    "cacheKeyParameters": []
}
```

G. Call `put-integration-response` to set up the integration response to pass the Lambda function output to the client as the `200 OK` method response
```script
$ aws apigateway put-integration-response \
  --region us-east-1 \
  --rest-api-id vjwf063rz8 \
  --resource-id 4423uo \
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
  --rest-api-id vjwf063rz8 \
  --stage-name test
```

Output:

```json
{
    "id": "nink3g",
    "createdDate": 1602087417
}
```

Now after deploying the api, your invocation URL should be
[`https://vjwf063rz8.execute-api.us-east-1.amazonaws.com/test/demo`](https://vjwf063rz8.execute-api.us-east-1.amazonaws.com/test/demo).
This URL can be used to make a `POST` request to invoke the Lambda.
But before that, we will need to allow API Gateway to invoke Lambda or else the requests will fail with `InternalServerError`.
The next section will do just that.

More information about creating an API and integrating it with the Lambda backend is
[here](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-custom-integrations.html).

## Step 3: Allowing Lambda To Be Invoked by API Gateway Using Lambda's Resource-Based Policy

The `source-arn` parameter of the `add-permission` subcommand needs the AWS account ID and the gateway REST API ID.

```script
$ aws lambda add-permission \
  --function-name BackendLambda \
  --action lambda:InvokeFunction \
  --statement-id lambdaperms \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:us-east-1:031372724784:vjwf063rz8/*/POST/*" \
  --output text | jq
```

Output is:

```json
{
  "Sid": "lambdaperms",
  "Effect": "Allow",
  "Principal": {
    "Service": "apigateway.amazonaws.com"
  },
  "Action": "lambda:InvokeFunction",
  "Resource": "arn:aws:lambda:us-east-1:031372724784:function:BackendLambda",
  "Condition": {
    "ArnLike": {
      "AWS:SourceArn": "arn:aws:execute-api:us-east-1:031372724784:vjwf063rz8/*/POST/*"
    }
  }
}
```

Now you can make `POST` requests to the API gateway's invocation URL like this:
```script
$ curl --no-progress-meter \
  -d 'param1=value1' \
  -d 'param2=value2' \
  https://vjwf063rz8.execute-api.us-east-1.amazonaws.com/test/demo/
```

Or even:

```
curl --no-progress-meter \
  -d "company='Slate Rock and Gravel Company'" \
  -d "emailAddress=fred@flintstone.com'" \
  -d "firstName=Fred" \
  -d "lastName=Flintstone" \
  -d "notes=None" \
  -d "phone=555-123-4567" \
  -d "title=Slob" \
  https://vjwf063rz8.execute-api.us-east-1.amazonaws.com/test/demo/
```
