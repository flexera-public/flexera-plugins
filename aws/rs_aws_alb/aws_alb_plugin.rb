name 'rs_aws_alb'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Elastic Load Balancer"
long_description "Version: 1.1"
package "plugins/rs_aws_alb"
import "sys_log"

plugin "rs_aws_alb" do
  endpoint do
    default_host "elasticloadbalancing.amazonaws.com"
    default_scheme "https"
    path "/"
    headers do {
      "content-type" => "application/xml"
    } end
    query do {
      "Version" => "2015-12-01"
    } end
  end
  
  type "load_balancer" do
    href_templates "/?Action=DescribeLoadBalancers&LoadBalancerArns.member.1={{//CreateLoadBalancerResult/LoadBalancers/member/LoadBalancerArn}}","/?Action=DescribeLoadBalancers&LoadBalancerArns.member.1={{//DescribeLoadBalancersResult/LoadBalancers/member/LoadBalancerArn}}"
    provision "provision_resource"
    delete    "delete_resource"

    field "name" do
      alias_for "Name"
      type      "string"
      location  "query"
      required true
    end

    field "ip_address_type" do
      alias_for "IpAddressType"
      type "string"
      location "query"
      # ALLOWED VALUES: "ipv4" OR "dualstack"
    end

    field "scheme" do
      alias_for "Scheme"
      type "string"
      location "query"
      # ALLOWED VALUES: "internet-facing" OR "internal"
      # DEFAULT: "internet-facing"
    end 

    field "security_group1" do
      alias_for "SecurityGroups.member.1"
      type "string"
      location "query"
    end

    field "security_group2" do
      alias_for "SecurityGroups.member.2"
      type "string"
      location "query"
    end

    field "security_group3" do
      alias_for "SecurityGroups.member.3"
      type "string"
      location "query"
    end

    field "subnet1" do
      alias_for "Subnets.member.1"
      type "string"
      location "query"
      required true
    end

    field "subnet2" do
      alias_for "Subnets.member.2"
      type "string"
      location "query"
      required true 
    end

    field "subnet3" do
      alias_for "Subnets.member.3"
      type "string"
      location "query"
    end

    field "tag_value_1" do
      alias_for "Tags.member.1.Value"
      type "string"
      location "query"
    end 

    field "tag_key_1" do
      alias_for "Tags.member.1.Key"
      type "string"
      location "query"
    end 

    field "tag_value_2" do
      alias_for "Tags.member.2.Value"
      type "string"
      location "query"
    end 

    field "tag_key_2" do
      alias_for "Tags.member.2.Key"
      type "string"
      location "query"
    end 

    field "tag_value_3" do
      alias_for "Tags.member.3.Value"
      type "string"
      location "query"
    end 

    field "tag_key_3" do
      alias_for "Tags.member.3.Key"
      type "string"
      location "query"
    end 

    field "tag_value_4" do
      alias_for "Tags.member.4.Value"
      type "string"
      location "query"
    end 

    field "tag_key_4" do
      alias_for "Tags.member.4.Key"
      type "string"
      location "query"
    end 

    field "tag_value_5" do
      alias_for "Tags.member.5.Value"
      type "string"
      location "query"
    end 

    field "tag_key_5" do
      alias_for "Tags.member.5.Key"
      type "string"
      location "query"
    end 

    field "tag_value_6" do
      alias_for "Tags.member.6.Value"
      type "string"
      location "query"
    end 

    field "tag_key_6" do
      alias_for "Tags.member.6.Key"
      type "string"
      location "query"
    end 

    action "create" do
      verb "POST"
      path "/?Action=CreateLoadBalancer"
      output_path "//CreateLoadBalancerResult/LoadBalancers/member"
    end
    
    action "destroy" do
      verb "POST"
      path "/?Action=DeleteLoadBalancer&LoadBalancerArn=$LoadBalancerArn"
    end
 
    action "get" do
      verb "POST"
      output_path "//DescribeLoadBalancersResult/LoadBalancers/member"
    end
 
    action "list" do
      verb "POST"
      path "/?Action=DescribeLoadBalancers"
      output_path "//DescribeLoadBalancersResult/LoadBalancers/member"
    end

    output "LoadBalancerArn","Scheme","LoadBalancerName","VpcId","CanonicalHostedZoneId","CreatedTime","DNSName"

    output "State" do
      body_path "/State/Code"
      type "simple_element"
    end 

    output "AvailabilityZone" do
      body_path "/AvailabilityZones/member/ZoneName"
      type "simple_element"
    end 

    output "SubnetId" do
      body_path "/AvailabilityZone/member/SubnetId"
      type "simple_element"
    end 

    output "SecurityGroup" do
      body_path "/SecurityGroups/member"
      type "simple_element"
    end 

    link "listeners" do
      path "/?Action=DescribeListeners&LoadBalancerArn=$LoadBalancerArn"
      type "listener"
    end 

  end

  type "target_group" do
    href_templates "/?Action=DescribeTargetGroups&TargetGroupArns.member.1={{//CreateTargetGroupResult/TargetGroups/member/TargetGroupArn}}","/?Action=DescribeTargetGroups&TargetGroupArns.member.1={{//DescribeTargetGroupsResult/TargetGroups/member/TargetGroupArn}}","/?Action=DescribeTargetGroups&TargetGroupArns.member.1={{//ModifyTargetGroupsResult/TargetGroups/member/TargetGroupArn}}"
    provision "provision_resource"
    delete "delete_resource"

    field "health_check_interval_seconds" do
      alias_for "HealthCheckIntervalSeconds"
      type "number"
      location "query"
      # DEFAULT: 30
      # VALID VALUES: 5-300
    end

    field "health_check_path" do
      alias_for "HealthCheckPath"
      type "string"
      location "query"
      # DEFAULT: /
    end

    field "health_check_port" do
      alias_for "HealthCheckPort"
      type "string"
      location "query"
      # DEFAULT: traffic-port
    end
    
    field "health_check_protocol" do
      alias_for "HealthCheckProtocol"
      type "string"
      location "query"
      # DEFAULT: HTTP
      # VALID VALUES: "HTTP" OR "HTTPS"
    end

    field "health_check_timeout_seconds" do
      alias_for "HealthCheckTimeoutSeconds"
      type "number"
      location "query"
      # DEFAULT: 5
      # VALID VALUES: 2-60
    end 

    field "healthy_threshold_count" do
      alias_for "HealthyThresholdCount"
      type "number"
      location "query"
      # DEFAULT 5
      # VALID VALUES 2-10
    end

    field "matcher" do
      alias_for "Matcher.HttpCode"
      type "string"
      location "query"
      # DEFAULT: 200
    end 

    field "name" do
      alias_for "Name"
      type "string"
      required true
      location "query"
    end 

    field "port" do
      alias_for "Port"
      type "number"
      required true
      location "query"
      # VALID VALUES: 1-65535
    end

    field "protocol" do
      alias_for "Protocol"
      type "string"
      location "query"
      required true
      # VALID VALUES: "HTTP" OR "HTTPS"
    end

    field "unhealthy_threshold_count" do
      alias_for "UnhealthyThresholdCount"
      type "number"
      location "query"
      # DEFAULT: 2
      # VALID VALUES: 2-10
    end 

    field "vpc_id" do
      alias_for "VpcId"
      type "string"
      location "query"
      required true
    end 

    #Non-create fields
    field "load_balancer_arn" do
      alias_for "LoadBalancerArn"
      type "string"
      location "query"
    end 

    field "target_group_name" do
      alias_for "Names.member.1"
      type "string"
      location "query"
    end 

    field "target_group_arn" do
      alias_for "TargetGroupArns.member.1"
      type "string"
      location "query"
    end 

    field "target1_id" do
      alias_for "Targets.member.1.Id"
      location "query"
      type "string"
    end

    field "target1_port" do
      alias_for "Targets.member.1.Port"
      location "query"
      type "number"
    end

    field "target2_id" do
      alias_for "Targets.member.2.Id"
      location "query"
      type "string"
    end

    field "target2_port" do
      alias_for "Targets.member.2.Port"
      location "query"
      type "number"
    end

    field "target3_id" do
      alias_for "Targets.member.3.Id"
      location "query"
      type "string"
    end

    field "target3_port" do
      alias_for "Targets.member.3.Port"
      location "query"
      type "number"
    end

    field "target4_id" do
      alias_for "Targets.member.4.Id"
      location "query"
      type "string"
    end

    field "target4_port" do
      alias_for "Targets.member.4.Port"
      location "query"
      type "number"
    end

    field "target5_id" do
      alias_for "Targets.member.5.Id"
      location "query"
      type "string"
    end

    field "target5_port" do
      alias_for "Targets.member.5.Port"
      location "query"
      type "number"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateTargetGroup"
      output_path "//CreateTargetGroupResult/TargetGroups/member"
    end 

    action "get" do
      verb "POST"
      output_path "//DescribeTargetGroupsResult/TargetGroups/member"
    end 

    action "destroy" do
      verb "POST"
      path "/?Action=DeleteTargetGroup&TargetGroupArn=$TargetGroupArn"
    end 

    action "list" do
      verb "POST"
      path "/?Action=DescribeTargetGroups"
      output_path "//DescribeTargetGroupsResult/TargetGroups/member"

      field "load_balancer_arn" do
        alias_for "LoadBalancerArn"
        location "query"
      end 

      field "target_group_name" do
        alias_for "Names.member.1"
        location "query"
      end 

      field "target_group_arn" do
        alias_for "TargetGroupArns.member.1"
        location "query"
      end 

    end 

    action "update" do
      verb "POST"
      path "/?Action=ModifyTargetGroup&TargetGroupArn=$TargetGroupArn"
      output_path "//ModifyTargetGroupResults/TargetGroups/member"

      field "health_check_interval_seconds" do
        alias_for "HealthCheckIntervalSeconds"
        location "query"
      end

      field "health_check_path" do
        alias_for "HealthCheckPath"
        location "query"
      end

      field "health_check_port" do
        alias_for "HealthCheckPort"
        location "query"
      end
      
      field "health_check_protocol" do
        alias_for "HealthCheckProtocol"
        location "query"
      end

      field "health_check_timeout_seconds" do
        alias_for "HealthCheckTimeoutSeconds"
        location "query"
      end 

      field "healthy_threshold_count" do
        alias_for "HealthyThresholdCount"
        location "query"
      end

      field "matcher" do
        alias_for "Matcher.HttpCode"
        location "query"
      end

      field "unhealthy_threshold_count" do
        alias_for "UnhealthyThresholdCount"
        location "query"
      end 

    end  

    action "register_target" do 
      verb "POST"
      path "/?Action=RegisterTargets&TargetGroupArn=$TargetGroupArn"

      field "target1_id" do
        alias_for "Targets.member.1.Id"
        location "query"
      end

      field "target1_port" do
        alias_for "Targets.member.1.Port"
        location "query"
      end

      field "target2_id" do
        alias_for "Targets.member.2.Id"
        location "query"
      end

      field "target2_port" do
        alias_for "Targets.member.2.Port"
        location "query"
      end

      field "target3_id" do
        alias_for "Targets.member.3.Id"
        location "query"
      end

      field "target3_port" do
        alias_for "Targets.member.3.Port"
        location "query"
      end

      field "target4_id" do
        alias_for "Targets.member.4.Id"
        location "query"
      end

      field "target4_port" do
        alias_for "Targets.member.4.Port"
        location "query"
      end

      field "target5_id" do
        alias_for "Targets.member.5.Id"
        location "query"
      end

      field "target5_port" do
        alias_for "Targets.member.5.Port"
        location "query"
      end
    end 

    action "deregister_target" do 
      verb "POST"
      path "/?Action=DeregisterTargets&TargetGroupArn=$TargetGroupArn"

      field "target1_id" do
        alias_for "Targets.member.1.Id"
        location "query"
      end

      field "target1_port" do
        alias_for "Targets.member.1.Port"
        location "query"
      end

      field "target2_id" do
        alias_for "Targets.member.2.Id"
        location "query"
      end

      field "target2_port" do
        alias_for "Targets.member.2.Port"
        location "query"
      end

      field "target3_id" do
        alias_for "Targets.member.3.Id"
        location "query"
      end

      field "target3_port" do
        alias_for "Targets.member.3.Port"
        location "query"
      end

      field "target4_id" do
        alias_for "Targets.member.4.Id"
        location "query"
      end

      field "target4_port" do
        alias_for "Targets.member.4.Port"
        location "query"
      end

      field "target5_id" do
        alias_for "Targets.member.5.Id"
        location "query"
      end

      field "target5_port" do
        alias_for "Targets.member.5.Port"
        location "query"
      end
    end 

    output "TargetGroupArn","HealthCheckTimeoutSeconds","HealthCheckPort","TargetGroupName","HealthCheckProtocol","HealthCheckPath","Protocol","Port","VpcId","HealthyThresholdCount","HealthCheckIntervalSeconds","UnhealthyThresholdCount"

  end 

  type "rule" do
    href_templates "/?Action=DescribeRules&RuleArns.member.1={{//DescribeRulesResult/Rules/member/RuleArn}}","/?Action=DescribeRules&RuleArns.member.1={{//CreateRuleResult/Rules/member/RuleArn}}","/?Action=DescribeRules&RuleArns.member.1={{//ModifyRulesResult/Rules/member/RuleArn"
    provision "provision_resource"
    delete "delete_resource"

    field "priority" do
      alias_for "Priority"
      type "number"
      required true
      location "query"
    end 

    field "listener_arn" do
      alias_for "ListenerArn"
      type "string"
      required true
      location "query"
    end 

    field "action1_target_group_arn" do
      alias_for "Actions.member.1.TargetGroupArn"
      type "string"
      required true
      location "query"
    end

    field "action1_type" do
      alias_for "Actions.member.1.Type"
      type "string"
      required true
      location "query"
      # ALLOWED VALUE: "forward"
    end

    field "action2_target_group_arn" do
      alias_for "Actions.member.2.TargetGroupArn"
      type "string"
      location "query"
    end

    field "action2_type" do
      alias_for "Actions.member.2.Type"
      type "string"
      location "query"
      # ALLOWED VALUE: "forward"
    end

    field "action3_target_group_arn" do
      alias_for "Actions.member.3.TargetGroupArn"
      type "string"
      location "query"
    end

    field "action3_type" do
      alias_for "Actions.member.3.Type"
      type "string"
      location "query"
      # ALLOWED VALUE: "forward"
    end

    field "condition1_field" do
      alias_for "Conditions.member.1.Field"
      type "string"
      required true
      location "query"
      # ALLOWED VALUES: "path-pattern" OR "host-header" -- http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html
    end 

    field "condition1_value1" do
      alias_for "Conditions.member.1.Values.member.1"
      type "string"
      required true
      location "query"
      # http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html
    end 

    field "condition1_value2" do
      alias_for "Conditions.member.1.Values.member.2"
      type "string"
      location "query"
      # http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html
    end 

    field "condition1_value3" do
      alias_for "Conditions.member.1.Values.member.3"
      type "string"
      location "query"
      # http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html
    end 

    field "condition2_field" do
      alias_for "Conditions.member.2.Field"
      type "string"
      location "query"
      # ALLOWED VALUES: "path-pattern" OR "host-header" -- http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html
    end 

    field "condition2_value1" do
      alias_for "Conditions.member.2.Values.member.1"
      type "string"
      location "query"
      # http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html
    end 

    field "condition2_value2" do
      alias_for "Conditions.member.2.Values.member.2"
      type "string"
      location "query"
      # http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html
    end 

    field "condition2_value3" do
      alias_for "Conditions.member.2.Values.member.3"
      type "string"
      location "query"
      # http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html
    end 

    field "condition3_field" do
      alias_for "Conditions.member.3.Field"
      type "string"
      location "query"
      # ALLOWED VALUES: "path-pattern" OR "host-header" -- http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html
    end 

    field "condition3_value1" do
      alias_for "Conditions.member.3.Values.member.1"
      type "string"
      location "query"
      # http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html
    end 

    field "condition3_value2" do
      alias_for "Conditions.member.3.Values.member.2"
      type "string"
      location "query"
      # http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html
    end 

    field "condition3_value3" do
      alias_for "Conditions.member.3.Values.member.3"
      type "string"
      location "query"
      # http://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RuleCondition.html
    end 

    # Non-create fields
    field "rule_arn" do 
      alias_for "RuleArns.member.1"
      type "string"
      location "query"
    end 

    action "get" do 
      verb "POST"
      output_path "//DescribeRulesResult/Rules/member"
    end 

    action "create" do
      verb "POST"
      path "/?Action=CreateRule"
      output_path "//CreateRuleResult/Rules/member"
    end 

    action "destroy" do 
      verb "POST"
      path "/?Action=DeleteRule&RuleArn=$RuleArn"
    end 

    action "list" do
      verb "POST"
      path "/?Action=DescribeRules"

      field "rule_arn" do 
        alias_for "RuleArns.member.1"
        location "query"
      end 

      field "listener_arn" do 
        alias_for "ListenerArn"
        location "query"
      end

      output_path "//DescribeRulesResult/Rules/member" 
    end

    action "update" do
      verb "POST"
      path "/?Action=ModifyRule&RuleArn=$RuleArn"

      field "action1_target_group_arn" do
        alias_for "Actions.member.1.TargetGroupArn"
        location "query"
      end

      field "action1_type" do
        alias_for "Actions.member.1.Type"
        location "query"
      end

      field "action2_target_group_arn" do
        alias_for "Actions.member.2.TargetGroupArn"
        location "query"
      end

      field "action2_type" do
        alias_for "Actions.member.2.Type"
        location "query"
      end

      field "action3_target_group_arn" do
        alias_for "Actions.member.3.TargetGroupArn"
        location "query"
      end

      field "action3_type" do
        alias_for "Actions.member.3.Type"
        location "query"
      end

      field "condition1_field" do
        alias_for "Conditions.member.1.Field"
        location "query"
      end 

      field "condition1_value1" do
        alias_for "Conditions.member.1.Values.member.1"
        location "query"
      end 

      field "condition1_value2" do
        alias_for "Conditions.member.1.Values.member.2"
        location "query"
      end 

      field "condition1_value3" do
        alias_for "Conditions.member.1.Values.member.3"
        location "query"
      end 

      field "condition2_field" do
        alias_for "Conditions.member.2.Field"
        location "query"
      end 

      field "condition2_value1" do
        alias_for "Conditions.member.2.Values.member.1"
        location "query"
      end 

      field "condition2_value2" do
        alias_for "Conditions.member.2.Values.member.2"
        location "query"
      end 

      field "condition2_value3" do
        alias_for "Conditions.member.2.Values.member.3"
        location "query"
      end 

      field "condition3_field" do
        alias_for "Conditions.member.3.Field"
        location "query"
      end 

      field "condition3_value1" do
        alias_for "Conditions.member.3.Values.member.1"
        location "query"
      end 

      field "condition3_value2" do
        alias_for "Conditions.member.3.Values.member.2"
        location "query"
      end 

      field "condition3_value3" do
        alias_for "Conditions.member.3.Values.member.3"
        location "query"
      end 

      output_path "//ModifyRulesResult/Rules/member"
    end 

    output "Priority","RuleArn"

    output "TargetGroupArn" do
      body_path "//Actions/member/TargetGroupArn"
      type "simple_element"
    end 

    output "ConditionField" do
      body_path "//Conditions/member/Field"
      type "simple_element"
    end 

    output "ConditionValue" do
      body_path "//Conditions/member/Values/member"
      type "simple_element"
    end 

  end

  type "listener" do 
    href_templates "/?Action=DescribeListeners&ListenerArns.member.1={{//DescribeListenersResult/Listeners/member/ListenerArn}}","/?Action=DescribeListeners&ListenerArns.member.1={{//CreateListenerResult/Listeners/member/ListenerArn}}","/?Action=DescribeListeners&ListenerArns.member.1={{//ModifyListenerResult/Listeners/member/ListenerArn}}"
    provision "provision_resource"
    delete "delete_resource"

    field "certificate_arn" do
      alias_for "Certificate.member.1.CertificateArn"
      type "string"
      location "query"
    end 

    field "action1_target_group_arn" do
      alias_for "DefaultActions.member.1.TargetGroupArn"
      type "string"
      required true
      location "query"
    end

    field "action1_type" do
      alias_for "DefaultActions.member.1.Type"
      type "string"
      required true
      location "query"
      # ALLOWED VALUE: "forward"
    end

    field "load_balancer_arn" do
      alias_for "LoadBalancerArn"
      type "string"
      required true
      location "query"
    end 

    field "port" do
      alias_for "Port"
      type "number"
      required true
      location "query"
    end 

    field "protocol" do
      alias_for "Protocol"
      type "string"
      required true
      location "query"
      # ALLOWED VALUES: HTTP or HTTPS
    end 

    field "ssl_policy" do
      alias_for "SslPolicy"
      type "string"
      location "query"
    end 

    #Non-create fields

    field "listener_arn" do
      alias_for "ListenerArns.member.1"
      type "string"
      location "query"
    end

    action "create" do
      verb "POST"
      path "/?Action=CreateListener"
      output_path "//CreateListenerResult/Listeners/member"  
    end 

    action "get" do
      verb "POST"
      output_path "//DescribeListenersResult/Listeners/member"
    end

    action "destroy" do
      verb "POST"
      path "/?Action=DeleteListener&ListenerArn=$ListenerArn"
    end 

    action "list" do
      verb "POST"
      path "/?Action=DescribeListeners"

      field "listener_arn" do
        alias_for "ListenerArns.member.1"
        location "query"
      end

      field "load_balancer_arn" do
        alias_for "LoadBalancerArn"
        location "query"
      end

      output_path "//DescribeListenersResult/Listeners/member"  

    end 

    action "update" do
      verb "POST"
      path "/?Action=ModifyListener&ListenerArn=$ListenerArn"

      field "certificate_arn" do
        alias_for "Certificate.member.1.CertificateArn"
        location "query"
      end 

      field "action1_target_group_arn" do
        alias_for "DefaultActions.member.1.TargetGroupArn"
        location "query"
      end

      field "action1_type" do
        alias_for "DefaultActions.member.1.Type"
        location "query"
        # ALLOWED VALUE: "forward"
      end

      field "port" do
        alias_for "Port"
        location "query"
      end

      field "protocol" do
        alias_for "Protocol"
        location "query"
      end 

      field "ssl_policy" do
        alias_for "SslPolicy"
        location "query"
      end 

      output_path "//ModifyListenerResult/Listeners/member"

    end 

    output "LoadBalancerArn","Protocol","Port","ListenerArn"

    output "TargetGroupArn" do
      body_path "//DefaultActions/member/TargetGroupArn"
      type "simple_element"
    end 

    link "load_balander" do
      type "load_balancer"
      path "/?Action=DescribeLoadBalancers&LoadBalancerArns.member.1=$LoadBalancerArn"
    end 

    link "rules" do
      type "rule"
      path "/?Action=DescribeRules&ListenerArn=$ListenerArn"
    end 
  end

end

resource_pool "alb_pool" do
  plugin $rs_aws_alb
  auth "key", type: "aws" do
    version     4
    service    'elasticloadbalancing'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define delete_resource(@resource) do
  sub on_error: stop_debugging() do
   call sys_log.set_task_target(@@deployment)
    call sys_log.summary("Destroy Resource")
    call sys_log.detail(to_object(@resource))
    call start_debugging()
    sub on_error: skip do
      @resource.destroy()
    end
    call stop_debugging()
  end
end

define provision_resource(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_aws_alb.$type.create($fields)
    call stop_debugging()
    call sys_log.detail(to_object(@operation))
    call start_debugging()
    @resource = @operation.get()
    call stop_debugging()
    call sys_log.detail(to_object(@resource))
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
