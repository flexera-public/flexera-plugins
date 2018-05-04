name 'ALB Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - Application Load Balancer - Test CAT"
import "plugins/rs_aws_alb"

parameter "lb_name" do
  label "ALB Name"
  description "ALB Name"
  default "myalb-1"
  type "string"
end

resource "my_alb", type: "rs_aws_alb.load_balancer" do
  name join([$lb_name, last(split(@@deployment.href,'/'))])
  scheme "internet-facing"
  ip_address_type "ipv4"
  subnet1 "subnet-843314b8"
  security_group1 "sg-7dad9003"
  subnet2 "subnet-b357c2fb"
  tag_key_1 "foo"
  tag_value_1 "bar"
end

resource "my_tg", type: "rs_aws_alb.target_group" do
  name join(["TargetGroup-",$lb_name])
  port 80
  protocol "HTTP"
  vpc_id "vpc-8172a6f8"
end

resource "my_listener", type: "rs_aws_alb.listener" do
  action1_target_group_arn @my_tg.TargetGroupArn
  action1_type "forward"
  load_balancer_arn @my_alb.LoadBalancerArn
  port 80
  protocol "HTTP"
end 

resource "my_rule", type: "rs_aws_alb.rule" do
  action1_target_group_arn @my_tg.TargetGroupArn
  action1_type "forward"
  condition1_field "path-pattern"
  condition1_value1 "/foo/*"
  listener_arn @my_listener.ListenerArn
  priority 1
end