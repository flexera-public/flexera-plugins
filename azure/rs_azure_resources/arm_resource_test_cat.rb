name 'ARM Resource Tagging Test CAT'
rs_ca_ver 20161221
short_description "ARM Resource Tagging Test CAT"
import "plugins/rs_azure_resource"
import 'sys_log'

parameter "subscription_id" do
  like $rs_azure_resource.subscription_id
end

resource "resource_group", type: "resource_group" do
  name join(["rsrg_", last(split(@@deployment.href, "/"))])
  cloud "AzureRM Central US"
end

resource "storage_account", type: "placement_group" do
  name join(["rssa",last(split(@@deployment.href, "/"))])
  cloud "AzureRM Central US"
  cloud_specific_attributes do {
    "account_type" => "Standard_LRS"
  } end
end

resource "my_server", type: "server" do
  name join(["rsserver_", last(split(@@deployment.href, "/"))])
  server_template find("RightLink 10.6.0 Linux Base")
  cloud "AzureRM Central US"
  network "ARM-CentralUS"
  subnets "default"
  instance_type "Standard_DS2_v2"
  security_groups "default"
  associate_public_ip_address "false"
  cloud_specific_attributes do {
    "root_volume_type_uid" => "Standard_LRS",
    "availability_set" => join(["availability-set_", last(split(@@deployment.href, "/"))])
  } end
end

operation "launch" do
  definition "launch"
end 

define launch($subscription_id, @resource_group, @storage_account, @my_server) return @resource_group, @storage_account, @my_server do
  provision(@resource_group)
  @@deployment.update(deployment: {resource_group: @resource_group.href})
  provision(@storage_account)
  provision(@my_server)
  
  # Tag via RightScale API
    $rs_tags = 'azure:from_rs_api=true'

    # Tag the Resource Group
    sub on_error: skip do
      rs_cm.tags.multi_add(resource_hrefs: @@deployment.href[],tags:[$rs_tags])  
    end

    # Tag the server
    rs_cm.tags.multi_add(resource_hrefs: @@deployment.servers().current_instance().href[],tags:[$rs_tags])

  # Tag via ARM Resource Plugin
    $azure_tags = {
      'cost_center': '12345',
      'project': 'azure tagging',
      'environment': 'dev',
      'from_arm_plugin' : 'true'
    }

    call get_arm_access_token("") retrieve $access_token

    # Tag the server
    $resource_group_name = @my_server.deployment().resource_group().name
    $resource_provider_namespace = "Microsoft.Compute"
    $resource_type = "virtualMachines"
    $resourceTypePath = $resource_provider_namespace + "/" + $resource_type
    $name = @my_server.name
    $resource_id = "/subscriptions/" + $subscription_id + "/resourceGroups/" + $resource_group_name + "/providers/" + $resource_provider_namespace + "/" + $resource_type + "/" + $name
    call get_arm_api_version($subscription_id, $access_token, $resourceTypePath) retrieve $vm_api_version
    call tag_resource_by_id($resource_id, $vm_api_version, {'single_tag': 'true'})

    # Tag all Resources in the Resource Group
    call tag_all_resources_in_a_resource_group($subscription_id, $access_token, $resource_group_name, $azure_tags)

    # Tag the Resource Group
    $resource_provider_namespace = "Microsoft.Resources"
    $resource_type = "resourceGroups"
    $resourceTypePath = $resource_provider_namespace + "/" + $resource_type
    $resource_id = "/subscriptions/" + $subscription_id + "/resourceGroups/" + $resource_group_name
    call get_arm_api_version($subscription_id, $access_token, $resourceTypePath) retrieve $rg_api_version
    call tag_resource_by_id($resource_id, $rg_api_version, $azure_tags)
end 

define tag_all_resources_in_a_resource_group($subscription_id, $access_token, $resource_group_name, $tags) do
  sub on_error: stop_debugging() do
    call sys_log.detail("tags_to_set: " + to_s($tags))
    call start_debugging()
    call get_arm_api_version($subscription_id, $access_token, "Microsoft.Resources/resources") retrieve $resources_api_version
    call sys_log.detail("resources_api_version: " + to_s($resources_api_version))
    @resources = rs_azure_resource.resource.listbyresourcegroup(resource_group: $resource_group_name, api_version: $resources_api_version)
    call stop_debugging()
    call sys_log.detail("resoures: " + to_s(@resources))
    $object = to_object(@resources)
    foreach @resource in @resources do
      $object = to_object(@resource)
      call sys_log.detail("object: " + to_s($object))
      $fields = $object["details"]
      call sys_log.detail("fields: " + to_s($fields))
      $resource = $fields[0]
      call sys_log.detail("resource: " + to_s($resource))
      call sys_log.detail("id: " + to_s($resource["id"]))
      $location = $resource["location"]
      call sys_log.detail("location: " + to_s($location))
      $type = $resource["type"]
      call sys_log.detail("type: " + to_s($type))
      call get_arm_api_version($subscription_id, $access_token, $type) retrieve $azure_api_version
      call sys_log.detail("api_version: " + to_s($azure_api_version))
      $tags_to_set = {}
      $tags_to_set = $tags
      if $resource["tags"] != null
        call sys_log.detail("existing_tags: " + to_s($resource["tags"]))
        $tags_to_set = $tags_to_set + $resource["tags"]
      end
      call sys_log.detail("updated_tags: " + to_s($tags_to_set))
      call start_debugging()
      @resource.updatebyid(api_version: $azure_api_version, tags: $tags_to_set)
      call stop_debugging()
    end
  end
