#  Command Line AWS Lambda, API Gateway and IAM

This documents how to use a command line to define and invoke a Lambda function.
Invocation will be via unsigned requests using two types of API Gateways: HTTP and REST.
The reason for not requiring a request to be signed is so the API is publicly accessible.
This means no security credentials are necessary to invoke the Lambda functions behind their API Gateways.

These instructions also detail how to create a short Python Lambda function that merely echoes its parameters, but you can substitute your own Lambda function if you modify the parameters passed to it appropriately.

The same Lambda function is invoked via two mechanisms (HTTP and REST), using the same data.
The initial steps are the same for both mechanisms.
Subsequent steps are explained separately.

If you want to type along:

1. Install [AWS CLI](https://aws.amazon.com/cli/) and [jq](https://stedolan.github.io/jq/download/).

2. Configure AWS CLI:
   ```script
   $ aws configure
   ```

 The remainder of these setup instructions are shown after they are introduced, all together,
 so you can copy them, perhaps edit their values, and paste them into a command line prompt.

3. Define an environment variable called `AWS_ACCOUNT_ID` by typing the following:

   ```script
   $ AWS_ACCOUNT_ID="$( aws sts get-caller-identity | jq -r .UserId )"
   ```
   You can examine the value of `AWS_ACCOUNT_ID` by typing:
   ```script
   $ echo $AWS_ACCOUNT_ID
   031772722783
   ```

4. Store the AWS region that you want to work with in an environment variable called `AWS_REGION`.
   Set this to any [valid region](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/) that you like:

   ```script
   $ AWS_REGION=us-east-1
   ```

5. Save the name of the Lambda function you wish to invoke in an environment variable called `AWS_LAMBDA_NAME`; you can provide any
   [valid name](https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#API_CreateFunction_RequestParameters)
   you like here:
   ```script
   $ AWS_LAMBDA_NAME=BackendLambda
   ```

6. Save the name of the zip file contaning the Lambda function in an environment variable called `AWS_LAMBDA_ZIP`:
   ```script
   $ AWS_LAMBDA_ZIP=function.zip  # Modify to suit your Lambda function
   ```

7. Save the runtime of the Lambda function in an environment variable called `AWS_LAMBDA_RUNTIME`:
   ```script
   $ AWS_LAMBDA_RUNTIME=python3.8  # Modify to suit your Lambda function
   ```

8. Save the entry point (AWS documentation calls this a `handler`)
   for the Lambda function in an environment variable called `AWS_LAMBDA_NAME`.
   The first portion of the value is the name of the Python source code in the zip file
   containing the handler, and the second portion of the value is the name of the handler function in that file.
   For example, if the Python source code file is called `echo.py` and
   the handler is called `handler`, the value would be:
   ```script
   $ AWS_LAMBDA_HANDLER=echo.handler  # Modify to suit your Lambda function
   ```

9. Compute the Lambda function's ARN and save in an environment variable called `AWS_LAMBDA_ARN`:
   ```script
   $ AWS_LAMBDA_ARN= "arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:function:$AWS_LAMBDA_NAME"
   ```

To summarize, copy the following to your clipboard, possibly edit the values in a text editor,
then paste the lines into a command line prompt:
```script
AWS_ACCOUNT_ID="$( aws sts get-caller-identity | jq -r .UserId )"
AWS_REGION=us-east-1  # Modify to another AWS region if you like

# Modify the following to suit your Lambda function
AWS_LAMBDA_NAME=BackendLambda
AWS_LAMBDA_ZIP=function.zip
AWS_LAMBDA_RUNTIME=python3.8
AWS_LAMBDA_HANDLER=echo.handler
AWS_LAMBDA_ARN= "arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:function:$AWS_LAMBDA_NAME"
```

The steps that follow will define additional environment variables.


## Next Step

Continue on to [Create IAM Role for the AWS Lambda Function and Register the Lambda Function](REGISTER.md).

## Acknowledgements
I would like to thank Raju J. of Amazon Web Services for his kind and thoughtful input.
