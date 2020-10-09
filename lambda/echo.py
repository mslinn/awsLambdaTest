import ast, base64, json, logging, ptvsd, urllib.parse

def double_quote(context_property):
    return f'"context.{function_name}"'

def detailJson(event: dict, context) -> dict:
    http_method: str = event["httpMethod"]
    path: str = event["path"]
    is_base64_encoded: bool = event["isBase64Encoded"]
    body: str = base64.b64decode(event['body']).decode('utf8') if is_base64_encoded else event['body']
    name_values = urllib.parse.parse_qsl(body)
    name_values_dict = { item[0]: item[1] for item in name_values }

    # See https://docs.aws.amazon.com/lambda/latest/dg/python-context.html
    return {
        "statusCode": 200,
        "http_method": http_method,
        "is_base64_encoded": is_base64_encoded,
        "path": path,
        "name_values_dict": name_values_dict,
        "body": body,
        "event": json.dumps(event),
        "context": json.dumps({
            "function_name": double_quote(function_name),
            "invoked_function_arn": double_quote(invoked_function_arn),
            "memory_limit_in_mb": double_quote(memory_limit_in_mb),
            "aws_request_id": double_quote(aws_request_id),
            "log_group_name": double_quote(log_group_name),
            "log_stream_name": double_quote(log_stream_name)
        })
    }

def lambda_handler(event: dict, context):
    """Sample pure Lambda function

    Parameters
    ----------
    event: dict, required
        API Gateway Lambda Proxy Input Format

        Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

    context: object, required
        Lambda Context runtime methods and attributes

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

    Returns
    ------
    API Gateway Lambda Proxy Output Format: dict

        Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    """

    logging.basicConfig(
        format = '%(levelname)s %(message)s',
        level = logging.DEBUG
    )

    logging.info(f"context type: {type(context)}")
    #logging.info(event)
    #logging.info(context)

    # See https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-using-debugging-python.html
    # Enable ptvsd on 0.0.0.0 address and on port 5890 that we'll connect later with our IDE
    #ptvsd.enable_attach(address=('0.0.0.0', 5890), redirect_output=True)
    #ptvsd.wait_for_attach()

    operation: str = event['httpMethod']
    logging.info(operation)

    if False:
        is_base64_encoded: bool = event["isBase64Encoded"]
        body: str = base64.b64decode(event['body']).decode('utf8') if is_base64_encoded else event['body']
        name_values = urllib.parse.parse_qsl(body)
        name_values_dict = { item[0]: item[1] for item in name_values }

        return {
            "statusCode": 200,
            "isBase64Encoded": is_base64_encoded,
            "body": body,
            "name_values_dict": name_values_dict
        }
    else:
        return detailJson(event, context)
