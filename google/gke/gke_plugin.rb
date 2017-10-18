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

    provision ""
    delete ""

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

    output "name","zone","operationType","status","detail","statusMessage","selfLink","targetLink","startTime","endTime"
  end 