name 'Cloud SQL - Test CAT'
rs_ca_ver 20161221
short_description "Cloud SQL - Test CAT"
import "plugins/google_sql"

parameter "google_project" do
    like $googledns.google_project
    default "rightscale.com:services1"
end

parameter "db_instance_prefix" do
    label "DB Instance Prefix"
    type "string"
    default "my-db-instance"
end

parameter "db_name" do
    label "DB Name"
    type "string"
    default "my-database"
end


resource "gsql_instance", type: "cloud_sql.instances" do
  name join([$db_instance_prefix,"-",last(split(@@deployment.href, "/"))])
  database_version "MYSQL_5_7"
  region "us-central1"
  settings do {
    "tier" => "db-g1-small",
    "activationPolicy" => "ALWAYS",
    "dataDiskSizeGb" => "10",
    "dataDiskType" => "PD_SSD"
  } end 
end

resource "gsql_db", type: "cloud_sql.databases" do
  name $db_name
  instance_name @gsql_instance.name
  collation "utf8_general_ci"
  charset "utf8"
end 

resource "gsql_user", type: "cloud_sql.users" do
  name "frankel"
  instance_name @gsql_instance.name
  password "RightScale2017"
  host "136.62.16.31"
end 