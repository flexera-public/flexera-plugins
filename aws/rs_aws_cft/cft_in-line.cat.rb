# In-line CFT Example.
# 
# When launching a CFT from CAT, one can specify the CFT body "in line" in the CAT itself.
# Or, one can reference the CFT via an S3 bucket URL.
#
# This example CAT uses the in-line method.


name "CFT In-Line Plugin Test"
rs_ca_ver 20161221
short_description  "CFT Test"
long_description ""

import "plugins/rs_aws_cft"

output "out_domain_name" do
  label "Domain Name"
end

resource "stack", type: "rs_aws_cft.stack" do
  stack_name join(["cft-", last(split(@@deployment.href, "/"))])
  template_body "" # CFT body is inserted below
  description "CFT Test"
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
    $out_domain_name => $domain_name
  } end
end

define launch_handler(@stack) return $cft_template,@stack do
  call generate_cloudformation_template() retrieve $cft_template
  task_label("provision CFT Stack")
  $stack = to_object(@stack)
  $stack["fields"]["template_body"] = $cft_template
  @stack = $stack
  provision(@stack)
end

# Outputs are provided as two arrays. 
# One array contains the keys. The other array contains the values.
# Given the CFT example and the fact that it returns a single input, the code below could be replaced with 
#    $domain_name = $OutputValue[0]
# But what's the fun in that ...?
define post_launch(@stack) return $domain_name do

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
define generate_cloudformation_template() return $cft_template do
  $cft_template = to_s('{ "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "CloudFrontDistribution": {
      "Type": "AWS::CloudFront::Distribution",
      "Properties": {
        "DistributionConfig": {
          "Comment": "Final Version",
          "Enabled": true,
          "PriceClass": "PriceClass_All",
          "DefaultCacheBehavior": {
            "TargetOriginId": "myelb-1",
            "ViewerProtocolPolicy": "allow-all",
            "MinTTL": 0,
            "AllowedMethods": [
              "HEAD",
              "DELETE",
              "POST",
              "GET",
              "OPTIONS",
              "PUT",
              "PATCH"
            ],
            "CachedMethods": [
              "HEAD",
              "GET"
            ],
            "ForwardedValues": {
              "QueryString": true,
              "Headers": [
                "Host",
                "Origin"
              ],
              "Cookies": {
                "Forward": "all"
              }
            }
          },
          "Origins": [
            {
              "DomainName": "myelb-1-123456789.us-east-1.elb.amazonaws.com",
              "Id": "myelb-1",
              "CustomOriginConfig": {
                "HTTPPort": "80",
                "HTTPSPort": "443",
                "OriginProtocolPolicy": "http-only"
              }
            }
          ],
          "Restrictions": {
            "GeoRestriction": {
              "RestrictionType": "none",
              "Locations": [

              ]
            }
          },
          "ViewerCertificate": {
            "CloudFrontDefaultCertificate": "true",
            "MinimumProtocolVersion": "TLSv1"
          }
        }
      }
    }
  },
  "Outputs" : {
  "DomainName" : {
    "Description" : "Domain Name",
    "Value" : { "Fn::Join" : ["", ["http://", { "Fn::GetAtt" : [ "CloudFrontDistribution", "DomainName" ]}]] }
  }
  },
  "Description": "Cloudfront Definition for RS"
}')
end
