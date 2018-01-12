name 'rs_aws_cft'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Cloud Formation"
long_description "Version: 1.3"
package "plugins/rs_aws_cft"
import "sys_log"

plugin "rs_aws_cft" do
  endpoint do
    default_scheme "https"
    query do {
      "Version" => "2010-05-15"
    } end
  end
  
  # http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/Welcome.html
  type "stack" do
    href_templates "/?Action=DescribeStacks&StackName={{//DescribeStacksResult/Stacks/member/StackName}}","{{//CreateStackResult/StackId}}"

    field "capabilities" do
      alias_for "Capabilities.member.1"
      type "string"
      location "query"
      # ALLOWED VALUES: CAPABILITY_IAM or CAPABILITY_NAMED_IAM
    end

    field "client_request_token" do
      alias_for "ClientRequestToken"
      type "string"
      location "query"
    end

    field "disable_rollback" do
      alias_for "DisableRollback"
      type "boolean"
      location "query"
    end 

    field "notification_arn_1" do
      alias_for "NotificationARNs.member.1"
      type "string"
      location "query"
    end 

    field "notification_arn_2" do
      alias_for "NotificationARNs.member.2"
      type "string"
      location "query"
    end 

    field "notification_arn_3" do
      alias_for "NotificationARNs.member.3"
      type "string"
      location "query"
    end 

    field "on_failure" do
      alias_for "OnFailure"
      type "string"
      location "query"
      # ALLOWED VALUES: DO_NOTHING | ROLLBACK | DELETE
    end

    field "parameter_1_name" do
      alias_for "Parameters.member.1.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_1_value" do
      alias_for "Parameters.member.1.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_2_name" do
      alias_for "Parameters.member.2.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_2_value" do
      alias_for "Parameters.member.2.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_3_name" do
      alias_for "Parameters.member.3.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_3_value" do
      alias_for "Parameters.member.3.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_4_name" do
      alias_for "Parameters.member.4.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_4_value" do
      alias_for "Parameters.member.4.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_5_name" do
      alias_for "Parameters.member.5.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_5_value" do
      alias_for "Parameters.member.5.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_6_name" do
      alias_for "Parameters.member.6.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_6_value" do
      alias_for "Parameters.member.6.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_7_name" do
      alias_for "Parameters.member.7.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_7_value" do
      alias_for "Parameters.member.7.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_8_name" do
      alias_for "Parameters.member.8.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_8_value" do
      alias_for "Parameters.member.8.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_9_name" do
      alias_for "Parameters.member.9.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_9_value" do
      alias_for "Parameters.member.9.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_10_name" do
      alias_for "Parameters.member.10.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_10_value" do
      alias_for "Parameters.member.10.ParameterValue"
      type "string"
      location "query"
    end 
    
    field "parameter_11_name" do
      alias_for "Parameters.member.11.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_11_value" do
      alias_for "Parameters.member.11.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_12_name" do
      alias_for "Parameters.member.12.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_12_value" do
      alias_for "Parameters.member.12.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_13_name" do
      alias_for "Parameters.member.13.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_13_value" do
      alias_for "Parameters.member.13.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_14_name" do
      alias_for "Parameters.member.14.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_14_value" do
      alias_for "Parameters.member.14.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_15_name" do
      alias_for "Parameters.member.15.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_15_value" do
      alias_for "Parameters.member.15.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_16_name" do
      alias_for "Parameters.member.16.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_16_value" do
      alias_for "Parameters.member.16.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_17_name" do
      alias_for "Parameters.member.17.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_17_value" do
      alias_for "Parameters.member.17.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_18_name" do
      alias_for "Parameters.member.18.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_18_value" do
      alias_for "Parameters.member.18.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_19_name" do
      alias_for "Parameters.member.19.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_19_value" do
      alias_for "Parameters.member.19.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_20_name" do
      alias_for "Parameters.member.20.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_20_value" do
      alias_for "Parameters.member.20.ParameterValue"
      type "string"
      location "query"
    end 
    
    field "parameter_21_name" do
      alias_for "Parameters.member.21.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_21_value" do
      alias_for "Parameters.member.21.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_22_name" do
      alias_for "Parameters.member.22.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_22_value" do
      alias_for "Parameters.member.22.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_23_name" do
      alias_for "Parameters.member.23.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_23_value" do
      alias_for "Parameters.member.23.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_24_name" do
      alias_for "Parameters.member.24.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_24_value" do
      alias_for "Parameters.member.24.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_25_name" do
      alias_for "Parameters.member.25.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_25_value" do
      alias_for "Parameters.member.25.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_26_name" do
      alias_for "Parameters.member.26.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_26_value" do
      alias_for "Parameters.member.26.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_27_name" do
      alias_for "Parameters.member.27.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_27_value" do
      alias_for "Parameters.member.27.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_28_name" do
      alias_for "Parameters.member.28.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_28_value" do
      alias_for "Parameters.member.28.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_29_name" do
      alias_for "Parameters.member.29.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_29_value" do
      alias_for "Parameters.member.29.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_30_name" do
      alias_for "Parameters.member.30.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_30_value" do
      alias_for "Parameters.member.30.ParameterValue"
      type "string"
      location "query"
    end 

    field "resource_type_1" do
      alias_for "ResourceTypes.member.1"
      type "string"
      location "query"
    end 

    field "resource_type_2" do
      alias_for "ResourceTypes.member.2"
      type "string"
      location "query"
    end 

    field "resource_type_3" do
      alias_for "ResourceTypes.member.3"
      type "string"
      location "query"
    end 

    field "role_arn" do
      alias_for "RoleARN"
      type "string"
      location "query"
    end 

    field "stack_name" do
      alias_for "StackName"
      type "string"
      location "query"
      required true
    end 

    field "stack_policy_body" do
      alias_for "StackPolicyBody"
      type "string"
      location "query"
    end 

    field "stack_policy_url" do
      alias_for "StackPolicyURL"
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

    field "template_body" do
      alias_for "TemplateBody"
      type "string"
      location "query"
    end 

    field "template_url" do
      alias_for "TemplateURL"
      type "string"
      location "query"
    end 

    field "timeout_in_minutes" do
      alias_for "TimeoutInMinutes"
      type "number"
      location "query"
    end 

    # Non-create fields

    field "stack_status_filter" do
      alias_for "StackStatusFilter.member.1"
      type "string"
      location "query"
    end 

    field "stack_policy_during_update_body" do
      alias_for "StackPolicyDuringUpdateBody"
      type "string"
      location "query"
    end 

    field "stack_policy_during_update_url" do
      alias_for "StackPolicyDuringUpdateURL"
      type "string"
      location "query"
    end 

    field "use_previous_template" do 
      alias_for "UsePreviousTemplate"
      type "boolean"
      location "query"
    end 

    # http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_CreateStack.html
    action "create" do
      verb "POST"
      path "/?Action=CreateStack"
    end

    # http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DeleteStack.html
    action "destroy" do
      verb "POST"
      path "/?Action=DeleteStack&StackName=$StackName"

    end

    # http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DescribeStacks.html
    action "get" do
      verb "POST"
      path "/?Action=DescribeStacks&StackName=$StackName"

      output_path "//DescribeStacksResult/Stacks/member"
    end 
    
    # http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DescribeStacks.html
    action "get_stack" do
      verb "POST"
      path "/?Action=DescribeStacks"

      field "stack_name" do
        alias_for "StackName"
        location "query"
      end  

      output_path "//DescribeStacksResult/Stacks/member"
    end

    # http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_UpdateStack.html
    action "update" do
      verb "POST"
      path "/?Action=UpdateStack&StackName=$StackName"

      field "capabilities" do
        alias_for "Capabilities.member.1"
        location "query"
      end

      field "client_request_token" do
        alias_for "ClientRequestToken"
        location "query"
      end

      field "notification_arn_1" do
        alias_for "NotificationARNs.member.1"
        location "query"
      end 

      field "notification_arn_2" do
        alias_for "NotificationARNs.member.2"
        location "query"
      end 

      field "notification_arn_3" do
        alias_for "NotificationARNs.member.3"
        location "query"
      end 

      field "parameter_1_name" do
        alias_for "Parameters.member.1.ParameterKey"
        location "query"
      end 

      field "parameter_1_value" do
        alias_for "Parameters.member.1.ParameterValue"
        location "query"
      end 

      field "parameter_2_name" do
        alias_for "Parameters.member.2.ParameterKey"
        location "query"
      end 

      field "parameter_2_value" do
        alias_for "Parameters.member.2.ParameterValue"
        location "query"
      end 

      field "parameter_3_name" do
        alias_for "Parameters.member.3.ParameterKey"
        location "query"
      end 

      field "parameter_3_value" do
        alias_for "Parameters.member.3.ParameterValue"
        location "query"
      end 

      field "parameter_4_name" do
        alias_for "Parameters.member.4.ParameterKey"
        location "query"
      end 

      field "parameter_4_value" do
        alias_for "Parameters.member.4.ParameterValue"
        location "query"
      end 

      field "parameter_5_name" do
        alias_for "Parameters.member.5.ParameterKey"
        location "query"
      end 

      field "parameter_5_value" do
        alias_for "Parameters.member.5.ParameterValue"
        location "query"
      end 

      field "parameter_6_name" do
        alias_for "Parameters.member.6.ParameterKey"
        location "query"
      end 

      field "parameter_6_value" do
        alias_for "Parameters.member.6.ParameterValue"
        location "query"
      end 

      field "parameter_7_name" do
        alias_for "Parameters.member.7.ParameterKey"
        location "query"
      end 

      field "parameter_7_value" do
        alias_for "Parameters.member.7.ParameterValue"
        location "query"
      end 

      field "parameter_8_name" do
        alias_for "Parameters.member.8.ParameterKey"
        location "query"
      end 

      field "parameter_8_value" do
        alias_for "Parameters.member.8.ParameterValue"
        location "query"
      end 

      field "parameter_9_name" do
        alias_for "Parameters.member.9.ParameterKey"
        location "query"
      end 

      field "parameter_9_value" do
        alias_for "Parameters.member.9.ParameterValue"
        location "query"
      end 

      field "parameter_10_name" do
        alias_for "Parameters.member.10.ParameterKey"
        location "query"
      end 

      field "parameter_10_value" do
        alias_for "Parameters.member.10.ParameterValue"
        location "query"
      end 
      
      field "parameter_11_name" do
        alias_for "Parameters.member.11.ParameterKey"
        location "query"
      end 
  
      field "parameter_11_value" do
        alias_for "Parameters.member.11.ParameterValue"
        location "query"
      end 
  
      field "parameter_12_name" do
        alias_for "Parameters.member.12.ParameterKey"
        location "query"
      end 
  
      field "parameter_12_value" do
        alias_for "Parameters.member.12.ParameterValue"
        location "query"
      end 
  
      field "parameter_13_name" do
        alias_for "Parameters.member.13.ParameterKey"
        location "query"
      end 
  
      field "parameter_13_value" do
        alias_for "Parameters.member.13.ParameterValue"
        location "query"
      end 
  
      field "parameter_14_name" do
        alias_for "Parameters.member.14.ParameterKey"
        location "query"
      end 
  
      field "parameter_14_value" do
        alias_for "Parameters.member.4.ParameterValue"
        location "query"
      end 
  
      field "parameter_15_name" do
        alias_for "Parameters.member.15.ParameterKey"
        location "query"
      end 
  
      field "parameter_15_value" do
        alias_for "Parameters.member.15.ParameterValue"
        location "query"
      end 
  
      field "parameter_16_name" do
        alias_for "Parameters.member.16.ParameterKey"
        location "query"
      end 
  
      field "parameter_16_value" do
        alias_for "Parameters.member.16.ParameterValue"
        location "query"
      end 
  
      field "parameter_17_name" do
        alias_for "Parameters.member.17.ParameterKey"
        location "query"
      end 
  
      field "parameter_17_value" do
        alias_for "Parameters.member.17.ParameterValue"
        location "query"
      end 
  
      field "parameter_18_name" do
        alias_for "Parameters.member.18.ParameterKey"
        location "query"
      end 
  
      field "parameter_18_value" do
        alias_for "Parameters.member.18.ParameterValue"
        location "query"
      end 
  
      field "parameter_19_name" do
        alias_for "Parameters.member.19.ParameterKey"
        location "query"
      end 
  
      field "parameter_19_value" do
        alias_for "Parameters.member.19.ParameterValue"
        location "query"
      end 
  
      field "parameter_20_name" do
        alias_for "Parameters.member.20.ParameterKey"
        location "query"
      end 
  
      field "parameter_20_value" do
        alias_for "Parameters.member.20.ParameterValue"
        location "query"
      end 
      
      field "parameter_21_name" do
        alias_for "Parameters.member.21.ParameterKey"
        location "query"
      end 
  
      field "parameter_21_value" do
        alias_for "Parameters.member.21.ParameterValue"
        location "query"
      end 
  
      field "parameter_22_name" do
        alias_for "Parameters.member.22.ParameterKey"
        location "query"
      end 
  
      field "parameter_22_value" do
        alias_for "Parameters.member.22.ParameterValue"
        location "query"
      end 
  
      field "parameter_23_name" do
        alias_for "Parameters.member.23.ParameterKey"
        location "query"
      end 
  
      field "parameter_23_value" do
        alias_for "Parameters.member.23.ParameterValue"
        location "query"
      end 
  
      field "parameter_24_name" do
        alias_for "Parameters.member.24.ParameterKey"
        location "query"
      end 
  
      field "parameter_24_value" do
        alias_for "Parameters.member.24.ParameterValue"
        location "query"
      end 
  
      field "parameter_25_name" do
        alias_for "Parameters.member.25.ParameterKey"
        location "query"
      end 
  
      field "parameter_25_value" do
        alias_for "Parameters.member.25.ParameterValue"
        location "query"
      end 
  
      field "parameter_26_name" do
        alias_for "Parameters.member.26.ParameterKey"
        location "query"
      end 
  
      field "parameter_26_value" do
        alias_for "Parameters.member.26.ParameterValue"
        location "query"
      end 
  
      field "parameter_27_name" do
        alias_for "Parameters.member.27.ParameterKey"
        location "query"
      end 
  
      field "parameter_27_value" do
        alias_for "Parameters.member.27.ParameterValue"
        location "query"
      end 
  
      field "parameter_28_name" do
        alias_for "Parameters.member.28.ParameterKey"
        location "query"
      end 
  
      field "parameter_28_value" do
        alias_for "Parameters.member.28.ParameterValue"
        location "query"
      end 
  
      field "parameter_29_name" do
        alias_for "Parameters.member.29.ParameterKey"
        location "query"
      end 
  
      field "parameter_29_value" do
        alias_for "Parameters.member.29.ParameterValue"
        location "query"
      end 
  
      field "parameter_30_name" do
        alias_for "Parameters.member.30.ParameterKey"
        location "query"
      end 
  
      field "parameter_30_value" do
        alias_for "Parameters.member.30.ParameterValue"
        location "query"
      end 

      field "resource_type_1" do
        alias_for "ResourceTypes.member.1"
        location "query"
      end 

      field "resource_type_2" do
        alias_for "ResourceTypes.member.2"
        location "query"
      end 

      field "resource_type_3" do
        alias_for "ResourceTypes.member.3"
        location "query"
      end 

      field "role_arn" do
        alias_for "RoleARN"
        location "query"
      end 

      field "stack_name" do
        alias_for "StackName"
        location "query"
      end 

      field "stack_policy_body" do
        alias_for "StackPolicyBody"
        location "query"
      end 

      field "stack_policy_url" do
        alias_for "StackPolicyURL"
        location "query"
      end 

      field "tag_value_1" do
        alias_for "Tags.member.1.Value"
        location "query"
      end 

      field "tag_key_1" do
        alias_for "Tags.member.1.Key"
        location "query"
      end 

      field "tag_value_2" do
        alias_for "Tags.member.2.Value"
        location "query"
      end 

      field "tag_key_2" do
        alias_for "Tags.member.2.Key"
        location "query"
      end 

      field "tag_value_3" do
        alias_for "Tags.member.3.Value"
        location "query"
      end 

      field "tag_key_3" do
        alias_for "Tags.member.3.Key"
        location "query"
      end 

      field "tag_value_4" do
        alias_for "Tags.member.4.Value"
        location "query"
      end 

      field "tag_key_4" do
        alias_for "Tags.member.4.Key"
        location "query"
      end 

      field "tag_value_5" do
        alias_for "Tags.member.5.Value"
        location "query"
      end 

      field "tag_key_5" do
        alias_for "Tags.member.5.Key"
        location "query"
      end 

      field "template_body" do
        alias_for "TemplateBody"
        location "query"
      end 

      field "template_url" do
        alias_for "TemplateURL"
        location "query"
      end 

      field "stack_policy_during_update_body" do
        alias_for "StackPolicyDuringUpdateBody"
        location "query"
      end 

      field "stack_policy_during_update_url" do
        alias_for "StackPolicyDuringUpdateURL"
        location "query"
      end 

      field "use_previous_template" do 
        alias_for "UsePreviousTemplate"
        location "query"
      end 

    end 

    # http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DescribeStackResources.html
    link "resources" do
      path "/?Action=DescribeStackResources&StackName=$StackName"
      type "resources"
      output_path "//DescribeStackResourcesResult/StackResources/member"
    end

    output "StackName","StackId","CreationTime","StackStatus","DisableRollback"

    output "OutputKey" do
      body_path "//DescribeStacksResult/Stacks/member/Outputs/member/OutputKey"
      type "array"
    end

    output "OutputValue" do
      body_path "//DescribeStacksResult/Stacks/member/Outputs/member/OutputValue"
      type "array"
    end 

    provision "create_stack"

    delete    "delete_stack"
  end

  type "resources" do 
    href_templates "/?Action=DescribeStackResources&StackName={{//DescribeStackResourcesResult/StackResources/member/StackName}}&LogicalResourceId={{//DescribeStackResourcesResult/StackResources/member/LogicalResourceId}}"

    field "stack_name" do
      alias_for "StackName"
      type "string"
      location "query"
    end
    
    field "logical_resource_id" do
      alias_for "LogicalResourceId"
      type "string"
      location "query"
    end 

    field "physical_resource_id" do
      alias_for "PhysicalResourceId"
      type "string"
      location "query"
    end 

    action "get" do
      verb "POST"
      path "/?Action=DescribeStackResources&StackName=$StackName"

      field "logical_resource_id" do
        alias_for "LogicalResourceId"
        location "query"
      end 

      field "physical_resource_id" do
        alias_for "PhysicalResourceId"
        location "query"
      end 

      output_path "//DescribeStackResourcesResult/StackResources/member"
    end

    action "show" do
      verb "POST"
      path "/?Action=DescribeStackResources"

      field "stack_name" do
        alias_for "StackName"
        location "query"
      end

      field "logical_resource_id" do
        alias_for "LogicalResourceId"
        location "query"
      end 

      field "physical_resource_id" do
        alias_for "PhysicalResourceId"
        location "query"
      end 

      output_path "//DescribeStackResourcesResult/StackResources/member"
    end 

    link "stack" do
      path "/?Action=DescribeStacks&StackName=$StackName"
      type "stack"
      output_path "//DescribeStacksResult/Stacks/member"
    end 

    output "StackName","StackId","Timestamp","LogicalResourceId","PhysicalResourceId","ResourceType","ResourceStatus"

    provision "no_operation"

    delete "no_operation"
  end
    
end

resource_pool "rs_aws_cft" do
  plugin $rs_aws_cft
  host "cloudformation.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'cloudformation'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define create_stack(@declaration) return @resource do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $tags = $fields["tags"]
    $type = $object["type"]
    $stack_name = $fields["stack_name"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ",$type]))
    call sys_log.detail($object)
    call sys_log.detail(join(["Stack Name: ", $stack_name]))
    @operation = rs_aws_cft.stack.create($fields)
    @operation = rs_aws_cft.stack.get_stack(stack_name: $stack_name)
    $status = @operation.StackStatus
    call sys_log.detail(join(["Status: ", $status]))
    sub on_error: skip, timeout: 60m do
      while $status == "CREATE_IN_PROGRESS" do
        $status = @operation.StackStatus
        call sys_log.detail(join(["Status: ", $status]))
        sleep(10)
      end
    end 
    @resource = @operation.get()
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define delete_stack(@declaration) do
  call start_debugging()
  $state = @declaration.StackStatus
  if $state != "DELETE_IN_PROGRESS" || $state != "DELETE_COMPLETE"
      @declaration.destroy()
  end 
  call stop_debugging()
end

define no_operation(@declaration) do
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