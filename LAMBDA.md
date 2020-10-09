# Create an AWS Lambda Function

The instructions on this page are common to both the REST and the HTTP APIs.
If you wish to type along and have not already performed the instructions on the [previous page](README.md) please do so now.

The commands necessary to accomplish all of the instructions on this page are [summarized](#user-content-summary) at the end of this page.

[The AWS CLI Getting Started documentation](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-awscli.html)
details the steps required for creating the lambda function via the command line.
These instructions are based on
[How do I build an AWS Lambda deployment package for Python?](https://aws.amazon.com/premiumsupport/knowledge-center/build-python-lambda-deployment-package/).

The [ATS sam build and package](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-build.html)
commands can also build AWS Lambda functions into zip file, but this document describes a simpler approach.

More information about creating a Lambda deployment package for Python is available
[here](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html).


## Resuming Your Work

The instructions on this page use the following environment variables from `setEnvVars.sh`, which I provided as:

```script
AWS_LAMBDA_DIR=lambda
AWS_LAMBDA_NAME=BackendLambda
AWS_LAMBDA_ZIP=function.zip
AWS_LAMBDA_RUNTIME=python3.8
AWS_LAMBDA_HANDLER=echo.lambda_handler
AWS_LAMBDA_ARN="arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:function:$AWS_LAMBDA_NAME"
```

If you are resuming these instructions in a new shell, load the environment variables from `setEnvVars.sh`:

```script
$ source setEnvVars.sh
```


## Move to the `$AWS_LAMBDA_DIR` Directory
Most of our work for this page will be done in the $AWS_LAMBDA_DIR subdirectory, so make it current:

```shell
$ cd "$AWS_LAMBDA_DIR"
```


## A Very Simple Python Program for an AWS Lambda Function
As a very simple example, here is a sample Python 3.8 program that merely prints the incoming event.
Although this program could be incorporated into an AWS Lambda function,
we aren't going to use this program in this example.
Note that the file containing the program should be called `blah.py` in order to match the handler name (`blah.my_handler`):

```python
import json

def my_handler(event, context):
    print(event)
    return {
        'message': 'Lambda has received your message !'
    }
```


## The Actual Python Program for Our AWS Lambda Function

[echo.py](lambda/echo.py) contains Python code for echoing an API Gateway request, including any HTTP `x-www-form-urlencoded` data.

The file [`requirements.txt`](https://pip.pypa.io/en/stable/user_guide/#requirements-files)
in the `$AWS_LAMBDA_DIR` directory looks like this:

```
requests
ptvsd
boto3
```


## Build a ZIP Containing the AWS Lambda Function and Dependencies

Now we can build a zip file containing the Lambda function and its dependencies.
The requirements file is updated by this process as well.

If you get a permission denied error when running the following command,
rerun it and preface the command with `sudo -H`:

```
$ pip3 install -r requirements.txt -t .
Warning: No xauth data; using fake authentication data for X11 forwarding.
X11 forwarding request failed on channel 0
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 8 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 568 bytes | 568.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0)
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To github.com:mslinn/awsLambdaTest.git
   18e4511..af2157c  master -> master
mslinn@gojira:/mnt/_/work/experiments/aws/awsLambdaTest$ pip3 install -r "$AWS_LAMBDA_DIR/requirements.txt" -t "$AWS_LAMBDA_DIR"
Collecting requests
  Using cached requests-2.24.0-py2.py3-none-any.whl (61 kB)
Collecting ptvsd
  Using cached ptvsd-4.3.2-py2.py3-none-any.whl (4.9 MB)
Collecting boto3
  Downloading boto3-1.15.15-py2.py3-none-any.whl (129 kB)
     |████████████████████████████████| 129 kB 1.9 MB/s
Collecting idna<3,>=2.5
  Using cached idna-2.10-py2.py3-none-any.whl (58 kB)
Collecting chardet<4,>=3.0.2
  Using cached chardet-3.0.4-py2.py3-none-any.whl (133 kB)
Collecting certifi>=2017.4.17
  Using cached certifi-2020.6.20-py2.py3-none-any.whl (156 kB)
Collecting urllib3!=1.25.0,!=1.25.1,<1.26,>=1.21.1
  Using cached urllib3-1.25.10-py2.py3-none-any.whl (127 kB)
Collecting jmespath<1.0.0,>=0.7.1
  Downloading jmespath-0.10.0-py2.py3-none-any.whl (24 kB)
Collecting s3transfer<0.4.0,>=0.3.0
  Downloading s3transfer-0.3.3-py2.py3-none-any.whl (69 kB)
     |████████████████████████████████| 69 kB 1.2 MB/s
Collecting botocore<1.19.0,>=1.18.15
  Downloading botocore-1.18.15-py2.py3-none-any.whl (6.7 MB)
     |████████████████████████████████| 6.7 MB 4.3 MB/s
Collecting python-dateutil<3.0.0,>=2.1
  Using cached python_dateutil-2.8.1-py2.py3-none-any.whl (227 kB)
Collecting six>=1.5
  Using cached six-1.15.0-py2.py3-none-any.whl (10 kB)
Installing collected packages: idna, chardet, certifi, urllib3, requests, ptvsd, jmespath, six, python-dateutil, botocore, s3transfer, boto3

Successfully installed boto3-1.15.15 botocore-1.18.15 certifi-2020.6.20 chardet-3.0.4 idna-2.10 jmespath-0.10.0 ptvsd-4.3.2 python-dateutil-2.8.1 requests-2.24.0 s3transfer-0.3.3 six-1.15.0 urllib3-1.25.10
```

If you had to preface the previous command with `sudo -H`,
change the owner and group of the contents in the `$AWS_LAMBDA_DIR` directory from `root:root`
to your userid and group:

```shell
$ sudo chown -R $USER: .
```

Files and subdirectories in `$AWS_LAMBDA_DIR` are now:

```
echo.py
bin/
boto3/
boto3-1.15.15.dist-info/
botocore/
botocore-1.18.15.dist-info/
certifi/
certifi-2020.6.20.dist-info/
chardet/
chardet-3.0.4.dist-info/
dateutil/
idna/
idna-2.10.dist-info/
jmespath/
jmespath-0.10.0.dist-info/
ptvsd/
ptvsd-4.3.2.dist-info/
__pycache__/
python_dateutil-2.8.1.dist-info/
requests/
requests-2.24.0.dist-info/
requirements.txt
s3transfer/
s3transfer-0.3.3.dist-info/
six-1.15.0.dist-info/
six.py
urllib3/
urllib3-1.25.10.dist-info/
```


## Update `requirements.txt`

Type the following:

```shell
pip3 freeze > requirements.txt
```

`requirements.txt` now contains all the dependencies, including transient dependencies:
```
apturl==0.5.2
arrow==0.16.0
attrs==20.2.0
aws-lambda-builders==1.1.0
aws-sam-cli==1.2.0
aws-sam-translator==1.26.0
awscli==1.18.69
beautifulsoup4==4.8.2
binaryornot==0.4.4
blinker==1.4
boto3==1.14.60
boto3-stubs==1.15.0.0
botocore==1.17.60
catfish==1.4.13
certifi==2019.11.28
chardet==3.0.4
chevron==0.13.1
cliapp==1.20180812.1
Click==7.0
cmdtest==0.32+git
colorama==0.4.3
command-not-found==0.3
cookiecutter==1.6.0
cryptography==2.8
cupshelpers==1.0
dateparser==0.7.6
dbus-python==1.2.16
dearpygui==0.1.0b13
defer==1.0.6
distro==1.4.0
distro-info===0.23ubuntu1
docker==4.2.2
docutils==0.15.2
entrypoints==0.3
Flask==1.0.4
future==0.18.2
gitdb==4.0.5
GitPython==3.1.8
html5lib==1.0.1
httpie==1.0.3
httplib2==0.14.0
idna==2.8
itsdangerous==1.1.0
Jinja2==2.11.2
jinja2-time==0.2.0
jmespath==0.9.5
jsonschema==3.2.0
keyring==18.0.1
keyrings.alt==3.4.0
language-selector==0.1
launchpadlib==1.10.13
lazr.restfulclient==0.14.2
lazr.uri==1.0.3
lightdm-gtk-greeter-settings==1.2.2
lxml==4.5.0
macaroonbakery==1.3.1
mailchimp-marketing==3.0.15
Markdown==3.1.1
MarkupSafe==1.1.1
meld==3.20.2
menulibre==2.2.1
mugshot==0.4.2
netifaces==0.10.4
oauth==1.0.1
oauthlib==3.1.0
olefile==0.46
onboard==1.4.1
packaging==20.4
pbr==5.5.0
pexpect==4.6.0
Pillow==7.0.0
poyo==0.5.0
protobuf==3.6.1
psutil==5.5.1
ptvsd==4.3.2
pyasn1==0.4.2
pycairo==1.16.2
pycrypto==2.6.1
pycups==1.9.73
pycurl==7.43.0.2
Pygments==2.3.1
PyGObject==3.36.0
PyJWT==1.7.1
pylibacl==0.5.4
pymacaroons==0.13.0
PyNaCl==1.3.0
pyparsing==2.4.7
PyQt5==5.14.1
pyRFC3339==1.1
pyrsistent==0.17.3
PySimpleSOAP==1.16.2
python-apt==2.0.0+ubuntu0.20.4.1
python-dateutil==2.7.3
python-debian===0.1.36ubuntu1
python-debianbts==3.0.2
python-magic==0.4.16
pytz==2020.1
pyxattr==0.6.1
pyxdg==0.26
PyYAML==5.3.1
realityengines==0.9.1
regex==2020.7.14
reportlab==3.5.34
requests==2.23.0
requests-unixsocket==0.2.0
roman==2.0.0
rsa==4.0
s3cmd==2.0.2
s3transfer==0.3.3
screen-resolution-extra==0.0.0
SecretStorage==2.3.1
serverlessrepo==0.1.9
sgt-launcher==0.2.5
simplejson==3.16.0
sip==4.19.21
six==1.14.0
smmap==3.0.4
soupsieve==1.9.5
ssh-import-id==5.10
sshconf==0.0.0
systemd-python==234
testresources==2.0.1
tomlkit==0.5.8
ttystatus==0.38
tzlocal==2.1
ubuntu-advantage-tools==20.3
ubuntu-drivers-common==0.0.0
ufw==0.36
unattended-upgrades==0.1
urllib3==1.25.8
vboxapi==1.0
wadllib==1.3.3
webencodings==0.5.1
websocket-client==0.57.0
Werkzeug==1.0.1
whichcraft==0.6.1
xcffib==0.8.1
xkit==0.0.0
youtube-dl==2020.9.20
zope.interface==4.7.1
```

## Summary

```shell
source setEnvVars.sh
cd "$AWS_LAMBDA_DIR"
# sudo chown -R $USER: .
pip3 install -r requirements.txt -t .
pip3 freeze > requirements.txt
zip -r ../$AWS_LAMBDA_ZIP .
cd -
```

You can examine the files in the created zip file without unzipping them:
```shell
$ unzip -l $AWS_LAMBDA_ZIP | less
```

My zip file had 2463 files in it so I won't list them here.


## Updating Lambda Function Code
To update the Lambda function with modified code, recreate `$AWS_LAMBDA_ZIP` and then call `update-function-code`:

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
    "Handler": "echo.lambda_handler",
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


## Renaming the Lambda Function Entry Point

If the Lambda function modification included changing the name of the main Python program file, and/or renaming the hander function,
tell AWS about the modified entry point name with `update-function-configuration`.

You should first change the value of `AWS_LAMBDA_HANDLER` in [`makeSetEnvVars.sh`](makeSetEnvVars.sh) to suit.
For example, if the new handler is the method `ooh_baby` in `my_file.py`, you could change the value from the command line like this:

```shell
$ sed -i '/AWS_LAMBDA_HANDLER/c\AWS_LAMBDA_HANDLER=my_file.ooh_baby' makeSetEnvVars.sh
```

Verify that it worked:

```shell
$ grep AWS_LAMBDA_HANDLER makeSetEnvVars.sh
AWS_LAMBDA_HANDLER=my_file.ooh_baby
```

Now re-source `setEnvVars.sh` so the new value of the `AWS_LAMBDA_NAME` environment variable is used, and tell AWS about the change:

```script
$ source setEnvVars.sh

$ aws lambda update-function-configuration \
  --function-name $AWS_LAMBDA_NAME \
  --handler $AWS_LAMBDA_HANDLER
```

Output will be something like:
```json
{
    "FunctionName": "$AWS_LAMBDA_NAME",
    "FunctionArn": "$AWS_LAMBDA_ARN",
    "Runtime": "$AWS_LAMBDA_RUNTIME",
    "Role": "$AWS_ROLE_ARN",
    "Handler": "$AWS_LAMBDA_HANDLER",
    "CodeSize": 14747364,
    "Description": "",
    "Timeout": 3,
    "MemorySize": 128,
    "LastModified": "2020-10-09T14:47:13.787+0000",
    "CodeSha256": "gxjzEYIfb5vlmPcH3kFIdaINy7xrZjke9e/uCTbHY2k=",
    "Version": "$LATEST",
    "TracingConfig": {
        "Mode": "PassThrough"
    },
    "RevisionId": "26a1facd-0401-46f7-ac6b-fbfdc661dd57",
    "State": "Active",
    "LastUpdateStatus": "Successful"
}
```


## Other Modifications To the Lambda Function

To learn about the other aspects of the lambda function that can be modified, view the output of:

```script
$ aws lambda update-function-configuration help
```


## Next Step

Continue on to [Create IAM Role for the AWS Lambda Function and Register the Lambda Function](REGISTER.md).
