name 'Cloud SQL - Test CAT'
rs_ca_ver 20161221
short_description "Cloud SQL - Test CAT"
import "plugins/google_sql"

permission "read_creds" do
  actions   "rs_cm.show_sensitive","rs_cm.index_sensitive"
  resources "rs_cm.credentials"
end

parameter "google_project" do
  like $google_sql.google_project
  default "rightscale.com:services1"
end

parameter "db_instance_prefix" do
  label "DB Instance Prefix"
  type "string"
end

parameter "param_gce_user" do
  type "string"
  label "GCE SQL User"
  category "SQL"
  operations ["create_gsql_user"]
end

parameter "param_gce_password" do
  type "string"
  no_echo true
  label "GCE SQL Password"
  category "SQL"
  operations ["create_gsql_user"]
end

parameter "db_name" do
  label "DB Name"
  type "string"
  default "my-database"
end

parameter "param_backup_id" do
  type "string"
  label "Backup ID"
  category "SQL"
  operations ["restore_primary_db"]
end

parameter "param_backup_instance" do
  type "string"
  label "Backup Instance"
  category "SQL"
  operations ["restore_primary_db"]
end

parameter "param_enable_ha_on_restore" do
  type "string"
  label "Enable HA On Restore"
  category "SQL"
  allowed_values "true","false"
  operations ["restore_primary_db"]
end

output "connection_name" do
  label "Connection Name"
  category "Cloud"
  default_value @gsql_instance.connectionName
  description "GSQL Connection Name"
end

operation "backup_primary_db" do
  label "Backup Primary Database"
  description "Creates a backup of the primary database"
  definition "create_database_backup"
end

operation "restore_primary_db" do
  label "Restore Primary Database"
  description "Creates a backup of the primary database"
  definition "create_database_restore_and_ha"
end

operation "create_gsql_user" do
  label "Create GSQL User"
  description "Creates GSQL User"
  definition "defn_create_gsql_user"
end

operation "create_gsql_db" do
  label "Create GSQL Database"
  description "Creates GSQL Database"
  definition "defn_create_gsql_db"
end

resource "gsql_instance", type: "cloud_sql.instances" do
  name join([$db_instance_prefix,"-",last(split(@@deployment.href, "/"))])
  database_version "MYSQL_5_7"
  region "us-east1"
  settings do {
    "tier" => "db-n1-standard-4",
    "activationPolicy" => "ALWAYS",
    "dataDiskSizeGb" => "25",
    "dataDiskType" => "PD_SSD",
    "pricingPlan" => "PER_USE",
    "replicationType" => "SYNCHRONOUS",
    "storageAutoResize" => true,
      "storageAutoResizeLimit": "0",
    "ipConfiguration": { "ipv4Enabled": true },
    "databaseFlags": [{"name": "max_allowed_packet","value": "268435456"}],
    "backupConfiguration": {
      "startTime": "04:00",
      "enabled": true,
      "binaryLogEnabled": true
    },
    "activationPolicy": "ALWAYS",
    "maintenanceWindow": {
      "hour": 0,
      "day": 0
    }
} end
end

resource "gsql_instance_failover", type: "cloud_sql.instances" do
  name join([$db_instance_prefix,"-",last(split(@@deployment.href, "/")),"-failover"])
  settings do {
    "tier" => "db-n1-standard-4"
  } end
end

resource "gsql_backup", type: "cloud_sql.backup_runs" do
  instance_name @gsql_instance.name
end

resource "gsql_db", type: "cloud_sql.databases" do
  name $db_name
  instance_name @gsql_instance.name
  collation "utf8_general_ci"
  charset "utf8"
end

define create_database_backup(@gsql_instance) return @gsql_instance do
  call google_sql.start_debugging()
  task_label("Creating Database Backup")
  @operation = cloud_sql.operation.empty()
  sub on_error: google_sql.stop_debugging() do
    @operation = cloud_sql.backup_runs.create(instance_name: @gsql_instance.name)
  end
  sub timeout: 5m, on_timeout: skip do
    task_label("Backup - sleeping to complete")
    sleep_until @operation.status == "DONE"
  end
  call google_sql.stop_debugging()
