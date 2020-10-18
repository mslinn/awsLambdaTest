# Enable CloudWatch Logging

This optional step makes it easier to figure out problems.

If you wish to type along and have not already performed the instructions on the previous page, which is either
[HTTP API](HTTP_API.md) or [REST API](REST_API.md), please do so now.

If you are resuming these instructions in a new shell, load the environment variables from `settings.py`:

```script
$ source settings.py
```

## CloudWatch Logging

See the [API Gateway Developer Guide](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-logging.html) for more information on enabling [CloudWatch logging](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html)
for a particular API Gateway stage.

```script
$ aws logs create-log-group --log-group-name log-group1
```

For HTTP APIs:
```script
$ aws apigatewayv2 update-stage --api-id $AWS_APIG_HTTP_ID \
    --stage-name '$default' \
    --access-log-settings '{"DestinationArn": "arn:aws:logs:region:account-id:log-group:log-group1", "Format": "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"}'
```

For REST APIs:
```script
$ aws apigatewayv2 update-stage --api-id $AWS_APIG_REST_ID \
    --stage-name $AWS_APIG_STAGE \
    --access-log-settings '{"DestinationArn": "arn:aws:logs:region:account-id:log-group:log-group1", "Format": "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"}'
```

### Tailing CloudWatch Logs From a Terminal
Use [cw](https://www.lucagrulla.com/cw/).
To install on Debian/Ubuntu:

```script
snap install cw-sh
sudo snap connect cw-sh:dot-aws-config-credentials
sudo snap alias cw-sh.cw cw
```

Tail all the streams in the CloudWatch Log group `log-group1` which was defined at the top of this section, showing times in the local time zone.
```script
$ cw tail log-group1 --local
```

If you are unsure what CloudWatch Log groups you have defined in the current AWS region, find all CloudWatch Log groups:
```script
$ cw ls groups
```
This should include `log-group1` which was defined at the top of this section.

Find all streams in a CloudWatch Log group for the current AWS region, for example `log-group1`:
```script
$ cw ls streams log-group1
```

Tail just the streams that are named with the prefix `log-stream-prefix` in the CloudWatch Log group `log-group1` which was defined for the current AWS region at the top of this section, showing times in the local time zone.
```script
$ cw tail log-group1:log-stream-prefix --local
```


### Deleting CloudWatch Logs
```script
$ aws logs describe-log-groups --log-group-name-prefix log-group1 \
  | jq '.[][]["logGroupName"]' \
  cut -d '"' -f 2 | \
    while read LOG_GROUP
    do
      aws logs delete-log-group --log-group-name $LOG_GROUP
    done
```
