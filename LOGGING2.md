# Logging Continued
## Log Retention Policy

CloudWatch logs build up forever unless they are automatically deleted by specifying a retention policy.
The retention policy shown below only keeps logs for one week.
```script
$ aws logs put-retention-policy \
  --log-group-name log_group1 \
  --retention-in-days 7
```


```script
$ aws apigatewayv2 update-stage --api-id $AWS_APIG_HTTP_ID \
    --stage-name '$default' \
    --access-log-settings "{
        \"DestinationArn\": \"arn:aws:logs:$AWS_REGION:$AWS_ACCOUNT_ID:log-group:$AWS_APIG_HTTP_LOG_GROUP\",
        \"Format\": "$context.identity.sourceIp - - [$context.requestTime] \"\$context.httpMethod $context.routeKey \$context.protocol\" \$context.status \$context.responseLength \$context.requestId"
      }"
```

For REST APIs:
```script
$ aws apigatewayv2 update-stage --api-id $AWS_APIG_REST_ID \
    --stage-name $AWS_APIG_STAGE \
    --access-log-settings '{"DestinationArn": "arn:aws:logs:region:account-id:log-group:log-group1", "Format": "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"}'
```


### Tailing CloudWatch Logs From a Terminal
Use [cw](https://www.lucagrulla.com/cw/).

#### WSL & WSL2 Installation
To install on Windows Subsystem for Linux 1 & 2, which do not support `snap`:
```script
cd ~/Downloads
wget https://github.com/lucagrulla/cw/releases/download/v3.3.0/cw_amd64.deb && sudo dpkg -i cw_amd64.deb
cd -
```


### Installation on Other Debian-Based Linux Distros
To install on Debian/Ubuntu:

```script
snap install cw-sh
sudo snap connect cw-sh:dot-aws-config-credentials
sudo snap alias cw-sh.cw cw
```


### Usage
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


#### Fuzzy Completion with `fzf`

[`fzf`](https://github.com/junegunn/fzf) works well with `cw` for tab completion.
Installation is documented [here](https://github.com/junegunn/fzf#using-linux-package-managers).
For example:

```script
$ cw tail -f "$(cw ls groups | fzf)"
```

Use <kbd>tab</kbd> to select multiple log groups:
```script
$ cw tail -f $(cw ls groups | fzf -m | tr '\n' ' ')
```


### Deleting CloudWatch Logs
```script
$ aws logs describe-log-groups --log-group-name-prefix log-group1 \
  | jq '.[][]["logGroupName"]' \
  cut -d '"' -f 2 | \
    while read LOG_GROUP
    do
      aws logs delete-log-group --log-group-name $AWS_LOG_GROUP
    done
```


## Next Step
Continue on to [Debugging](DEBUGGING.md).
