name 'GKE - Test CAT'
rs_ca_ver 20161221
short_description "Google Cloud Platform - GKE - Test CAT"
import "plugins/gke"

##########################
##########################
###### Parameters ########
##########################
##########################

parameter "google_project" do
  like $gke.google_project
  default "rightscale.com:services1"
end

##########################
##########################
####### Resources ########
##########################
##########################

resource "my_cluster", type: "gke.clusters" do
  zone "us-central1-a"
  cluster do {
    "name" => join(["rs-cluster-", last(split(@@deployment.href, "/"))]),
    "initialClusterVersion" => "1.15.9-gke.9",
    "nodePools" => [
      {
        "name" => "nodepool1",
        "initialNodeCount" => 3
      }
    ]
  } 
  end 
end

resource "my_node_pool", type: "gke.nodePools" do
  location "us-central1-a"
  cluster @my_cluster.name
  nodePool do {
    "name" => "nodepool2",
    "initialNodeCount" => 3
  }
  end
end
