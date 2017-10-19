name "GCP Plugin"
rs_ca_ver 20161221
short_description "GCE & GKE plugins"
type 'plugin'
package "plugins/gce_gke"
import "sys_log"

parameter "google_project" do
  type "string"
  label "Google Cloud Project"
  allowed_pattern "^[0-9a-z:\.-]+$"
end

plugin "gke" do
  endpoint do
    default_scheme "https"
    default_host "container.googleapis.com"
    path "/v1"
  end

  parameter "project" do
    type "string"
    label "Project"
    description "The GCP Project to create/manage resources"
  end

  # https://cloud.google.com/container-engine/reference/rest/v1/projects.zones.clusters
  type "clusters" do
    href_templates "{{contains(selfLink, '/clusters/') && selfLink || null}}","{{contains(selfLink, '/clusters/') && clusters[*].selfLink || null}}"

    provision "provision_cluster"
    delete "destroy_cluster"

    field "zone" do
      required true
      type "string"
      location "path"
    end 

    field "cluster" do
      required true
      type "object"
      location "body"
    end 

    field "update" do
      type "object"
      location "body"
    end 

    action "create" do
      verb "POST"
      path "/projects/$project/zones/$zone/clusters"
      type "operation"
    end 

    action "get" do
      verb "GET"
      path "$href"
      type "clusters"
    end 

    action "list" do
      verb "GET"
      path "/projects/$project/zones/$zone/clusters"
      type "clusters"

      field "zone" do
        location "path"
      end 

      output_path "clusters[]"
    end
    
    action "destroy" do
      verb "DELETE"
      path "$href"
      type "operation"
    end 

    action "update" do
      verb "PUT"
      path "$href"
      type "operation"

      field "update" do
        location "body"
      end 

    end 

    output "name","description","initialNodeCount","loggingService","monitoringService","network","clusterIpv4Cidr","subnetwork","locations","enableKubernetesAlpha","resourceLabels","labelFingerprint","selfLink","zone","endpoint","initialClusterVersion","currentMasterVersion","currentNodeVersion","createTime","status","statusMessage","nodeIpv4CidrSize","servicesIpv4Cidr","instanceGroupUrls","currentNodeCount","expireTime","nodeConfig","masterAuth","addonsConfig","nodePools","legacyAbac","networkPolicy","ipAllocationPolicy","masterAuthorizedNetworksConfig"

  end

  # https://cloud.google.com/container-engine/reference/rest/v1/projects.zones.operations
  type "operation" do
    href_templates "{{contains(selfLink, '/operations/') && selfLink || null}}"

    provision "no_operation"
    delete "no_operation"
    
    action "get" do
      verb "GET"
      path "$href"
      type "operation"
    end 

    link "targetLink" do
      url "$targetLink"
    end

    output "name","zone","operationType","status","detail","statusMessage","selfLink","targetLink","startTime","endTime"
  end 
end

resource_pool "gke" do
  plugin $gke
  parameter_values do
    project $google_project
  end
  auth "my_google_auth", type: "oauth2" do
    token_url "https://www.googleapis.com/oauth2/v4/token"
    grant type: "jwt_bearer" do
      iss cred("GOOGLE_CONTAINER_ENGINE_ACCOUNT")
      aud "https://www.googleapis.com/oauth2/v4/token"
      additional_claims do {
        "scope" => "https://www.googleapis.com/auth/cloud-platform"
      } end
      signing_key cred("GOOGLE_CONTAINER_ENGINE_KEY")
    end
  end
end

