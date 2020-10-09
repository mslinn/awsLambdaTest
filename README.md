#  Command Line AWS Lambda, API Gateway and IAM

This GitHub project documents how to use a command line to define and invoke an AWS Lambda function.
Invocation will be via unsigned synchronous requests using two types of API Gateways: HTTP and REST.
The reason for not requiring a request to be signed is so the API is publicly accessible.
This means no security credentials are necessary to invoke the Lambda functions behind their API Gateways.

These instructions also detail how to create a short Python Lambda function that merely echoes its parameters, but you can substitute your own Lambda function if you modify the parameters passed to it appropriately.

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

3. Examine `makeSetEnvVars.sh` and make any changes you like for the environment variables that are indicated as being modifiable.

3. Run the `makeSetEnvVars.sh` script to create `setEnvVars.sh`,
   which defines the environment variables that this tutorial uses when it is processed by the bash `source` command.

   ```shell
   $ ./makeSetEnvVars.sh
   $ source setEnvVars.sh
   ```

The pages that follow will define additional environment variables.


## Bash Scripts

This project provides two bash scripts: `capture` and `extract` for working with commands that generate JSON to `stdout`.

 - The `capture` script runs commands and saves `stdout` to a hidden file called `.result`.
 - The `extract` script assumes that `.result` contains JSON and extracts values from it using `jq`.
   The same values are echoed to `STDOUT` and `STDERR` so the script can assign output to an environment variable and also display it.


## Next Step

Continue on to [Create an AWS Lambda Function](LAMBDA.md).


## Acknowledgements

I would like to thank Raju J. of Amazon Web Services for his kind and thoughtful input.
