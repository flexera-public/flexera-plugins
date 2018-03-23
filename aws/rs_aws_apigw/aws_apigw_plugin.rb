name 'aws_apigw_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - API Gateway"
long_description "Version: 1.0"
package "plugins/rs_aws_apigw"
import "sys_log"

plugin "rs_aws_apigw" do
  endpoint do
    default_scheme "https"
  end

  # https://docs.aws.amazon.com/apigateway/api-reference/resource/rest-api/
  type "rest_api" do
    href_templates "{{_links.curies[?name=='restapi'] && _links.self.href || null}}"

    field "name" do
      type "string"
      required true
    end

    field "description" do
      type "string"
    end

    field "version" do
      type "string"
    end

    field "cloneFrom" do
      type "string"
    end

    field "binaryMediaTypes" do
      type "array"
    end

    field "minimumCompressionSize" do
      type "string"
    end

    field "apiKeySource" do
      type "string"
    end

    field "endpointConfiguration" do
      type "composite"
    end

    output "_links","createdDate","description","id","name"

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/restapi-create/
    action "create" do
      verb "POST"
      path "/restapis"
      type "rest_api"
    end

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/restapi-delete/
    action "destroy" do
      verb "DELETE"
      path "$href"
    end

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/restapi-by-id/
    action "get" do
      verb "GET"
      path "$href"
      type "rest_api"
    end

    link "resources" do
      path "$href/resources"
      type "resource"
    end

    link "deployments" do
      path "$href/deployments"
      type "deployment"
    end

    provision "provision_resource"

    delete    "delete_resource"
  end

  type "resource" do
    href_templates "{{!(contains(_links.curies[*].name, 'restapi')) && contains(_links.curies[*].name, 'resource') && _links.self.href || null}}"

    field "pathPart" do
      type "string"
    end

    field "restapi_id" do
      type "string"
      location "path"
    end

    field "parent_id" do
      type "string"
      location "path"
    end

    output "_links","id","parentId","path","pathPart","_embedded"

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/resource-create/
    action "create" do
      verb "POST"
      path "/restapis/$restapi_id/resources/$parent_id"
    end

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/resource-delete/
    action "destroy" do
      verb "DELETE"
      path "$href"
    end

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/resource-by-id/
    action "get" do
      verb "GET"
      path "$href"
    end


    provision "provision_resource"

    delete    "delete_resource"
  end

  type "method" do
    href_templates "{{_links.curies[?name=='methodresponse'] && _links.self.href || null}}"

    field "http_method" do
      type "string"
      location "path"
    end

    field "restapi_id" do
      type "string"
      location "path"
    end

    field "resource_id" do
      type "string"
      location "path"
    end

    field "authorizationType" do
      type "string"
    end

    field "authorizerId" do
      type "string"
    end

    field "apiKeyRequired" do
      type "string"
    end

    field "operationName" do
      type "string"
    end

    field "requestParameters" do
      type "composite"
    end

    field "requestModels" do
      type "composite"
    end

    field "requestValidatorId" do
      type "string"
    end

    field "authorizationScopes" do
      type "array"
    end

    output "_links","apiKeyRequired","authorizationType","httpMethod"

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/method-put/
    action "create" do
      verb "PUT"
      path "/restapis/$restapi_id/resources/$resource_id/methods/$http_method"
    end

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/method-delete/
    action "destroy" do
      verb "DELETE"
      path "$href"
    end

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/method-by-http-method/
    action "get" do
      verb "GET"
      path "$href"
    end

    link "integration" do
      path "$href/integration"
      type "integration"
    end

    provision "provision_resource"

    delete    "delete_resource"
  end

  type "integration" do
    href_templates "{{!(contains(_links.curies[*].name, 'method')) && contains(_links.curies[*].name, 'integration') && _links.self.href || null}}"

    field "http_method" do
      type "string"
      location "path"
    end

    field "restapi_id" do
      type "string"
      location "path"
    end

    field "resource_id" do
      type "string"
      location "path"
    end

    field "type" do
      type "string"
    end

    field "httpMethod" do
      type "string"
    end

    field "uri" do
      type "string"
    end

    field "connectionType" do
      type "string"
    end

    field "connectionId" do
      type "string"
    end

    field "credentials" do
      type "string"
    end

    field "requestParameters" do
      type "composite"
    end

    field "requestTemplates" do
      type "composite"
    end

    field "passthroughBehavior" do
      type "string"
    end

    field "cacheNamespace" do
      type "string"
    end

    field "cacheKeyParameters" do
      type "array"
    end

    field "contentHandling" do
      type "string"
    end

    field "timeoutInMillis" do
      type "string"
    end

    output "_links","cacheKeyParameters","cacheNamespace","credentials","httpMethod","passthroughBehavior","requestParameters","requestTemplates","type","uri"

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/integration-put/
    action "create" do
      verb "PUT"
      path "/restapis/$restapi_id/resources/$resource_id/methods/$http_method/integration"
    end

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/integration-delete/
    action "destroy" do
      verb "DELETE"
      path "$href"
    end

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/method-integration/
    action "get" do
      verb "GET"
      path "$href"
    end

    provision "provision_resource"

    delete    "delete_resource"
  end

  type "deployment" do
    href_templates "{{_links.curies.name=='deployment' && _links.self.href || null}}"
    field "restapi_id" do
      type "string"
      location "path"
    end

    field "stageName" do
      type "string"
    end

    field "stageDescription" do
      type "string"
    end

    field "description" do
      type "string"
    end

    field "cacheClusterEnabled" do
      type "string"
    end

    field "cacheClusterSize" do
      type "string"
    end

    field "variables" do
      type "composite"
    end

    field "canarySettings" do
      type "composite"
    end

    output "_links","createdDate","description","id","apiSummary"

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/deployment-create/
    action "create" do
      verb "POST"
      path "/restapis/$restapi_id/deployments"
    end

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/deployment-delete/
    action "destroy" do
      verb "DELETE"
      path "$href"
    end

    # https://docs.aws.amazon.com/apigateway/api-reference/link-relation/deployment-by-id/
    action "get" do
      verb "GET"
      path "$href"
    end

    provision "provision_resource"

    delete    "delete_resource"
  end

end



resource_pool "rs_aws_apigw" do
  plugin $rs_aws_apigw
  host "apigateway.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'apigateway'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define provision_resource(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_aws_apigw.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @resource = @operation.get()
    call stop_debugging()
    call sys_log.detail(to_object(@resource))
  end
end

define delete_resource(@resource) do
  sub on_error: skip do
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary("Destroy Resource")
    call sys_log.detail(to_object(@resource))
  end
  @resource.destroy()
end

define start_debugging() do
  if $$debugging == false || logic_and($$debugging != false, $$debugging != true)
    initiate_debug_report()
    $$debugging = true
  end
end

define stop_debugging() do
  if $$debugging == true
    $debug_report = complete_debug_report()
    call sys_log.detail($debug_report)
    $$debugging = false
  end
end
