name 'rds test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - Relational Database Service"
import "plugins/rs_aws_rds"


output "rds_endpoint" do
  label "rds_endpoint"
  default_value @my_rds.endpoint_address
end

output "rds_instance_name" do
  label "rds_instance_name"
  default_value @my_rds.DBInstanceIdentifier
end

#FROM Snapshot:
#resource "my_rds", type: "rs_aws_rds.db_instance" do
#  zone "us-east-1a"
#  db_instance_type "db.t2.small"
#  db_instance_identifier join(["my-rds-", last(split(@@deployment.href, "/"))])
#  db_subnet_group "db-sub-grp-8172a6f8"
#  db_snapshot_identifier "arn:aws:rds:us-east-1:041819229125:snapshot:my-rds-937549003-final-snapshot"
#  storage_type "standard"
#end

#New Instance:
resource "my_rds", type: "rs_aws_rds.db_instance" do
  allocated_storage "10"
  zone "us-east-1a"
  db_instance_type "db.t2.small"
  db_instance_identifier join(["my-rds-", last(split(@@deployment.href, "/"))])
  db_name join(["mydb", last(split(@@deployment.href, "/"))])
  db_subnet_group "db-sub-grp-8172a6f8"
  engine "mysql"
  engine_version "5.7.11" 
  master_username "my_user"
  master_password "pa$$w0rd1"
  storage_encrypted "false"
  storage_type "standard"
end

