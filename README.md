#  AWS Lambda Test

STEP 1: CREATE A LAMBDA FUNCTION 
=============================

A. Create an IAM role which will act as a Lamdba Execution Role. We need to allow Lamdba service to assume this role in the trust policy. This role will specify which AWS resources does the Lambda function has access to. (I am assuming Lamdba is not accessing any other AWS resources here)
	$ aws iam create-role --role-name lambda-ex --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'

B. Create a Lambda function using the below command :

	$ aws lambda create-function --function-name BackendLambda --zip-file fileb://function.zip --handler index.handler --runtime python3.7 --role arn:aws:iam::123456789012:role/lambda-ex 

Kindly note that the function.zip is a Lambda Deployment Package and has the required codes and dependencies. Also please make sure that the “function.zip” file lies in the Present Working Directory of Command Line (PWD). Please find more information about Lambda Deployment package for Python here [1]. Below is a Sample python code for Lambda function which just prints the incoming event:
====
import json

def lambda_handler(event, context):
    print(event)
    return {
        'message': ‘Lambda has received your message !’ 
    }
====

This documentation [2] explains in detail the steps required for creating the Lambda function via Command Line.

STEP 2: CREATING AN APIGATEWAY API
==============================

We are assuming the above STEP 1 created a Lambda function with ARN arn:aws:lambda:us-east-1:123456789012:function:BackendLambda

A.  Call the create-rest-api command to create an API:
$ aws apigateway create-rest-api --name "LambdaREST" --region us-east-1

Output: 
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
B. Call the get-resources command to get the root resource id:
$aws apigateway get-resources --rest-api-id te6si5ach7 --region us-east-1
 Output: 
{
    "items": [
        {
            "path": "/", 
            "id": "krznpq9xpg"
        }
    ]
}

C. Call create-resource to create an API Gateway Resource of /demo:
$ aws apigateway create-resource --rest-api-id te6si5ach7 --region us-east-1 --parent-id krznpq9xpg --path-part demo

Output: 
{
    "path": “/demo”, 
    "pathPart": “demo”, 
    "id": "2jf6xt", 
    "parentId": "krznpq9xpg"
}

D. Call put-method to create an API method request of POST /demo
$ aws apigateway put-method --rest-api-id te6si5ach7 --resource-id 2jf6xt --http-method POST --authorization-type "NONE"

Output: 
{
    "apiKeyRequired": false, 
    "httpMethod": “POST”, 
    "authorizationType": "NONE"
}

E. Call put-method-response to set up the 200 OK response to the method request of POST /demo.
$ aws apigateway put-method-response --rest-api-id te6si5ach7 --resource-id 2jf6xt --http-method POST --status-code 200

Output:
{
    "statusCode": "200"
}

F. Call put-integration to set up the integration of the POST /demo method with a Lambda function, named BackendLambda. The function responds with “Lambda has received your message !” as specified in the Lambda code.
$ aws apigateway put-integration --rest-api-id te6si5ach7 --resource-id 2jf6xt --http-method POST --type AWS --integration-http-method POST --uri 'arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:BackendLambda/invocations'

Output: 
{
    "type": "AWS",
    "httpMethod": "POST",
    "uri": "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:BackendLambda/invocations",
    "passthroughBehavior": "WHEN_NO_MATCH",
    "timeoutInMillis": 29000,
    "cacheNamespace": "2jf6xt",
    "cacheKeyParameters": []
}

G. Call put-integration-response to set up the integration response to pass the Lambda function output to the client as the 200 OK method response
$ aws apigateway put-integration-response --region us-east-1 --rest-api-id te6si5ach7 --resource-id 2jf6xt --http-method POST --status-code 200 —selection-pattern “” 

Output: 
{
    "selectionPattern": "", 
    "statusCode": "200"
}

H. Call create-deployment to deploy the API to a test stage:
$ aws apigateway create-deployment --rest-api-id te6si5ach7 --stage-name test

Now after deploying the api, your invoke URL should be : https://te6si5ach7.execute-api.us-east-1.amazonaws.com/test/demo. This URL can be used to make a POST request to invoke the backend Lambda. But before that, we will need to allow ApiGateway to invoke Lambda or else the requests will fail with InternalServerError. 

Kindly find detailed steps on creating an API and integrating it with the Lambda backend here [3]. 
STEP 3: ALLOWING LAMBDA TO GET INVOKED BY THE APIGATEWAY USING LAMBDA’S RESOURCE-BASED POLICY.
====================================================================================

$ aws lambda add-permission --function-name BackendLamdba --action lambda:InvokeFunction --statement-id lambdaperms --principal apigateway.amazonaws.com --source-arn “arn:aws:execute-api:us-east-1:394654164621:ira0fio9af/*/POST/*” --output text

Once the above steps are completed, you would be able to make POST requests to the API gateway’s invoke URL which would be usually in following pattern:

https://<rest-api-id>.execute-api.us-east-1.amazonaws.com/test/demo/

Additionally, I would also like to mention that, code/script debugging/development is out of scope for AWS Premium Support and we being support engineers are not proficient in writing production ready codes, nevertheless, I am happy to provide you with some information which might help and thus, did it on best effort basis. Kindly note that other support engineers might or might not be able to help with the same. (https://aws.amazon.com/premiumsupport/features/)

I hope the above information helped you out with the usecase. If you have any further queries or concerns please feel free to reach back and I will be more than happy to assist you further.

Have a wonderful day ahead! Take care.

REFERENCES:
[1]. https://docs.aws.amazon.com/lambda/latest/dg/python-package.html
[2]. https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-awscli.html 
[3]. https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-custom-integrations.html

We value your feedback. Please share your experience by rating this correspondence using the AWS Support Center link at the end of this correspondence. Each correspondence can also be rated by selecting the stars in top right corner of each correspondence within the AWS Support Center.

Best regards,
Raju J.
Amazon Web Services

===============================================================

To share your experience or contact us again about this case, please return to the AWS Support Center using the following URL: https://console.aws.amazon.com/support/home#/case/?displayId=7444627091&language=en

Note, this e-mail was sent from an address that cannot accept incoming e-mails.
To respond to this case, please follow the link above to respond from your AWS Support Center.

===============================================================

AWS Support:
https://aws.amazon.com/premiumsupport/knowledge-center/

AWS Documentation:
https://docs.aws.amazon.com/

AWS Cost Management:
https://aws.amazon.com/aws-cost-management/

AWS Training:
http://aws.amazon.com/training/

AWS Managed Services:
https://aws.amazon.com/managed-services/

