name 'GCP BigTable - Test CAT'
rs_ca_ver 20161221
short_description "Google Cloud Platform - BigTable - Test CAT"
import "plugins/bigtable"

##########################
##########################
###### Parameters ########
##########################
##########################

parameter "google_project" do
    like $bigtable.google_project
    default "rightscale.com:services1"
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

resource "my_instance", type: "bigtable.instances" do
    instance_id join(["df-",last(split(@@deployment.href, "/"))])
    instance do {
        "displayName" => "rs-instance",
        "type" => "PRODUCTION"
    } end
end 

resource "my_cluster", type: "bigtable.clusters" do
    instance_id join(["df-",last(split(@@deployment.href, "/"))])
    cluster_id join(["rs-cluster-",last(split(@@deployment.href, "/"))])
end

resource "my_table", type: "bigtable.tables" do
    instance_id join(["df-",last(split(@@deployment.href, "/"))])
    table_id join(["table",last(split(@@deployment.href, "/"))])
end

##########################
##########################
###### Operations ########
##########################
##########################

operation "launch" do
    definition "launch_handler"
end 

##########################
##########################
###### Definitions #######
##########################
##########################

define launch_handler(@my_instance, @my_cluster, @my_table, $google_project) return @my_instance, @my_cluster, @my_table do
    $cluster_name = join(["rs-cluster-",last(split(@@deployment.href, "/"))])
    $object = to_object(@my_instance)
    $object["fields"]["clusters"] = {}
    $object["fields"]["clusters"][$cluster_name] = {}
    $object["fields"]["clusters"][$cluster_name]["location"] = join(["projects/", $google_project, "/locations/us-central1-c"])
    $object["fields"]["clusters"][$cluster_name]["serveNodes"] = 3
    $object["fields"]["clusters"][$cluster_name]["defaultStorageType"] = "HDD"
    @my_instance = $object
    provision(@my_instance)
    @my_cluster = bigtable.clusters.show(name: $cluster_name, instance_id: join(["df-",last(split(@@deployment.href, "/"))]))
    provision(@my_table)
end

