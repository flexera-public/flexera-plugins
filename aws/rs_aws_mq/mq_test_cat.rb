name 'MQ Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - MQ"
import "plugins/rs_aws_mq"


resource "my_broker", type: "rs_aws_mq.brokers" do
  broker_name join(["RightScale-",last(split(@@deployment.href, "/"))])
  host_instance_type "mq.m4.large"
  engine_type "ActiveMQ"
  engine_version "5.15.0"
  deployment_mode "SINGLE_INSTANCE"
  publicly_accessible true
  subnet_ids ["subnet-843314b8"]
  security_groups ["sg-7dad9003"]
  auto_minor_version_upgrade false
  users do [{
    "password" => "MyPassword456",
    "groups" => ["admins"],
    "consoleAccess" => true,
    "username" => "jane.doe"
  }] end
end