define provision_cluster(@declaration) return @resource on_error: stop_debugging() do
  call start_debugging()
  $raw = to_object(@declaration)
  $fields = $raw["fields"]
  $type = $raw["type"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary(join(["Provision ",$type]))
  call sys_log.detail($raw)
  @operation = gke.$type.create($fields)
  call sys_log.detail(to_object(@operation))
  sub timeout: 2m, on_timeout: skip do
    sleep_until @operation.status == "DONE"
  end
  @resource = @operation.targetLink()
  call sys_log.detail(to_object(@resource))
  call stop_debugging()
end

define destroy_cluster(@resource) on_error: stop_debugging() do
  call start_debugging()
  if !empty?(@resource)
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Delete: ",@resource.name]))
    @operation = @resource.destroy()
    sub timeout: 2m, on_timeout: skip do
      sleep_until(@operation.status == "DONE")
    end
    call sys_log.detail(to_object(@operation))
  end
end

define no_operation() do
end

define skip_not_found_error() do
  if $_error["message"] =~ "/not found/i"
    log_info($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "skip"
  end
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

plugin "gce" do
  endpoint do
    default_scheme "https"
    default_host "www.googleapis.com"
    path "/compute/v1"
  end

  parameter "project" do
    type "string"
    label "Project"
    description "The GCE project to create resources in"
  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups.
  type "instanceGroup" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.instanceGroups[].selfLink}}"

    field "zone" do
      location "path"
      required true
      type "string"
    end

    field "description" do
      type "string"
    end

    field "name" do
      type "string"
    end

    field "namedPorts" do
      type "array"
    end

    field "network" do
      type "string"
    end

    field "region" do
      type "string"
    end

    field "subnetwork" do
      type "string"
    end

    output "creationTimestamp","description","fingerprint","id","kind","name","namedPorts","network","region","selfLink","size","subnetwork","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/addInstances.
    action "addInstances" do 
      verb "POST"
      path "$href/addInstances"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/aggregatedList.
    action "aggregatedList" do 
      verb "GET"
      path "/projects/$project/aggregated/instanceGroups"
      type "instanceGroup"
      output_path "items.*.instanceGroups[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/delete.
    action "delete" do 
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/get.
    action "get" do 
      verb "GET"
      path "$href"
      type "instanceGroup"
    end

    action "show" do
      verb "GET"
      path "/projects/$project/zones/$zone/instanceGroups/$name"
      type "instanceGroup"

      field "zone" do
        location "path"
      end 

      field "name" do
        location "path"
      end 
    end 

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/insert.
    action "insert" do 
      verb "POST"
      path "/projects/$project/zones/$zone/instanceGroups"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/list.
    action "list" do 
      verb "GET"
      path "/projects/$project/zones/$zone/instanceGroups"
      type "instanceGroup"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/listInstances.
    action "listInstances" do 
      verb "POST"
      path "$href/listInstances"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/removeInstances.
    action "removeInstances" do 
      verb "POST"
      path "$href/removeInstances"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instanceGroups/setNamedPorts.
    action "setNamedPorts" do 
      verb "POST"
      path "$href/setNamedPorts"
      type "operation"
    end

    link "network" do
      url "$network"
      type "network"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "subnetwork" do
      url "$subnetwork"
      type "subnetwork"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances.
  type "instance" do
    href_templates "{{selfLink}}","{{items[*].selfLink}}","{{items.*.instances[].selfLink}}"

    field "zone" do
      location "path"
      required true
      type "string"
    end

    field "canIpForward" do
      type "boolean"
    end

    field "description" do
      type "string"
    end

    field "disks" do
      type "array"
    end

    field "machineType" do
      required true
      type "string"
    end

    field "metadata" do
      type "object"
    end

    field "name" do
      required true
      type "string"
    end

    field "networkInterfaces" do
      type "array"
    end

    field "scheduling" do
      type "object"
    end

    field "serviceAccounts" do
      type "array"
    end

    field "tags" do
      type "object"
    end

    field "fingerprint" do
      type "string"
    end 

    field "items" do
      type "array"
    end 

    output "canIpForward","cpuPlatform","creationTimestamp","description","disks","id","kind","machineType","metadata","name","networkInterfaces","scheduling","selfLink","serviceAccounts","status","statusMessage","tags","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/addAccessConfig.
    action "addAccessConfig" do 
      verb "POST"
      path "$href/addAccessConfig"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/aggregatedList.
    action "aggregatedList" do 
      verb "GET"
      path "/projects/$project/aggregated/instances"
      type "instance"
      output_path "items.*.instances[]"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/attachDisk.
    action "attachDisk" do 
      verb "POST"
      path "$href/attachDisk"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/delete.
    action "delete" do 
      verb "DELETE"
      path "$href"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/deleteAccessConfig.
    action "deleteAccessConfig" do 
      verb "POST"
      path "$href/deleteAccessConfig"
      type "operation"

      field "accessConfig" do
        location "query"
      end
      field "networkInterface" do
        location "query"
      end
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/detachDisk.
    action "detachDisk" do 
      verb "POST"
      path "$href/detachDisk"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/get.
    action "get" do 
      verb "GET"
      path "$href"
      type "instance"
    end

    action "show" do
      verb "GET"
      path "/projects/$project/zones/$zone/instances/$name"
      type "instance"

      field "zone" do
        location "path"
      end 

      field "name" do
        location "path"
      end 
    end 

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/getSerialPortOutput.
    action "getSerialPortOutput" do 
      verb "GET"
      path "$href/serialPort"
      type "serialPortOutput"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/insert.
    action "insert" do 
      verb "POST"
      path "/projects/$project/zones/$zone/instances"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/list.
    action "list" do 
      verb "GET"
      path "/projects/$project/zones/$zone/instances"
      type "instance"
      output_path "items"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/reset.
    action "reset" do 
      verb "POST"
      path "$href/reset"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/setDiskAutoDelete.
    action "setDiskAutoDelete" do 
      verb "POST"
      path "$href/setDiskAutoDelete"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/setMachineType.
    action "setMachineType" do 
      verb "POST"
      path "$href/setMachineType"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/setMetadata.
    action "setMetadata" do 
      verb "POST"
      path "$href/setMetadata"
      type "operation"

      field "fingerprint" do
        location "body"
      end

      field "items" do
        location "body"
      end 
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/setScheduling.
    action "setScheduling" do 
      verb "POST"
      path "$href/setScheduling"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/setTags.
    action "setTags" do 
      verb "POST"
      path "$href/setTags"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/start.
    action "start" do 
      verb "POST"
      path "$href/start"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/startWithEncryptionKey.
    action "startWithEncryptionKey" do 
      verb "POST"
      path "$href/startWithEncryptionKey"
      type "operation"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/instances/stop.
    action "stop" do 
      verb "POST"
      path "$href/stop"
      type "operation"
    end

    link "machineType" do
      url "$machineType"
      type "machineType"
    end

    link "zone" do
      url "$zone"
      type "zone"
    end

    provision "provision_resource"

    delete "delete_resource"

  end

  # This resource was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalOperations.
  type "operation" do
    href_templates "{{selfLink}}"

    output "clientOperationId","creationTimestamp","description","endTime","error","httpErrorMessage","httpErrorStatusCode","id","insertTime","kind","name","operationType","progress","region","selfLink","startTime","status","statusMessage","targetId","targetLink","user","warnings","zone"

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalOperations/delete.
    action "delete" do 
      verb "DELETE"
      path "$href"
    end

    # This action was generated using the documentation from https://cloud.google.com/compute/docs/reference/latest/globalOperations/get.
    action "get" do 
      verb "GET"
      path "$href"
      type "operation"
    end

    link "region" do
      url "$region"
      type "region"
    end

    link "targetLink" do
      url "$targetLink"
    end

    provision "no_operation"

    delete "delete_resource"

  end

