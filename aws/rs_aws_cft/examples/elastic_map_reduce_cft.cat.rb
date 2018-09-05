name "Elastic Map Reduce CAT"
rs_ca_ver 20161221
short_description  "Elastic Map Reduce CAT"
long_description ""

import "plugins/rs_aws_cft"

parameter "key_name" do
  type "string"
  label "SSH Key Name"
  default "default"
end

parameter "master_instance_type" do
  type "string"
  label "Master Instance Type"
  default "m3.xlarge"
end

parameter "core_instance_type" do
  type "string"
  label "Core Instance Type"
  default "m3.xlarge"
end

parameter "number_of_core_instances" do
  type "number"
  label "Number of Core Instances"
  default 2
end

parameter "subnet_id" do
  type "string"
  label "subnet_id"
  default "subnet-7c295240"
end

parameter "log_uri" do
  type "string"
  label "LogUri"
  default "s3://emrclusterlogbucket/"
end

parameter "s3_data_uri" do
  type "string"
  label "S3DataUri"
  default "s3://emrclusterdatabucket/"
end

parameter "release_label" do
  type "string"
  label "ReleaseLabel"
  default "emr-5.16.0"
end

parameter "applications" do
  type "string"
  label "Applications"
  default "Ganglia,Hive,Hue,Mahout,Pig,Tez,Spark,ZooKeeper"
end

resource "stack", type: "rs_aws_cft.stack" do
  stack_name join(["emr-", last(split(@@deployment.href, "/"))])
  capabilities "CAPABILITY_IAM"
  template_body ""
  description "elastic map reduce"
end

output "out_domain_name" do
  label "Domain Name"
end

operation "launch" do
  description "Launch the application"
  definition "launch_handler"
  output_mappings do {
    $out_domain_name => $domain_name
  } end
end

define launch_handler(@stack,$key_name,$master_instance_type,$core_instance_type,$number_of_core_instances,$subnet_id,$log_uri,$s3_data_uri,$release_label,$applications) return $cft_template,@stack,$domain_name do
  call generate_cloudformation_template($key_name,$master_instance_type,$core_instance_type,$number_of_core_instances,$subnet_id,$log_uri,$s3_data_uri,$release_label,$applications) retrieve $cft_template
  task_label("provision CFT Stack")
  $stack = to_object(@stack)
  $stack["fields"]["template_body"] = $cft_template
  @stack = $stack
  provision(@stack)
  $output_keys = @stack.OutputKey
  $output_values = @stack.OutputValue
  
  $i = 0
  foreach $output_key in $output_keys do
    if $output_key == "DomainName"
      $domain_name = $output_values[$i]
    elsif $output_key == "AnotherOutput"  # this will fire given the CFT example. Provided as an example bit of code.
      $another_output = $output_values[$i]
    end
    $i = $i + 1
  end
end