end

define enable_ha(@gsql_instance,$db_instance_prefix,@gsql_instance_failover) return @gsql_instance_failover do
  $replica = {
    "namespace": "cloud_sql",
    "type": "instances",
    "fields": {
                name: join([$db_instance_prefix,"-",last(split(@@deployment.href, "/")),"-failover"]),
                masterInstanceName: @gsql_instance.name,
                region: @gsql_instance.region,
                databaseVersion: @gsql_instance.databaseVersion,
                replicaConfiguration: {"failoverTarget": true},
                settings: {"tier":@gsql_instance.settings["tier"]}
    }
  }
  @gsql_instance_failover = cloud_sql.instances.empty()
  @gsql_instance_failover = $replica
  task_label("Provisioning HA")
  provision(@gsql_instance_failover)
  @gsql_instance_failover = cloud_sql.instances.get_replica(name: join([$db_instance_prefix,"-",last(split(@@deployment.href, "/")),"-failover"]))
  @@gsql_instance_failover = @gsql_instance_failover
end

define create_database_restore(@gsql_instance,$param_backup_id,$param_backup_instance) return @gsql_instance do
  call google_sql.start_debugging()
  task_label("restoring backup")
  @operation = cloud_sql.operation.empty()
  sub on_error: google_sql.stop_debugging() do
    @operation = @gsql_instance.restore_backup(restore_backup_context: {"backupRunId": $param_backup_id, "instanceId": $param_backup_instance })
  end
  sub timeout: 5m, on_timeout: skip do
    task_label("restore - sleeping to complete")
    sleep_until @operation.status == "DONE"
  end
  call google_sql.stop_debugging()
end

define create_database_restore_and_ha(@gsql_instance,$param_backup_id,$param_backup_instance,$param_enable_ha_on_restore,$db_instance_prefix,@gsql_instance_failover) return @gsql_instance,@gsql_instance_failover do
  call create_database_restore(@gsql_instance,$param_backup_id,$param_backup_instance) retrieve @gsql_instance
  call create_database_backup(@gsql_instance) retrieve @gsql_instance
  @gsql_instance_failover = cloud_sql.instances.empty()
  if $param_enable_ha_on_restore == "true"
    call enable_ha(@gsql_instance, $db_instance_prefix,@gsql_instance_failover) retrieve @gsql_instance_failover
  end
end

define defn_create_gsql_user(@gsql_instance,$param_gce_user, $param_gce_password) return @gsql_instance,@gsql_user do
  @gsql_user = cloud_sql.users.create(name: $param_gce_user, instance_name: @gsql_instance.name, password: $param_gce_password)
end

define defn_create_gsql_db(@gsql_instance,@gsql_db) return @gsql_instance,@gsql_db do
  @gsql_db = provision(@gsql_db)
end

operation "launch" do
  definition "gen_launch"
end

operation "terminate" do
  definition "gen_terminate"
end

define gen_launch(@gsql_instance_failover,@gsql_db) return @gsql_instance_failover,@@gsql_instance_failover do
 #return empty - let autoprovision
 @@gsql_instance_failover = cloud_sql.instances.empty()
end

define gen_terminate(@gsql_instance,$db_instance_prefix) return @gsql_instance,@gsql_instance_failover do
  call google_sql.start_debugging()
  sub on_error: google_sql.stop_debugging() do
    @g_cloud_sql = cloud_sql.instances.list(filter: join(["name:",$db_instance_prefix,"-",last(split(@@deployment.href, "/")),"-failover"]))
  end
  sub on_error: skip do
    foreach $name in @gsql_instance.replicaNames do
      cloud_sql.instances.delete_replica(name: $name)
    end
  end
  delete(@gsql_instance)
  call google_sql.stop_debugging()
end