end

define tag_resource_by_id($resource_id, $api_version, $tags) do
  sub on_error: stop_debugging() do
    call sys_log.detail("tags_to_set: " + to_s($tags))
    call start_debugging()
    @resource = rs_azure_resource.resource.get(href: $resource_id, api_version: $api_version)
    call stop_debugging()
    call sys_log.detail(to_s(@resource))
    call start_debugging()
    $object = to_object(@resource)
    call sys_log.detail("object: " + to_s($object))
    $fields = $object["details"]
    call sys_log.detail("fields: " + to_s($fields))
    $resource = $fields[0]
    call sys_log.detail("resource: " + to_s($resource))
    $location = $resource["location"]
    call sys_log.detail("location: " + to_s($location))
    $tags_to_set = {}
    $tags_to_set = $tags
    if $resource["tags"] != null
      call sys_log.detail("existing_tags: " + to_s($resource["tags"]))
      $tags_to_set = $tags_to_set + $resource["tags"]
    end
    call sys_log.detail("updated_tags: " + to_s($tags_to_set))
    call start_debugging()
    @resource.updatebyid(api_version: $api_version, tags: $tags_to_set)
    call stop_debugging()
  end
end

define get_arm_access_token($resource) return $access_token do

  $tenant_id = cred("TENANT_ID")
  $client_id = cred("AZURE_APPLICATION_ID")
  call url_encode(cred("AZURE_APPLICATION_KEY")) retrieve $client_secret
  
  if $resource == null || $resource == ""
    $resource = "https://management.core.windows.net/"
  end

  $body_string = "grant_type=client_credentials&resource="+$resource+"&client_id="+$client_id+"&client_secret="+$client_secret

  $auth_response = http_post(
    url: "https://login.microsoftonline.com/" + $tenant_id + "/oauth2/token",
    headers: {
      "cache-control":"no-cache",
      "content-type":"application/x-www-form-urlencoded"
    },
    body:$body_string
  )

  if $auth_response["code"] == 200
    $auth_response_body = $auth_response["body"]
    $access_token = $auth_response_body["access_token"]
  else
    raise "Error getting access token! Response: " + to_s($auth_response)
  end
end

define get_arm_api_version($subscription_id, $access_token, $resourceTypePath) return $azure_api_version do
  $azure_api_version = "Unknown"
  $namespace = split($resourceTypePath, "/")[0]
  $resourceType = sub(sub($resourceTypePath, $namespace, ""),"/","")
  
  $response = http_get(
    url: "https://management.azure.com/subscriptions/" + $subscription_id + "/providers/" + $namespace + "?api-version=2017-05-10",
    headers: {
      "Authorization": "Bearer " + $access_token
    }
  )

  if $response["code"] == 200
    $provider = $response["body"]
    $type = select($provider["resourceTypes"], {"resourceType": $resourceType})
    $azure_api_version = $type[0]["apiVersions"][0]
  else
    raise "Error getting providers! Response: " + to_s($$response)
  end
end

define get_arm_api_versions($subscription_id, $access_token) return $azure_api_versions do
  
  $response = http_get(
    url: "https://management.azure.com/subscriptions/" + $subscription_id + "/providers?api-version=2017-05-10",
    headers: {
      "Authorization": "Bearer " + $access_token
    }
  )

  if $response["code"] == 200
    $response_body = $response["body"]
    $providers = $response_body["value"]
    $azure_api_versions = {}
    foreach $provider in $providers do
      foreach $resourceType in $provider["resourceTypes"] do
        $namespaceResourceType = $provider["namespace"] + "/" + $resourceType["resourceType"]
        $apiVersion = $resourceType["apiVersions"][0]
        $resourceTypeDetails = {
          $namespaceResourceType: $apiVersion
        }
        $azure_api_versions = $azure_api_versions + $resourceTypeDetails
      end
    end
  else
    raise "Error getting providers! Response: " + to_s($$response)
  end
end

define url_encode($string) return $encoded_string do
  $encoded_string = $string
  $encoded_string = gsub($encoded_string, " ", "%20")
  $encoded_string = gsub($encoded_string, "!", "%21")
  $encoded_string = gsub($encoded_string, "#", "%23")
  $encoded_string = gsub($encoded_string, "$", "%24")
  $encoded_string = gsub($encoded_string, "&", "%26")
  $encoded_string = gsub($encoded_string, "'", "%27")
  $encoded_string = gsub($encoded_string, "(", "%28")
  $encoded_string = gsub($encoded_string, ")", "%29")
  $encoded_string = gsub($encoded_string, "*", "%2A")
  $encoded_string = gsub($encoded_string, "+", "%2B")
  $encoded_string = gsub($encoded_string, ",", "%2C")
  $encoded_string = gsub($encoded_string, "/", "%2F")
  $encoded_string = gsub($encoded_string, ":", "%3A")
  $encoded_string = gsub($encoded_string, ";", "%3B")
  $encoded_string = gsub($encoded_string, "=", "%3D")
  $encoded_string = gsub($encoded_string, "?", "%3F")
  $encoded_string = gsub($encoded_string, "@", "%40")
  $encoded_string = gsub($encoded_string, "[", "%5B")
  $encoded_string = gsub($encoded_string, "]", "%5D")
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