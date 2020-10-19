I have suggestions for product development and documentation, and I have questions:

1) I renamed the GitHub project containing AWS CLI scripts to [awsLambdaTutorial.cli](https://github.com/mslinn/awsLambdaTutorial.cli).

2) Any number of API gateways with the same name are possible (however, each API has a unique `ApiId`). I did not expect that. All of the documentation (AWS CLI, language bindings and web console) should clearly state that this is possible, and should explain what the benefits of this design decision are, as well as the problems that inadvertently created APIs that have the same name could create. Is this design decision due to the need for supporting multiple stages? If so, I would like to suggest that the documentation for AWS CLI, all language bindings and the web console tell the user that best practices for naming APIs include the name of the stage; for example `marketing_dev` and `marketing_$default`. Are there any other benefits provided by the ability to have multiple API Gateways with identical names?

3) The [API Gateway Developer Guide](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop.html) discusses using the web console and AWS CLI, but does not discuss language bindings. This is a problem because, as I will show next, the programming interfaces for all three are not completely equivalent.

4) The [API Gateway web console](https://console.aws.amazon.com/apigateway) shows different information for an API's Details (after clicking on the API entry) than is available from [AWS CLI](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/apigatewayv2/get-apis.html). According to the documentation (which I have learned is misleading in many places, as I will show) and the [information returned by the Python binding](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/apigatewayv2.html#ApiGatewayV2.Client.get_apis) is also different. It would be most helpful to be able to read a detailed discussion of how the web console fields map to AWS CLI commands and results, and language binding methods and results.

   a) This is what is shown on the web console documentation (sorted alphabetically): `API ID`, `Attached deployment`, `Auto deploy`, `Created`, `Default endpoint` (boolean), `Description`, `Invoke URL`, `Last updated`, `Protocol`, `Stage name`, `Tags`.

   b) This is what is documented to be returned for each API by AWS CLI (sorted alphabetically): `ApiEndpoint` (URL), `ApiKeySelectionExpression`, `ApiId`, `CreatedDate`, `Name`, `ProtocolType`, `RouteSelectionExpression`, `Tags`.

   c) This is what is documented to be returned for each API from the Python language binding (sorted alphabetically): `ApiEndpoint` (URL), `ApiGatewayManaged`, `ApiId`, `ApiKeySelectionExpression`, `CorsConfiguration`, `CreatedDate`, `Description`, `DisableExecuteApiEndpoint`, `DisableSchemaValidation`, `ImportInfo`, `Name`, `RouteSelectionExpression`, `Tags`, `Version`, `Warnings`.

   d) This is missing from the web console but is found in the documentation for the Python language binding and AWS CLI: `ApiKeySelectionExpression`, `CorsConfiguration`, `DisableExecuteApiEndpoint`, `DisableSchemaValidation`, `ImportInfo`, `RouteSelectionExpression`, `Version`, `Warnings`. I learned that `ApiKeySelectionExpression`, `DisableExecuteApiEndpoint` and `RouteSelectionExpression` are only returned for WebSocket APIs; `CorsConfiguration` is only returned for HTTP APIs; the Python language binding documentation for the returned fields should mention this.

   e) Is the web console's `Invoke URL` the same as `ApiEndpoint` (a URL) for AWS CLI and the Python binding?

   f) Other than web console's `Invoke URL`, the following is missing from the information returned by AWS CLI: `Attached deployment`, `Auto deploy`, `Default endpoint` (boolean), `Description`.

   g) Other than web console's "Invoke URL", the following is missing from the Python binding: `Attached deployment`, `Auto deploy`, `Default endpoint` (boolean). `Description` is present, unlike AWS CLI's documented response.

5) Exactly what does `Auto deploy` mean for managed APIs?

   a) What is deployed, changes to an API definition such as permissions, paths, integrations, or does it also pertain to Lambda functions and other resources behind the API? The deployment description is not helpful: "Automatic deployment triggered by changes to the Api configuration". Since this appears only for Stage details in the web console, and that page also shows a `Deployment ID`, it seems likely that `Automatic deployment` pertains to the deployment of the specific stage shown. None of this information is apparent to people reading the AWS CLI docs or the docs for the Python bindings.

   b) Is it true that `autodeploy` is meaningless for `quick create` HTTP APIs, because no changes are possible?