end

define provision_resource(@raw) return @resource on_error: stop_debugging() do
  call start_debugging()
  $raw = to_object(@raw)
  $fields = $raw["fields"]
  $type = $raw["type"]
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary(join(["Provision ",$type]))
  call sys_log.detail($raw)
  @operation = gce.$type.insert($fields)
  call sys_log.detail(to_object(@operation))
  sub timeout: 2m, on_timeout: skip do
    sleep_until @operation.status == "DONE"
  end
  call sys_log.detail(to_object(@resource))
  @resource = @operation.targetLink()
  call stop_debugging()
end

define delete_resource(@resource) on_error: stop_debugging() do
  call start_debugging()
  if !empty?(@resource)
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Delete: ",@resource.name]))
    sub on_error: skip_not_found_error() do
      @operation = @resource.delete()
      sub timeout: 2m, on_timeout: skip do
        sleep_until(@operation.status == "DONE")
      end
      call sys_log.detail(to_object(@operation))
    end
  end
end

resource_pool "gce" do
  plugin $gce
  parameter_values do
    project $google_project
  end
  auth "my_google_auth", type: "oauth2" do
    token_url "https://www.googleapis.com/oauth2/v4/token"
    grant type: "jwt_bearer" do
      iss cred("GCE_PLUGIN_ACCOUNT")
      aud "https://www.googleapis.com/oauth2/v4/token"
      additional_claims do {
        "scope" => "https://www.googleapis.com/auth/compute"
      } end
      signing_key cred("GCE_PLUGIN_PRIVATE_KEY")
    end
  end
end

