name "Google Container Engine Plugin"
rs_ca_ver 20161221
short_description "GKE plugin"
long_description "Version: 1.0"
type 'plugin'
package "plugins/gke"
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