6) The [API Gateway Developer Guide](https://docs.aws.amazon.com/apigateway/latest/developerguide/using-service-linked-roles.html) says `You can delete a service-linked role only after first deleting the related resources`. However, I was able to delete a role (`arn:aws:iam::031372724784:role/lambda-ex`) using AWS CLI without deleting the Lambda function first (`arn:aws:lambda:us-east-1:031372724784:function:BackendLambda`). Is this a bug?

7) The [AWS Developer Guide](https://docs.aws.amazon.com/apigateway/latest/developerguide/using-service-linked-roles.html#create-slr) also says `You don't need to manually create a service-linked role. When you create an API, custom domain name, or VPC link in the AWS Management Console, the AWS CLI, or the AWS API, API Gateway creates the service-linked role for you.` However, [elsewhere in that same document](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html#permissions-executionrole-api) the example code shown explicitly includes that information in `trust-policy.json` and inline for the `create-role` subcommand, then it instructs the reader `To add permissions to the role, use the attach-policy-to-role command.`

   a) Are both of these required, or would this be equivalent: `aws iam create-role --role-name lambda-ex`? When documentation describes something in different ways in different sections without an explanation that compares and contrasts the two expressions the reader often becomes confused. I know I am.

7) How are routes related to integrations?

   a) The [AWS CLI docs](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/apigatewayv2/create-api.html) says `--route-key (string) This property is part of quick create. If you don't specify a routeKey, a default route of $default is created. The $default route acts as a catch-all for any request made to your API, for a particular stage. The $default route key can't be modified. You can add routes after creating the API, and you can update the route keys of additional routes. Supported only for HTTP APIs.`

   b) The [Python bindings docs](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/apigatewayv2.html#ApiGatewayV2.Client.create_api) says this about `RouteKey`: `RouteKey (string) -- This property is part of quick create. If you don't specify a routeKey, a default route of $default is created. The $default route acts as a catch-all for any request made to your API, for a particular stage. The $default route key can't be modified. You can add routes after creating the API, and you can update the route keys of additional routes. Supported only for HTTP APIs.`

   c) I used the Python language binding to quick create an HTTP API, then I used the Python binding to examine the integration for the HTTP API with id `ma4w4rc9gi`. I found method `ANY` as expected:
`IntegrationId: fsikieq, IntegrationMethod: POST, IntegrationUri: arn:aws:lambda:us-east-1:031372724784:function:echoLambdaHTTP`

   d) The [web console](https://console.aws.amazon.com/apigateway/main/develop/integrations/attach?api=ma4w4rc9gi&integration=fsikieq&region=us-east-1&routes=wbygs9i) shows method `ANY`, not `POST`. Is this a bug?

   e) Why show an HTTP method for an integration AND a route? Is this due to a mapping or transformation? Once again I am confused.

8) There are many places in the published documentation for the Python bindings that show more fields in the response than are actually returned.

   a) For example, [`get_api` is documented](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/apigatewayv2.html#ApiGatewayV2.Client.get_api) to return a dict containing many key/value pairs, however the following keys are documented but not returned for a quick HTTP API: `ApiGatewayManaged`, `CorsConfiguration`, `DisableSchemaValidation`, `DisableExecuteApiEndpoint`, `ImportInfo`, `Version` and `Warnings`.

   b) I have not checked to see if these fields are returned for non-quick HTTP APIs, or if they are returned by REST APIs. The documentation needs to be corrected and enhanced.

9) None of the AWS CLI subcommands documented have a proper explanation of what the subcommands do.

   a) For example, [`get_integration_response`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/apigatewayv2/get-integration.html) merely says `Gets an Integration.` This is useless information.

   b) The same documentation then points to the APIG documentation for the [low-level REST interface underlying the AWS CLI subcommand](https://docs.aws.amazon.com/goto/WebAPI/apigatewayv2-2018-11-29/GetIntegration) which is similarly useless: `Gets an Integration.`

   c) Instead of pointing to the documentation for the underlying implementation, the subcommand documentation should point to a section in the Programming Guide, wherever that might be (I could not find it.)

10) None of the methods documented for the Python bindings have a proper explanation of what the methods do.

    a) For example, [`get_integration_response`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/apigatewayv2.html#ApiGatewayV2.Client.get_integration) merely says `Gets an Integration.` This is useless information.

    b) The same documentation then points to the APIG documentation for the [low level REST interface underneath the Python bindings](https://docs.aws.amazon.com/apigatewayv2/latest/api-reference/apis-apiid-integrations-integrationid.html#apis-apiid-integrations-integrationidget) which is similarly useless: `Gets an Integration.`

11) If one searches Google for [`aws cli get http api`](https://docs.aws.amazon.com/cli/latest/reference/apigatewayv2/get-apis.html) the first 4 results all point to the same documentation page.

    a) Notice that the url for that page suggests that this is the `latest` documentation, but the user is then told that this is not the case: `AWS CLI version 2, the latest major version of AWS CLI, is now stable and recommended for general use. To view this page for the AWS CLI version 2, click here. For more information see the AWS CLI version 2 installation instructions and migration guide.`

    b) The latest (and current) information is actually [here](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/apigatewayv2/get-apis.html). After working for many hours I sometimes sometimes forget to click through to the current information. The URLs should be corrected so that `latest` is not the 'latest for version 1', but instead point to the currently recommended information, which is version 2 at the moment.
