# CFT via URL Example.
# 
# When launching a CFT from CAT, one can specify the CFT body "in line" in the CAT itself.
# Or, one can reference the CFT via an S3 bucket URL.
# 
# One form of the URL use-case is where the CFT is in an S3 bucket that has at least public READ permissions.
# In this case, the CAT just references the URL.
#
# Another form of the URL use-case, is where a "pre-signed URL" is used. S3 buckets can be referenced by an authenticated URL
# that is signed and has an expiry of no more than 1 week. 
# In this case, the CAT can generate the URL and then reference it.
#
# This CAT demonstrates both use-cases.
#
# PREREQUISITES:
# If testing the pre-signed URL model, you need to store a CFT in an S3 bucket.
# You can grab the public CFT referenced below and drop it in your S3 bucket.
# BE SURE to update the map_bucket mapping accordingly.
# 


name "CFT S3 URL Plugin Test"
rs_ca_ver 20161221
short_description  "CFT Test"
long_description ""

import "plugins/rs_aws_cft"
import "pft/s3_utilities" # found in https://github.com/rs-services/rs-premium_free_trial

parameter "param_use_private_s3" do  
  type "string"  
  label "Use Private S3"  
  description "Test the private S3 bucket use-case"  
  allowed_values "yes", "no"
  default "no"
end

output "out_public_ip" do
  label "Public IP"
end

#####
# UPDATE this mapping with your bucket and file (aka object) information for the CFT you want to use.
# If you use a CFT other than the default one, you may need to update the output and related output mapping.
mapping "map_cft" do {
  "cft_location" => {
    "bucket" => "BUCKET_NAME",
    "object" => "CFT_YAML_OR_JSON_FILE" 
  }
} end

# Default CFT is a publicly available simple EC2 instance CFT published by AWS.
# If the user selects to use private S3 example, this URL is overwritten in the RCL below.
resource "stack", type: "rs_aws_cft.stack" do
  stack_name join(["cft-", last(split(@@deployment.href, "/"))])
  template_url "https://s3-us-west-2.amazonaws.com/cloudformation-templates-us-west-2/EC2InstanceWithSecurityGroupSample.template"
  description "CFT Test"
  parameter_1_name "KeyName"
  parameter_1_value @ssh_key.name
end

# The CFT needs an SSH key.
# So create one.
resource "ssh_key", type: "ssh_key" do
  name join(["cft_sshkey_", last(split(@@deployment.href,"/"))])
  cloud "EC2 us-east-1"
end

operation "launch" do
  description "Launch the application"
  definition "launch_handler"
end

# Demonstrates how to get outputs
# Over complicated example given the single output returned by the example CFT.
# But hopefully it helps when faced with a CFT that returns multiple outputs.
operation "enable" do
  definition "post_launch"
  output_mappings do {
    $out_public_ip => $public_ip
  } end
end

define launch_handler(@stack, @ssh_key, $param_use_private_s3, $map_cft) return @stack, @ssh_key do
  task_label("provision CFT Stack")
  
  provision(@ssh_key) # an SSH key is required by the sample CFT being used
  
  if $param_use_private_s3 == "yes"
    # Need to overwrite the template_url attribute with the generated URL
    $bucket = map($map_cft, "cft_location", "bucket")
    $object = map($map_cft, "cft_location", "object")
    call s3_utilities.get_signed_url($bucket, $object) retrieve $signed_url
  
    $stack = to_object(@stack)
    $stack["fields"]["template_url"] = $signed_url
    @stack = $stack
  end
  
  # If the private S3 option is not used, the provision will just use the URL that was specified in the resource declaration above.
  provision(@stack)
end

# Outputs are provided as two arrays. 
# One array contains the keys. The other array contains the values.
# Given the CFT example and the fact that it returns a single input, the code below could be replaced with 
#    $domain_name = $OutputValue[0]
# But what's the fun in that ...?
define post_launch(@stack) return $public_ip do

  $output_keys = @stack.OutputKey
  $output_values = @stack.OutputValue
  
  $i = 0
  $public_ip = ""
  foreach $output_key in $output_keys do
    if $output_key == "PublicIP"
      $public_ip = $output_values[$i]
    elsif $output_key == "AnotherOutput"  # this will not fire given the CFT example. Provided as an example bit of code.
      $another_output = $output_values[$i]
    end
    $i = $i + 1
  end
end

