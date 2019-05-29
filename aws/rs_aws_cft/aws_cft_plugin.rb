name 'rs_aws_cft'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Cloud Formation"
long_description "Version: 1.7"
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

    field "parameter_31_name" do
      alias_for "Parameters.member.31.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_31_value" do
      alias_for "Parameters.member.31.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_32_name" do
      alias_for "Parameters.member.32.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_32_value" do
      alias_for "Parameters.member.32.ParameterValue"
      type "string"
      location "query"
    end    

    field "parameter_33_name" do
      alias_for "Parameters.member.33.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_33_value" do
      alias_for "Parameters.member.33.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_34_name" do
      alias_for "Parameters.member.34.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_34_value" do
      alias_for "Parameters.member.34.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_35_name" do
      alias_for "Parameters.member.35.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_35_value" do
      alias_for "Parameters.member.35.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_36_name" do
      alias_for "Parameters.member.36.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_36_value" do
      alias_for "Parameters.member.36.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_37_name" do
      alias_for "Parameters.member.37.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_37_value" do
      alias_for "Parameters.member.37.ParameterValue"
      type "string"
      location "query"
    end    

    field "parameter_38_name" do
      alias_for "Parameters.member.38.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_38_value" do
      alias_for "Parameters.member.38.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_39_name" do
      alias_for "Parameters.member.39.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_39_value" do
      alias_for "Parameters.member.39.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_40_name" do
      alias_for "Parameters.member.40.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_40_value" do
      alias_for "Parameters.member.40.ParameterValue"
      type "string"
      location "query"
    end    

    field "parameter_41_name" do
      alias_for "Parameters.member.41.ParameterKey"
      type "string"
      location "query"
    end

    field "parameter_41_value" do
      alias_for "Parameters.member.41.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_42_name" do
      alias_for "Parameters.member.42.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_42_value" do
      alias_for "Parameters.member.42.ParameterValue"
      type "string"
      location "query"
    end    

    field "parameter_43_name" do
      alias_for "Parameters.member.43.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_43_value" do
      alias_for "Parameters.member.43.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_44_name" do
      alias_for "Parameters.member.44.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_44_value" do
      alias_for "Parameters.member.44.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_45_name" do
      alias_for "Parameters.member.45.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_45_value" do
      alias_for "Parameters.member.45.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_46_name" do
      alias_for "Parameters.member.46.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_46_value" do
      alias_for "Parameters.member.46.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_47_name" do
      alias_for "Parameters.member.47.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_47_value" do
      alias_for "Parameters.member.47.ParameterValue"
      type "string"
      location "query"
    end    

    field "parameter_48_name" do
      alias_for "Parameters.member.48.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_48_value" do
      alias_for "Parameters.member.48.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_49_name" do
      alias_for "Parameters.member.49.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_49_value" do
      alias_for "Parameters.member.49.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_50_name" do
      alias_for "Parameters.member.50.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_50_value" do
      alias_for "Parameters.member.50.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_51_name" do
      alias_for "Parameters.member.52.ParameterKey"
      type "string"
      location "query"
    end

    field "parameter_51_value" do
      alias_for "Parameters.member.51.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_52_name" do
      alias_for "Parameters.member.52.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_52_value" do
      alias_for "Parameters.member.52.ParameterValue"
      type "string"
      location "query"
    end    

    field "parameter_53_name" do
      alias_for "Parameters.member.53.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_53_value" do
      alias_for "Parameters.member.53.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_54_name" do
      alias_for "Parameters.member.54.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_54_value" do
      alias_for "Parameters.member.54.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_55_name" do
      alias_for "Parameters.member.55.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_55_value" do
      alias_for "Parameters.member.55.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_56_name" do
      alias_for "Parameters.member.56.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_56_value" do
      alias_for "Parameters.member.56.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_57_name" do
      alias_for "Parameters.member.57.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_57_value" do
      alias_for "Parameters.member.57.ParameterValue"
      type "string"
      location "query"
    end    

    field "parameter_58_name" do
      alias_for "Parameters.member.58.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_58_value" do
      alias_for "Parameters.member.58.ParameterValue"
      type "string"
      location "query"
    end 

    field "parameter_59_name" do
      alias_for "Parameters.member.59.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_59_value" do
      alias_for "Parameters.member.59.ParameterValue"
      type "string"
      location "query"
    end

    field "parameter_60_name" do
      alias_for "Parameters.member.60.ParameterKey"
      type "string"
      location "query"
    end 

    field "parameter_60_value" do
      alias_for "Parameters.member.60.ParameterValue"
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

    field "tag_value_7" do
      alias_for "Tags.member.7.Value"
      type "string"
      location "query"
    end 

    field "tag_key_7" do
      alias_for "Tags.member.7.Key"
      type "string"
      location "query"
    end 

    field "tag_value_8" do
      alias_for "Tags.member.8.Value"
      type "string"
      location "query"
    end 

    field "tag_key_8" do
      alias_for "Tags.member.8.Key"
      type "string"
      location "query"
    end 

    field "tag_value_9" do
      alias_for "Tags.member.9.Value"
      type "string"
      location "query"
    end 

    field "tag_key_9" do
      alias_for "Tags.member.9.Key"
      type "string"
      location "query"
    end 

    field "tag_value_10" do
      alias_for "Tags.member.10.Value"
      type "string"
      location "query"
    end 

    field "tag_key_10" do
      alias_for "Tags.member.10.Key"
      type "string"
      location "query"
    end 
    
    field "tag_value_11" do
      alias_for "Tags.member.11.Value"
      type "string"
      location "query"
    end 

    field "tag_key_11" do
      alias_for "Tags.member.11.Key"
      type "string"
      location "query"
    end 

    field "tag_value_12" do
      alias_for "Tags.member.12.Value"
      type "string"
      location "query"
    end 

    field "tag_key_12" do
      alias_for "Tags.member.12.Key"
      type "string"
      location "query"
    end 

    field "tag_value_13" do
      alias_for "Tags.member.13.Value"
      type "string"
      location "query"
    end 

    field "tag_key_13" do
      alias_for "Tags.member.13.Key"
      type "string"
      location "query"
    end 

    field "tag_value_14" do
      alias_for "Tags.member.14.Value"
      type "string"
      location "query"
    end 

    field "tag_key_14" do
      alias_for "Tags.member.14.Key"
      type "string"
      location "query"
    end 

    field "tag_value_15" do
      alias_for "Tags.member.15.Value"
      type "string"
      location "query"
    end 

    field "tag_key_15" do
      alias_for "Tags.member.15.Key"
      type "string"
      location "query"
    end 

    field "tag_value_16" do
      alias_for "Tags.member.16.Value"
      type "string"
      location "query"
    end 

    field "tag_key_16" do
      alias_for "Tags.member.16.Key"
      type "string"
      location "query"
    end

    field "tag_value_17" do
      alias_for "Tags.member.17.Value"
      type "string"
      location "query"
    end

    field "tag_key_17" do
      alias_for "Tags.member.17.Key"
      type "string"
      location "query"
    end

    field "tag_value_18" do
      alias_for "Tags.member.18.Value"
      type "string"
      location "query"
    end 

    field "tag_key_18" do
      alias_for "Tags.member.18.Key"
      type "string"
      location "query"
    end

    field "tag_value_19" do
      alias_for "Tags.member.19.Value"
      type "string"
      location "query"
    end

    field "tag_key_19" do
      alias_for "Tags.member.19.Key"
      type "string"
      location "query"
    end

    field "tag_value_20" do
      alias_for "Tags.member.20.Value"
      type "string"
      location "query"
    end

    field "tag_key_20" do
      alias_for "Tags.member.20.Key"
      type "string"
      location "query"
    end

    field "tag_value_21" do
      alias_for "Tags.member.21.Value"
      type "string"
      location "query"
    end 

    field "tag_key_21" do
      alias_for "Tags.member.21.Key"
      type "string"
      location "query"
    end 

    field "tag_value_22" do
      alias_for "Tags.member.22.Value"
      type "string"
      location "query"
    end 

    field "tag_key_22" do
      alias_for "Tags.member.22.Key"
      type "string"
      location "query"
    end 

    field "tag_value_23" do
      alias_for "Tags.member.23.Value"
      type "string"
      location "query"
    end 

    field "tag_key_23" do
      alias_for "Tags.member.23.Key"
      type "string"
      location "query"
    end 

    field "tag_value_24" do
      alias_for "Tags.member.24.Value"
      type "string"
      location "query"
    end 

    field "tag_key_24" do
      alias_for "Tags.member.24.Key"
      type "string"
      location "query"
    end 

    field "tag_value_25" do
      alias_for "Tags.member.25.Value"
      type "string"
      location "query"
    end 

    field "tag_key_25" do
      alias_for "Tags.member.25.Key"
      type "string"
      location "query"
    end 

    field "tag_value_26" do
      alias_for "Tags.member.26.Value"
      type "string"
      location "query"
    end 

    field "tag_key_26" do
      alias_for "Tags.member.26.Key"
      type "string"
      location "query"
    end

    field "tag_value_27" do
      alias_for "Tags.member.27.Value"
      type "string"
      location "query"
    end

    field "tag_key_27" do
      alias_for "Tags.member.27.Key"
      type "string"
      location "query"
    end

    field "tag_value_28" do
      alias_for "Tags.member.28.Value"
      type "string"
      location "query"
    end 

    field "tag_key_28" do
      alias_for "Tags.member.28.Key"
      type "string"
      location "query"
    end

    field "tag_value_29" do
      alias_for "Tags.member.29.Value"
      type "string"
      location "query"
    end

    field "tag_key_29" do
      alias_for "Tags.member.29.Key"
      type "string"
      location "query"
    end

    field "tag_value_30" do
      alias_for "Tags.member.30.Value"
      type "string"
      location "query"
    end

    field "tag_key_30" do
      alias_for "Tags.member.30.Key"
      type "string"
      location "query"
    end

    field "tag_value_31" do
      alias_for "Tags.member.31.Value"
      type "string"
      location "query"
    end 

    field "tag_key_31" do
      alias_for "Tags.member.31.Key"
      type "string"
      location "query"
    end 

    field "tag_value_32" do
      alias_for "Tags.member.32.Value"
      type "string"
      location "query"
    end 

    field "tag_key_32" do
      alias_for "Tags.member.32.Key"
      type "string"
      location "query"
    end 

    field "tag_value_33" do
      alias_for "Tags.member.33.Value"
      type "string"
      location "query"
    end 

    field "tag_key_33" do
      alias_for "Tags.member.33.Key"
      type "string"
      location "query"
    end 

    field "tag_value_34" do
      alias_for "Tags.member.34.Value"
      type "string"
      location "query"
    end 

    field "tag_key_34" do
      alias_for "Tags.member.34.Key"
      type "string"
      location "query"
    end 

    field "tag_value_35" do
      alias_for "Tags.member.35.Value"
      type "string"
      location "query"
    end 

    field "tag_key_35" do
      alias_for "Tags.member.35.Key"
      type "string"
      location "query"
    end 

    field "tag_value_36" do
      alias_for "Tags.member.36.Value"
      type "string"
      location "query"
    end 

    field "tag_key_36" do
      alias_for "Tags.member.36.Key"
      type "string"
      location "query"
    end

    field "tag_value_37" do
      alias_for "Tags.member.37.Value"
      type "string"
      location "query"
    end

    field "tag_key_37" do
      alias_for "Tags.member.37.Key"
      type "string"
      location "query"
    end

    field "tag_value_38" do
      alias_for "Tags.member.38.Value"
      type "string"
      location "query"
    end 

    field "tag_key_38" do
      alias_for "Tags.member.38.Key"
      type "string"
      location "query"
    end

    field "tag_value_39" do
      alias_for "Tags.member.39.Value"
      type "string"
      location "query"
    end

    field "tag_key_39" do
      alias_for "Tags.member.39.Key"
      type "string"
      location "query"
    end

    field "tag_value_40" do
      alias_for "Tags.member.40.Value"
      type "string"
      location "query"
    end

    field "tag_key_40" do
      alias_for "Tags.member.40.Key"
      type "string"
      location "query"
    end

      field "tag_value_41" do
      alias_for "Tags.member.41.Value"
      type "string"
      location "query"
    end 

    field "tag_key_41" do
      alias_for "Tags.member.41.Key"
      type "string"
      location "query"
    end 

    field "tag_value_42" do
      alias_for "Tags.member.42.Value"
      type "string"
      location "query"
    end 

    field "tag_key_42" do
      alias_for "Tags.member.42.Key"
      type "string"
      location "query"
    end 

    field "tag_value_43" do
      alias_for "Tags.member.43.Value"
      type "string"
      location "query"
    end 

    field "tag_key_43" do
      alias_for "Tags.member.43.Key"
      type "string"
      location "query"
    end 

    field "tag_value_44" do
      alias_for "Tags.member.44.Value"
      type "string"
      location "query"
    end 

    field "tag_key_44" do
      alias_for "Tags.member.44.Key"
      type "string"
      location "query"
    end 

    field "tag_value_45" do
      alias_for "Tags.member.45.Value"
      type "string"
      location "query"
    end 

    field "tag_key_45" do
      alias_for "Tags.member.45.Key"
      type "string"
      location "query"
    end 

    field "tag_value_46" do
      alias_for "Tags.member.46.Value"
      type "string"
      location "query"
    end 

    field "tag_key_46" do
      alias_for "Tags.member.46.Key"
      type "string"
      location "query"
    end

    field "tag_value_47" do
      alias_for "Tags.member.47.Value"
      type "string"
      location "query"
    end

    field "tag_key_47" do
      alias_for "Tags.member.47.Key"
      type "string"
      location "query"
    end

    field "tag_value_48" do
      alias_for "Tags.member.48.Value"
      type "string"
      location "query"
    end 

    field "tag_key_48" do
      alias_for "Tags.member.48.Key"
      type "string"
      location "query"
    end

    field "tag_value_49" do
      alias_for "Tags.member.49.Value"
      type "string"
      location "query"
    end

    field "tag_key_49" do
      alias_for "Tags.member.49.Key"
      type "string"
      location "query"
    end

    field "tag_value_50" do
      alias_for "Tags.member.50.Value"
      type "string"
      location "query"
    end

    field "tag_key_50" do
      alias_for "Tags.member.50.Key"
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

      field "parameter_31_name" do
        alias_for "Parameters.member.31.ParameterKey"
        location "query"
      end 
  
      field "parameter_31_value" do
        alias_for "Parameters.member.31.ParameterValue"
        location "query"
      end 
  
      field "parameter_32_name" do
        alias_for "Parameters.member.32.ParameterKey"
        location "query"
      end 
  
      field "parameter_32_value" do
        alias_for "Parameters.member.32.ParameterValue"
        location "query"
      end 
  
      field "parameter_33_name" do
        alias_for "Parameters.member.33.ParameterKey"
        location "query"
      end 
  
      field "parameter_33_value" do
        alias_for "Parameters.member.33.ParameterValue"
        location "query"
      end 
  
      field "parameter_34_name" do
        alias_for "Parameters.member.34.ParameterKey"
        location "query"
      end 
  
      field "parameter_34_value" do
        alias_for "Parameters.member.34.ParameterValue"
        location "query"
      end 
  
      field "parameter_35_name" do
        alias_for "Parameters.member.35.ParameterKey"
        location "query"
      end 
  
      field "parameter_35_value" do
        alias_for "Parameters.member.35.ParameterValue"
        location "query"
      end 
  
      field "parameter_36_name" do
        alias_for "Parameters.member.36.ParameterKey"
        location "query"
      end 
  
      field "parameter_36_value" do
        alias_for "Parameters.member.36.ParameterValue"
        location "query"
      end 
  
      field "parameter_37_name" do
        alias_for "Parameters.member.37.ParameterKey"
        location "query"
      end 
  
      field "parameter_37_value" do
        alias_for "Parameters.member.37.ParameterValue"
        location "query"
      end 
  
      field "parameter_38_name" do
        alias_for "Parameters.member.38.ParameterKey"
        location "query"
      end 
  
      field "parameter_38_value" do
        alias_for "Parameters.member.38.ParameterValue"
        location "query"
      end 
  
      field "parameter_39_name" do
        alias_for "Parameters.member.39.ParameterKey"
        location "query"
      end 
  
      field "parameter_39_value" do
        alias_for "Parameters.member.39.ParameterValue"
        location "query"
      end 
  
      field "parameter_40_name" do
        alias_for "Parameters.member.40.ParameterKey"
        location "query"
      end 
  
      field "parameter_40_value" do
        alias_for "Parameters.member.40.ParameterValue"
        location "query"
      end      

      field "parameter_41_name" do
        alias_for "Parameters.member.41.ParameterKey"
        location "query"
      end 
  
      field "parameter_41_value" do
        alias_for "Parameters.member.41.ParameterValue"
        location "query"
      end 
  
      field "parameter_42_name" do
        alias_for "Parameters.member.42.ParameterKey"
        location "query"
      end 
  
      field "parameter_42_value" do
        alias_for "Parameters.member.42.ParameterValue"
        location "query"
      end 
  
      field "parameter_43_name" do
        alias_for "Parameters.member.43.ParameterKey"
        location "query"
      end 
  
      field "parameter_43_value" do
        alias_for "Parameters.member.43.ParameterValue"
        location "query"
      end 
  
      field "parameter_44_name" do
        alias_for "Parameters.member.44.ParameterKey"
        location "query"
      end 
  
      field "parameter_44_value" do
        alias_for "Parameters.member.44.ParameterValue"
        location "query"
      end 
  
      field "parameter_45_name" do
        alias_for "Parameters.member.45.ParameterKey"
        location "query"
      end 
  
      field "parameter_45_value" do
        alias_for "Parameters.member.45.ParameterValue"
        location "query"
      end 
  
      field "parameter_46_name" do
        alias_for "Parameters.member.46.ParameterKey"
        location "query"
      end 
  
      field "parameter_46_value" do
        alias_for "Parameters.member.46.ParameterValue"
        location "query"
      end 
  
      field "parameter_47_name" do
        alias_for "Parameters.member.47.ParameterKey"
        location "query"
      end 
  
      field "parameter_47_value" do
        alias_for "Parameters.member.47.ParameterValue"
        location "query"
      end 
  
      field "parameter_48_name" do
        alias_for "Parameters.member.48.ParameterKey"
        location "query"
      end 
  
      field "parameter_48_value" do
        alias_for "Parameters.member.48.ParameterValue"
        location "query"
      end 
  
      field "parameter_49_name" do
        alias_for "Parameters.member.49.ParameterKey"
        location "query"
      end 
  
      field "parameter_49_value" do
        alias_for "Parameters.member.49.ParameterValue"
        location "query"
      end 
  
      field "parameter_50_name" do
        alias_for "Parameters.member.50.ParameterKey"
        location "query"
      end 
  
      field "parameter_50_value" do
        alias_for "Parameters.member.50.ParameterValue"
        location "query"
      end

      field "parameter_51_name" do
        alias_for "Parameters.member.51.ParameterKey"
        location "query"
      end 
  
      field "parameter_51_value" do
        alias_for "Parameters.member.51.ParameterValue"
        location "query"
      end 
  
      field "parameter_52_name" do
        alias_for "Parameters.member.52.ParameterKey"
        location "query"
      end 
  
      field "parameter_52_value" do
        alias_for "Parameters.member.52.ParameterValue"
        location "query"
      end 
  
      field "parameter_53_name" do
        alias_for "Parameters.member.53.ParameterKey"
        location "query"
      end 
  
      field "parameter_53_value" do
        alias_for "Parameters.member.53.ParameterValue"
        location "query"
      end 
  
      field "parameter_54_name" do
        alias_for "Parameters.member.54.ParameterKey"
        location "query"
      end 
  
      field "parameter_54_value" do
        alias_for "Parameters.member.54.ParameterValue"
        location "query"
      end 
  
      field "parameter_55_name" do
        alias_for "Parameters.member.55.ParameterKey"
        location "query"
      end 
  
      field "parameter_55_value" do
        alias_for "Parameters.member.55.ParameterValue"
        location "query"
      end 
  
      field "parameter_56_name" do
        alias_for "Parameters.member.56.ParameterKey"
        location "query"
      end 
  
      field "parameter_56_value" do
        alias_for "Parameters.member.56.ParameterValue"
        location "query"
      end 
  
      field "parameter_57_name" do
        alias_for "Parameters.member.57.ParameterKey"
        location "query"
      end 
  
      field "parameter_57_value" do
        alias_for "Parameters.member.57.ParameterValue"
        location "query"
      end 
  
      field "parameter_58_name" do
        alias_for "Parameters.member.58.ParameterKey"
        location "query"
      end 
  
      field "parameter_58_value" do
        alias_for "Parameters.member.58.ParameterValue"
        location "query"
      end 
  
      field "parameter_59_name" do
        alias_for "Parameters.member.59.ParameterKey"
        location "query"
      end 
  
      field "parameter_59_value" do
        alias_for "Parameters.member.59.ParameterValue"
        location "query"
      end 
  
      field "parameter_60_name" do
        alias_for "Parameters.member.60.ParameterKey"
        location "query"
      end 
  
      field "parameter_60_value" do
        alias_for "Parameters.member.60.ParameterValue"
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

      field "tag_value_6" do
        alias_for "Tags.member.6.Value"
        location "query"
      end 

      field "tag_key_6" do
        alias_for "Tags.member.6.Key"
        location "query"
      end

      field "tag_value_7" do
        alias_for "Tags.member.7.Value"
        location "query"
      end

      field "tag_key_7" do
        alias_for "Tags.member.7.Key"
        location "query"
      end

      field "tag_value_8" do
        alias_for "Tags.member.8.Value"
        location "query"
      end 

      field "tag_key_8" do
        alias_for "Tags.member.8.Key"
        location "query"
      end

      field "tag_value_9" do
        alias_for "Tags.member.9.Value"
        location "query"
      end

      field "tag_key_9" do
        alias_for "Tags.member.9.Key"
        location "query"
      end

      field "tag_value_10" do
        alias_for "Tags.member.10.Value"
        location "query"
      end

      field "tag_key_10" do
        alias_for "Tags.member.10.Key"
        location "query"
      end

      field "tag_value_11" do
        alias_for "Tags.member.11.Value"
        location "query"
      end 

      field "tag_key_11" do
        alias_for "Tags.member.11.Key"
        location "query"
      end 

      field "tag_value_12" do
        alias_for "Tags.member.12.Value"
        location "query"
      end 

      field "tag_key_12" do
        alias_for "Tags.member.12.Key"
        location "query"
      end 

      field "tag_value_13" do
        alias_for "Tags.member.13.Value"
        location "query"
      end 

      field "tag_key_13" do
        alias_for "Tags.member.13.Key"
        location "query"
      end 

      field "tag_value_14" do
        alias_for "Tags.member.14.Value"
        location "query"
      end 

      field "tag_key_14" do
        alias_for "Tags.member.14.Key"
        location "query"
      end 

      field "tag_value_15" do
        alias_for "Tags.member.15.Value"
        location "query"
      end 

      field "tag_key_15" do
        alias_for "Tags.member.15.Key"
        location "query"
      end 

      field "tag_value_16" do
        alias_for "Tags.member.16.Value"
        location "query"
      end 

      field "tag_key_16" do
        alias_for "Tags.member.16.Key"
        location "query"
      end

      field "tag_value_17" do
        alias_for "Tags.member.17.Value"
        location "query"
      end

      field "tag_key_17" do
        alias_for "Tags.member.17.Key"
        location "query"
      end

      field "tag_value_18" do
        alias_for "Tags.member.18.Value"
        location "query"
      end 

      field "tag_key_18" do
        alias_for "Tags.member.18.Key"
        location "query"
      end

      field "tag_value_19" do
        alias_for "Tags.member.19.Value"
        location "query"
      end

      field "tag_key_19" do
        alias_for "Tags.member.19.Key"
        location "query"
      end

      field "tag_value_20" do
        alias_for "Tags.member.20.Value"
        location "query"
      end

      field "tag_key_20" do
        alias_for "Tags.member.20.Key"
        location "query"
      end

      field "tag_value_21" do
        alias_for "Tags.member.21.Value"
        location "query"
      end 

      field "tag_key_21" do
        alias_for "Tags.member.21.Key"
        location "query"
      end 

      field "tag_value_22" do
        alias_for "Tags.member.22.Value"
        location "query"
      end 

      field "tag_key_22" do
        alias_for "Tags.member.22.Key"
        location "query"
      end 

      field "tag_value_23" do
        alias_for "Tags.member.23.Value"
        location "query"
      end 

      field "tag_key_23" do
        alias_for "Tags.member.23.Key"
        location "query"
      end 

      field "tag_value_24" do
        alias_for "Tags.member.24.Value"
        location "query"
      end 

      field "tag_key_24" do
        alias_for "Tags.member.24.Key"
        location "query"
      end 

      field "tag_value_25" do
        alias_for "Tags.member.25.Value"
        location "query"
      end 

      field "tag_key_25" do
        alias_for "Tags.member.25.Key"
        location "query"
      end 

      field "tag_value_26" do
        alias_for "Tags.member.26.Value"
        location "query"
      end 

      field "tag_key_26" do
        alias_for "Tags.member.26.Key"
        location "query"
      end

      field "tag_value_27" do
        alias_for "Tags.member.27.Value"
        location "query"
      end

      field "tag_key_27" do
        alias_for "Tags.member.27.Key"
        location "query"
      end

      field "tag_value_28" do
        alias_for "Tags.member.28.Value"
        location "query"
      end 

      field "tag_key_28" do
        alias_for "Tags.member.28.Key"
        location "query"
      end

      field "tag_value_29" do
        alias_for "Tags.member.29.Value"
        location "query"
      end

      field "tag_key_29" do
        alias_for "Tags.member.29.Key"
        location "query"
      end

      field "tag_value_30" do
        alias_for "Tags.member.30.Value"
        location "query"
      end

      field "tag_key_30" do
        alias_for "Tags.member.30.Key"
        location "query"
      end

      field "tag_value_31" do
        alias_for "Tags.member.31.Value"
        location "query"
      end 

      field "tag_key_31" do
        alias_for "Tags.member.31.Key"
        location "query"
      end 

      field "tag_value_32" do
        alias_for "Tags.member.32.Value"
        location "query"
      end 

      field "tag_key_32" do
        alias_for "Tags.member.32.Key"
        location "query"
      end 

      field "tag_value_33" do
        alias_for "Tags.member.33.Value"
        location "query"
      end 

      field "tag_key_33" do
        alias_for "Tags.member.33.Key"
        location "query"
      end 

      field "tag_value_34" do
        alias_for "Tags.member.34.Value"
        location "query"
      end 

      field "tag_key_34" do
        alias_for "Tags.member.34.Key"
        location "query"
      end 

      field "tag_value_35" do
        alias_for "Tags.member.35.Value"
        location "query"
      end 

      field "tag_key_35" do
        alias_for "Tags.member.35.Key"
        location "query"
      end 

      field "tag_value_36" do
        alias_for "Tags.member.36.Value"
        location "query"
      end 

      field "tag_key_36" do
        alias_for "Tags.member.36.Key"
        location "query"
      end

      field "tag_value_37" do
        alias_for "Tags.member.37.Value"
        location "query"
      end

      field "tag_key_37" do
        alias_for "Tags.member.37.Key"
        location "query"
      end

      field "tag_value_38" do
        alias_for "Tags.member.38.Value"
        location "query"
      end 

      field "tag_key_38" do
        alias_for "Tags.member.38.Key"
        location "query"
      end

      field "tag_value_39" do
        alias_for "Tags.member.39.Value"
        location "query"
      end

      field "tag_key_39" do
        alias_for "Tags.member.39.Key"
        location "query"
      end

      field "tag_value_40" do
        alias_for "Tags.member.40.Value"
        location "query"
      end

      field "tag_key_40" do
        alias_for "Tags.member.40.Key"
        location "query"
      end

      field "tag_value_41" do
        alias_for "Tags.member.41.Value"
        location "query"
      end 

      field "tag_key_41" do
        alias_for "Tags.member.41.Key"
        location "query"
      end 

      field "tag_value_42" do
        alias_for "Tags.member.42.Value"
        location "query"
      end 

      field "tag_key_42" do
        alias_for "Tags.member.42.Key"
        location "query"
      end 

      field "tag_value_43" do
        alias_for "Tags.member.43.Value"
        location "query"
      end 

      field "tag_key_43" do
        alias_for "Tags.member.43.Key"
        location "query"
      end 

      field "tag_value_44" do
        alias_for "Tags.member.44.Value"
        location "query"
      end 

      field "tag_key_44" do
        alias_for "Tags.member.44.Key"
        location "query"
      end 

      field "tag_value_45" do
        alias_for "Tags.member.45.Value"
        location "query"
      end 

      field "tag_key_45" do
        alias_for "Tags.member.45.Key"
        location "query"
      end 

      field "tag_value_46" do
        alias_for "Tags.member.46.Value"
        location "query"
      end 

      field "tag_key_46" do
        alias_for "Tags.member.46.Key"
        location "query"
      end

      field "tag_value_47" do
        alias_for "Tags.member.47.Value"
        location "query"
      end

      field "tag_key_47" do
        alias_for "Tags.member.47.Key"
        location "query"
      end

      field "tag_value_48" do
        alias_for "Tags.member.48.Value"
        location "query"
      end 

      field "tag_key_48" do
        alias_for "Tags.member.48.Key"
        location "query"
      end

      field "tag_value_49" do
        alias_for "Tags.member.49.Value"
        location "query"
      end

      field "tag_key_49" do
        alias_for "Tags.member.49.Key"
        location "query"
      end

      field "tag_value_50" do
        alias_for "Tags.member.50.Value"
        location "query"
      end

      field "tag_key_50" do
        alias_for "Tags.member.50.Key"
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

    action "get_stack_events" do
      verb "GET"
      path "/?Action=DescribeStackEvents&StackName=$StackName"

      field "stack_name" do
        alias_for "StackName"
        location "query"
      end  

      output_path "//DescribeStackEventsResult"
    end

    # http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DescribeStackResources.html
    link "resources" do
      path "/?Action=DescribeStackResources&StackName=$StackName"
      type "resources"
      output_path "//DescribeStackResourcesResult/StackResources/member"
    end

    output "StackName","StackId","CreationTime","StackStatus","DisableRollback","StackEvents"

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
    if $status != "CREATE_COMPLETE"
      call sys_log.detail(@operation.get_stack_events())
      raise "Did not complete provision, check audit entry for details"
    end
    @resource = @operation.get()
    call sys_log.detail(@resource.get_stack_events())
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