# Example CFT
define generate_cloudformation_template($key_name,$master_instance_type,$core_instance_type,$number_of_core_instances,$subnet_id,$log_uri,$s3_data_uri,$release_label,$applications) return $cft_template do
  $app_arr = [{"Name":"Hadoop"}]
  foreach $app in split($applications,',') do
   $app_arr << { "Name": $app }
  end
  $app_json = to_json($app_arr)

  $cft_template = to_s('{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "Best Practice EMR Cluster for Spark or S3 backed Hbase",
  "Parameters": {
    "EMRClusterName": {
      "Description": "Name of the cluster",
      "Type": "String",
      "Default": "'+join(["emr-", last(split(@@deployment.href, "/"))])+'"
    },
    "KeyName": {
      "Description": "Must be an existing Keyname",
      "Type": "String",
      "Default": "'+$key_name+'"
    },
    "MasterInstanceType": {
      "Description": "Instance type to be used for the master instance.",
      "Type": "String",
      "Default": "'+$master_instance_type+'"
    },
    "CoreInstanceType": {
      "Description": "Instance type to be used for core instances.",
      "Type": "String",
      "Default": "'+$core_instance_type+'"
    },
    "NumberOfCoreInstances": {
      "Description": "Must be a valid number",
      "Type": "Number",
      "Default": '+$number_of_core_instances+'
    },
    "SubnetID": {
      "Description": "Must be a valid public subnet ID",
      "Default": "'+$subnet_id+'",
      "Type": "String"
    },
    "LogUri": {
      "Description": "Must be a valid S3 URL",
      "Default": "'+$log_uri+'",
      "Type": "String"
    },
    "S3DataUri": {
      "Description": "Must be a valid S3 bucket URL",
      "Default": "'+$s3_data_uri+'",
      "Type": "String"
    },
    "ReleaseLabel": {
      "Description": "Must be a valid EMR release version",
      "Default": "'+$release_label+'",
      "Type": "String"
    }
  },
  "Mappings": {},
  "Resources": {
    "EMRCluster": {
      "DependsOn": [
        "EMRClusterServiceRole",
        "EMRClusterinstanceProfileRole",
        "EMRClusterinstanceProfile"
      ],
      "Type": "AWS::EMR::Cluster",
      "Properties": {
        "Applications": '+$app_json+',
        "Configurations": [
          {
            "Classification": "hbase-site",
            "ConfigurationProperties": {
              "hbase.rootdir":{"Ref":"S3DataUri"}
            }
          },
          {
            "Classification": "hbase",
            "ConfigurationProperties": {
              "hbase.emr.storageMode": "s3"
            }
          }
        ],
        "Instances": {
          "Ec2KeyName": {
            "Ref": "KeyName"
          },
          "Ec2SubnetId": {
            "Ref": "SubnetID"
          },
          "AdditionalMasterSecurityGroups" : [ "sg-06637ce19c1a45f91" ],
          "AdditionalSlaveSecurityGroups" : [ "sg-0d77ba105c4fbf6f0" ],
          "MasterInstanceGroup": {
            "InstanceCount": 1,
            "InstanceType": {
              "Ref": "MasterInstanceType"
            },
            "Market": "ON_DEMAND",
            "Name": "Master"
          },
          "CoreInstanceGroup": {
            "InstanceCount": {
              "Ref": "NumberOfCoreInstances"
            },
            "InstanceType": {
              "Ref": "CoreInstanceType"
            },
            "Market": "ON_DEMAND",
            "Name": "Core"
          },
          "TerminationProtected": false
        },
        "VisibleToAllUsers": true,
        "JobFlowRole": {
          "Ref": "EMRClusterinstanceProfile"
        },
        "ReleaseLabel": {
          "Ref": "ReleaseLabel"
        },
        "LogUri": {
          "Ref": "LogUri"
        },
        "Name": {
          "Ref": "EMRClusterName"
        },
        "AutoScalingRole": "EMR_AutoScaling_DefaultRole",
        "ServiceRole": {
          "Ref": "EMRClusterServiceRole"
        }
      }
    },
    "EMRClusterServiceRole": {
      "Type": "AWS::IAM::Role",
      "Properties": {
        "AssumeRolePolicyDocument": {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Principal": {
                "Service": [
                  "elasticmapreduce.amazonaws.com"
                ]
              },
              "Action": [
                "sts:AssumeRole"
              ]
            }
          ]
        },
        "ManagedPolicyArns": [
          "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
        ],
        "Path": "/"
      }
    },
    "EMRClusterinstanceProfileRole": {
      "Type": "AWS::IAM::Role",
      "Properties": {
        "AssumeRolePolicyDocument": {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Principal": {
                "Service": [
                  "ec2.amazonaws.com"
                ]
              },
              "Action": [
                "sts:AssumeRole"
              ]
            }
          ]
        },
        "ManagedPolicyArns": [
          "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
        ],
        "Path": "/"
      }
    },
    "EMRClusterinstanceProfile": {
      "Type": "AWS::IAM::InstanceProfile",
      "Properties": {
        "Path": "/",
        "Roles": [
          {
            "Ref": "EMRClusterinstanceProfileRole"
          }
        ]
      }
    }
  },
  "Outputs": {
    "DomainName" : {
      "Description" : "Domain Name",
      "Value" : { "Fn::GetAtt" : [ "EMRCluster", "MasterPublicDNS" ]}
    }
  }
}')
end
