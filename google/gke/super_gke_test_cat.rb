name 'GKE Cluster'
rs_ca_ver 20161221
short_description "![logo](https://s3.amazonaws.com/rs-pft/cat-logos/nav_logo.png)

Google Cloud Platform - GKE Cluster"
import "plugins/gce_gke"

##########################
##########################
###### Parameters ########
##########################
##########################

parameter "google_project" do
  like $gce_gke.google_project
  default "rightscale.com:salesdemo"
end

parameter "zone" do
  type "string"
  label "Zone"
  allowed_values "us-central1-a","us-central1-b","us-central1-c"
  default "us-central1-c"
end

parameter "cluster_prefix" do
  type "string"
  label "Cluster Prefix"
  default "rs-cluster"
end 

parameter "node_count" do
  type "number"
  label "Node Count"
  default 3
  min_value 3
  max_value 20
end 

parameter "environment" do
  type "string"
  label "Environment"
  allowed_values "Dev","Test","Prod"
end 


##########################
##########################
#######  Outputs  ########
##########################
##########################


##########################
##########################
####### Resources ########
##########################
##########################

resource "my_cluster", type: "gke.clusters" do
  zone $zone
  cluster do {
    "name" => join([$cluster_prefix, "-", last(split(@@deployment.href, "/"))]),
    "initialNodeCount" => $node_count,
    "initialClusterVersion" => "1.7.6-gke.1"
  } end 
end 



##########################
##########################
###### Operations ########
##########################
##########################

operation "launch" do
  definition "launch_hanlder"
end 

##########################
##########################
###### Definitions #######
##########################
##########################

define launch_hanlder(@my_cluster, $environment) return @my_cluster do
  $cluster_object = to_object(@my_cluster)
  $zone = $cluster_object["fields"]["zone"]
  provision(@my_cluster)
  $url = @my_cluster.instanceGroupUrls[0]
  $name = last(split($url, "/"))
  @gce_inst_grp = gce.instanceGroup.show(name: $name, zone: $zone)
  $list_instances = @gce_inst_grp.listInstances()
  $gce_instances = $list_instances[0]["items"]
  foreach $gce_instance in $gce_instances do
    $name = last(split($gce_instance["instance"], "/"))
    @instance = rs_cm.instances.empty()
    while empty?(@instance) do 
      @instance = rs_cm.instances.index(filter: ["name==" + $name])
    end 
    @instance.update(instance: {deployment_href: @@deployment.href})
    rs_cm.tags.multi_add(resource_hrefs: [@instance.href], tags: ["kube:environment="+$environment])
  end 
end 



