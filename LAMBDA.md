# Create an AWS Lambda Function

If you wish to type along and have not already performed the instructions on the [previous page](README.md) please do so now.

This step is common to both the REST and the HTTP APIs.

These instructions are based on
[How do I build an AWS Lambda deployment package for Python?](https://aws.amazon.com/premiumsupport/knowledge-center/build-python-lambda-deployment-package/).


## Python 3.8 Code for AWS Lambda Function
[app.py](lambda/app.py) contains the code to echo an API Gateway request, including any HTTP `x-www-form-urlencoded` data.

I created the file [`requirements.txt`](https://pip.pypa.io/en/stable/user_guide/#requirements-files)
in the `$AWS_LAMBDA_DIR` directory, and it looks like this:

```
requests
ptvsd
boto3
```

The commands necessary are summarized at the end of this page.


## Build ZIP Containing AWS Lambda Function and Dependencies

Now we can build a zip file containing the Lambda function and its dependencies.
The requirements file is updated by this process as well.

If you get a permission denied error when running the following command,
rerun it and preface the command with `sudo -H`:

```
$ pip3 install -r "$AWS_LAMBDA_DIR/requirements.txt" -t "$AWS_LAMBDA_DIR"
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
change the owner and group of the contents in the $AWS_LAMBDA_DIR directory from `root:root`
to your userid and group:

```shell
$ sudo chown -R $USER: $AWS_LAMBDA_DIR
```

Files in `$AWS_LAMBDA_DIR` are now:

```
app.py
bin/
drwxr-xr-x 10 mslinn mslinn  4096 Oct  9 08:39 boto3/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 boto3-1.15.15.dist-info/
drwxr-xr-x  7 mslinn mslinn  4096 Oct  9 08:39 botocore/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 botocore-1.18.15.dist-info/
drwxr-xr-x  3 mslinn mslinn  4096 Oct  9 08:39 certifi/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 certifi-2020.6.20.dist-info/
drwxr-xr-x  4 mslinn mslinn  4096 Oct  9 08:39 chardet/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 chardet-3.0.4.dist-info/
drwxr-xr-x  6 mslinn mslinn  4096 Oct  9 08:39 dateutil/
drwxr-xr-x  3 mslinn mslinn  4096 Oct  9 08:39 idna/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 idna-2.10.dist-info/
drwxr-xr-x  3 mslinn mslinn  4096 Oct  9 08:39 jmespath/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 jmespath-0.10.0.dist-info/
drwxr-xr-x  4 mslinn mslinn  4096 Oct  9 08:39 ptvsd/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 ptvsd-4.3.2.dist-info/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 __pycache__/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 python_dateutil-2.8.1.dist-info/
drwxr-xr-x  3 mslinn mslinn  4096 Oct  9 08:39 requests/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 requests-2.24.0.dist-info/
-rw-rw-r--  1 mslinn mslinn    21 Oct  9 08:25 requirements.txt
drwxr-xr-x  3 mslinn mslinn  4096 Oct  9 08:39 s3transfer/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 s3transfer-0.3.3.dist-info/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 six-1.15.0.dist-info/
-rw-r--r--  1 mslinn mslinn 34159 Oct  9 08:39 six.py
drwxr-xr-x  6 mslinn mslinn  4096 Oct  9 08:39 urllib3/
drwxr-xr-x  2 mslinn mslinn  4096 Oct  9 08:39 urllib3-1.25.10.dist-info/
```


## Update `requirements.txt`

```shell
(cd "$AWS_LAMBDA_DIR"; pip3 freeze >  requirements.txt)
```


## Summary

```shell
sudo -H pip3 install -r "$AWS_LAMBDA_DIR/requirements.txt" -t "$AWS_LAMBDA_DIR"
sudo chown -R $USER: $AWS_LAMBDA_DIR
(cd "$AWS_LAMBDA_DIR"; pip3 freeze >  "$AWS_LAMBDA_DIR/requirements.txt")
chmod -R 755 "$AWS_LAMBDA_DIR"
(cd "$AWS_LAMBDA_DIR"; zip -r "$AWS_LAMBDA_ZIP" .)
```

You can examine the files in the created zip file:
```shell
$ unzip -l myDeploymentPackage.zip
```

## Next Step

Continue on to [Create IAM Role for the AWS Lambda Function and Register the Lambda Function](REGISTER.md).
