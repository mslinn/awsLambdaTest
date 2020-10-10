# REST API

If you wish to type along and have not already performed the instructions on the
[previous page](REGISTER.md) please do so now.

If you are resuming these instructions in a new shell, load the environment variables from `setEnvVars`:

```script
$ source setEnvVars
```


## Saving Your Work

We will use these environment variables from `setEnvVars`:

```script
AWS_REST_NAME=LambdaREST  # Name of the REST API can be anything
AWS_APIG_PATH_PART=demo   # Part of the URL path to invoke the Lambda function
AWS_APIG_STAGE=test       # Usually called dev, prod or test
```

Near the end of this page you will be instructed to create and save additional environment variables to `setEnvVars` so you can return to this project at another time.


## Create an API Gateway REST API

1. Call the `create-rest-api` command to create an API called `LambdaREST`.

   a. Define the name of the API in an environment variable called `AWS_REST_NAME`

      ```script
      $ ./capture aws apigateway create-rest-api \
        --name $AWS_REST_NAME \
        --region $AWS_REGION
      ```

    Output will be something like:

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

    b. Save the returned REST API `id` in an environment variable called `AWS_REST_ID`:

    ```script
    $ AWS_REST_ID="$( ./extract .id )"
    ```

2. Call the `get-resources` command to get the `root` resource id.
   This will be passed to `create-resource` as the `parent-id` property,
   and to `put-method`, `put-method-response`, `put-integration` and `put-integration-response` as the `resource-id` property.
   It also forms the first subdomain of the REST invocation endpoint.

   ```script
   $ ./capture aws apigateway get-resources \
     --rest-api-id $AWS_REST_ID \
     --region $AWS_REGION
   ```

   Output will be something like:

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

   Save the returned root resouce `id` in an environment variable called `AWS_APIG_ROOT_ID`:

   ```script
   $ AWS_APIG_ROOT_ID="$( ./extract .items[0].id )"
   ```

3. Call `create-resource` to create an API Gateway Resource at `path-part $AWS_APIG_PATH_PART`:

   ```script
   $ ./capture aws apigateway create-resource \
     --rest-api-id $AWS_REST_ID \
     --region $AWS_REGION \
     --parent-id $AWS_APIG_ROOT_ID \
     --path-part $AWS_APIG_PATH_PART
   ```

   Output will be something like:

   ```json
   {
       "id": "4423uo",
       "parentId": "al6h0phbl7",
       "pathPart": "$AWS_APIG_PATH_PART",
       "path": "/$AWS_APIG_PATH_PART"
   }
   ```

   Save the new resource id in an environment variable called `AWS_APIG_RESOURCE_ID`:
   ```script
   AWS_APIG_RESOURCE_ID="$( ./extract .id )"
   ```

4. Call `put-method` to create an API method request for `POST /$AWS_APIG_PATH_PART`:

   ```script
   $ aws apigateway put-method \
     --rest-api-id $AWS_REST_ID \
     --resource-id $AWS_APIG_RESOURCE_ID \
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

5. Call `put-method-response` to set up the `200 OK` response to the method request of POST `/$AWS_APIG_PATH_PART`.

   ```script
   $ aws apigateway put-method-response \
     --rest-api-id $AWS_REST_ID \
     --resource-id $AWS_APIG_RESOURCE_ID \
     --http-method POST \
     --status-code 200
   ```

   Output:
   ```json
   {
       "statusCode": "200"
   }
   ```

6. Call `put-integration` to set up the integration of the `POST /$AWS_APIG_PATH_PART` method with a Lambda function named `$AWS_LAMBDA_NAME`.
   The function responds with "Lambda has received your message !" as specified in the Lambda code.

   ```script
   $ aws apigateway put-integration \
     --rest-api-id $AWS_REST_ID \
     --resource-id $AWS_APIG_RESOURCE_ID \
     --http-method POST \
     --type AWS \
     --integration-http-method POST \
     --uri 'arn:aws:apigateway:$AWS_REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:function:$AWS_LAMBDA_NAME/invocations'
   ```

   Output:
   ```json
   {
       "type": "AWS",
       "httpMethod": "POST",
       "uri": "arn:aws:apigateway:$AWS_REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:function:$AWS_LAMBDA_NAME/invocations",
       "passthroughBehavior": "WHEN_NO_MATCH",
       "timeoutInMillis": 29000,
       "cacheNamespace": "$AWS_APIG_RESOURCE_ID",
       "cacheKeyParameters": []
   }
   ```

7. Call `put-integration-response` to set up the integration response to pass the Lambda function output to the client as the `200 OK` method response

   ```script
   $ aws apigateway put-integration-response \
     --region $AWS_REGION \
     --rest-api-id $AWS_REST_ID \
     --resource-id $AWS_APIG_RESOURCE_ID \
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

