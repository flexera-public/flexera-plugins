name "API GW Plugin Test"
rs_ca_ver 20161221
short_description  "![lambda](https://cdn.zapier.com/storage/developer/9e5d4603975b5382952af253c12017fb.128x128.png) ![apigw](https://pragmaticintegrator.files.wordpress.com/2016/12/search.png)"
long_description ""

import "plugins/rs_aws_apigw"
import "sys_log"

resource "rest_api", type: "rs_aws_apigw.rest_api" do
  name join(["rest_api-", last(split(@@deployment.href, "/"))])
  description "created from RS SS"
  endpointConfiguration do {
    "types" => [ "REGIONAL" ]
  } end
end

resource "resource", type: "rs_aws_apigw.resource" do
  restapi_id @rest_api.id
  parent_id ""
  pathPart "{proxy+}"
end

resource "method", type: "rs_aws_apigw.method" do
  http_method "ANY"
  restapi_id @rest_api.id
  resource_id @resource.id
  authorizationType "NONE"
  apiKeyRequired "false"
end

resource "integration", type: "rs_aws_apigw.integration" do
  http_method "ANY"
  restapi_id @rest_api.id
  resource_id @resource.id
  type "AWS_PROXY"
  httpMethod "POST"
  uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:041819229125:function:test1/invocations"
  credentials "arn:aws:iam::041819229125:role/lambda-apigw"
end

resource "deployment", type: "rs_aws_apigw.deployment" do
  restapi_id @rest_api.id
  stageName "demo"
end

operation "launch" do
  definition "launch"
end

define launch(@rest_api, @resource, @method, @integration, @deployment) return @rest_api, @resource, @method, @integration, @deployment do

  $rest_api = to_object(@rest_api)
  $rest_api_fields = $rest_api["fields"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Provision rest_api")
  call sys_log.detail($rest_api)
  call rs_aws_apigw.start_debugging()
  @rest_api = rs_aws_apigw.rest_api.create($rest_api_fields)
  call rs_aws_apigw.stop_debugging()
  $rest_api = to_object(@rest_api)
  call sys_log.detail(to_s($rest_api))

  call rs_aws_apigw.start_debugging()
  @existing_resources = @rest_api.resources()
  call rs_aws_apigw.stop_debugging()
  $existing_resource = to_object(@existing_resources)
  call sys_log.detail(to_s($existing_resource))
  $parent_id = $existing_resource["details"][0]["_embedded"]["item"]["id"]
  $resource = to_object(@resource)
  $resource["fields"]["parent_id"] = $parent_id

  $resource_fields = $resource["fields"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Provision resource")
  call sys_log.detail($resource)
  call rs_aws_apigw.start_debugging()
  @resource = rs_aws_apigw.resource.create($resource_fields)
  call rs_aws_apigw.stop_debugging()
  $resource = to_object(@resource)
  call sys_log.detail(to_s($resource))

  $method = to_object(@method)
  $method_fields = $method["fields"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Provision method")
  call sys_log.detail($method)
  call rs_aws_apigw.start_debugging()
  @method = rs_aws_apigw.method.create($method_fields)
  call rs_aws_apigw.stop_debugging()
  $method = to_object(@method)
  call sys_log.detail(to_s($method))

  $integration = to_object(@integration)
  $integration_fields = $integration["fields"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Provision integration")
  call sys_log.detail($integration)
  call rs_aws_apigw.start_debugging()
  @integration = rs_aws_apigw.integration.create($integration_fields)
  call rs_aws_apigw.stop_debugging()
  $integration = to_object(@integration)
  call sys_log.detail(to_s($integration))

  $deployment = to_object(@deployment)
  $deployment_fields = $deployment["fields"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Provision deployment")
  call sys_log.detail($deployment)
  call rs_aws_apigw.start_debugging()
  @deployment = rs_aws_apigw.deployment.create($deployment_fields)
  call rs_aws_apigw.stop_debugging()
  $deployment = to_object(@deployment)
  call sys_log.detail(to_s($deployment))
end