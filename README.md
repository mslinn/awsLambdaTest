#  Tutorial - Command Line AWS Lambda, API Gateway and IAM

This tutorial documents how to use a command line to define and invoke an AWS Lambda function.
Invocation will be via unsigned synchronous requests using two types of API Gateways: HTTP and REST.
The reason for not requiring a request to be signed is so the API is publicly accessible.
This means no security credentials are necessary to invoke the Lambda functions behind their API Gateways.

These instructions also detail how to create a short Python Lambda function that merely echoes its parameters,
but you can substitute your own Lambda function if you modify the parameters passed to it appropriately.

The same Lambda function is invoked via two mechanisms (HTTP and REST), using the same data.
The initial steps are the same for both mechanisms.
Subsequent steps are explained separately.


## Setup

If you want to type along:

1. Install [AWS CLI](https://aws.amazon.com/cli/) and [jq](https://stedolan.github.io/jq/download/).

2. Configure AWS CLI:
   ```script
   $ aws configure
   ```

   The dialog looks like the following.
   This tutorial needs the default output format to be JSON:
   ```script
   AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
   AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
   Default region name [None]: us-east-1
   Default output format [None]: json
   ```

3. Examine the file called `setEnvVars` and make any changes you like for this tutorial's environment variables that are indicated as being modifiable.

3. Read the environment variables defined in `setEnvVars` into your shell environment by using the bash `source` command.

   ```shell
   $ source setEnvVars
   ```

The pages that follow provide values for some of the environment variables.
When a value changes the `setEnvVars` will need to be re-sourced.


## Bash Scripts

This tutorial provides 3 bash scripts: `capture`, `extract` and `updateEnvVar`.

 - The `capture` script runs commands and saves `stdout` to a hidden file called `.result`.
 - The `extract` script assumes that `.result` contains JSON and extracts a value from it using `jq`.
   The value is written to `STDOUT`.
   if an optional second argument is provided it is assumed to be the name of an environment variable
   and its value is updated in `setEnvVars`.
   Each time a value is changed in `setEnvVars` that file needs to be re-sourced.


## Next Step

Continue on to [Create an AWS Lambda Function](LAMBDA.md).


## Acknowledgements

I would like to thank Raju J. of Amazon Web Services for his kind and thoughtful input.