8. Call `create-deployment` to deploy the API to the `$AWS_APIG_STAGE` stage:

   ```script
   $ aws apigateway create-deployment \
     --rest-api-id $AWS_REST_ID \
     --stage-name $AWS_APIG_STAGE
   ```

   Output:

   ```json
   {
       "id": "nink3g",
       "createdDate": 1602087417
   }
   ```

   Save the AWS Lambda invocation URL in an environment variable called `AWS_LAMBDA_INVOCATION_URL`:
   ```script
   AWS_LAMBDA_INVOCATION_URL="https://$AWS_REST_ID.execute-api.$AWS_REGION.amazonaws.com/$AWS_APIG_STAGE/$AWS_APIG_PATH_PART"
   ```

   This URL will be able to be used to make a `POST` request to invoke the Lambda.

   First, however, we need to allow API Gateway to invoke the Lambda function or else the requests will fail with `{"message":"Internal Server Error"}`.
   The next section will do just that.

   More information about creating an API and integrating it with the Lambda backend is
   [here](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-custom-integrations.html).

9. Save the new environment variables into `setEnvVars` in case you want to stop now and return to this in the future:
   ```script
   $ cat &lt;&lt;EOF >> setEnvVars


   # Added by following the instructions in REST_API.md:
   AWS_REST_ID=$AWS_REST_ID
   AWS_APIG_ROOT_ID=$AWS_APIG_ROOT_ID
   AWS_APIG_RESOURCE_ID=$AWS_APIG_RESOURCE_ID
   AWS_LAMBDA_INVOCATION_URL=$AWS_LAMBDA_INVOCATION_URL
   EOF
   ```


## Allow Lambda To Be Invoked by API Gateway Using Lambda's Resource-Based Policy

The `source-arn` parameter of the `add-permission` subcommand needs the AWS account ID and the gateway REST API ID.
The second-last token in the `source-arn` is shown as `POST`, which authorizes `POST` requests.
To allow all HTTP methods, specify `*` instead.

```script
$ aws lambda add-permission \
  --function-name $AWS_LAMBDA_NAME \
  --action lambda:InvokeFunction \
  --statement-id lambdaperms \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:$AWS_REGION:$AWS_ACCOUNT_ID:$AWS_REST_ID/*/POST/*"
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
  "Resource": "$AWS_LAMBDA_ARN",
  "Condition": {
    "ArnLike": {
      "AWS:SourceArn": "arn:aws:execute-api:$AWS_REGION:$AWS_ACCOUNT_ID:$AWS_REST_ID/*/POST/*"
    }
  }
}
```


## Invoke the AWS Lambda from a POST

Now you can make `POST` requests to the API gateway's invocation URL like this:

```script
$ curl --no-progress-meter \
  -d 'param1=value1' \
  -d 'param2=value2' \
  "$AWS_LAMBDA_INVOCATION_URL"
```

Or even:

```script
$ curl --no-progress-meter \
  -d "company='Slate Rock and Gravel Company'" \
  -d "emailAddress=fred@flintstone.com'" \
  -d "firstName=Fred" \
  -d "lastName=Flintstone" \
  -d "notes=None" \
  -d "phone=555-123-4567" \
  -d "title=Slob" \
  "$AWS_LAMBDA_INVOCATION_URL"
```


## Next Step
Continue on to [Debugging](DEBUGGING.md).
