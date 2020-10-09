# Create an AWS Lambda Function

If you wish to type along and have not already performed the instructions on the [previous page](README.md) please do so now.

This step is common to both the REST and the HTTP APIs.


## Python 3.8 Code for AWS Lambda Function
[app.py](lambda/app.py) contains the code to echo an API Gateway request, including any HTTP `x-www-form-urlencoded` data.


## Build ZIP Container for AWS Lambda Function
From [How do I build an AWS Lambda deployment package for Python?](https://aws.amazon.com/premiumsupport/knowledge-center/build-python-lambda-deployment-package/):

```shell
$ pip3 install -r "$AWS_LAMBDA_DIR/requirements.txt" -t "$AWS_LAMBDA_DIR"
$ pip3 freeze >  "$AWS_LAMBDA_DIR/requirements.txt"
$ chmod -R 755 "$AWS_LAMBDA_DIR"
$ (cd "$AWS_LAMBDA_DIR"; zip -r "$AWS_LAMBDA_ZIP" .)
```

You can examine the files in the created zip file:
```shell
$ unzip -l myDeploymentPackage.zip
```

## Next Step

Continue on to [Create IAM Role for the AWS Lambda Function and Register the Lambda Function](REGISTER.md).
