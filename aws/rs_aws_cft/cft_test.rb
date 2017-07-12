name "CFT Plugin Test"
rs_ca_ver 20161221
short_description  "CFT Test"
long_description ""

import "plugins/rs_aws_cft"

resource "drupal_cft", type: "rs_aws_cft.stack" do
 stack_name join(["cft-cf-", last(split(@@deployment.href, "/"))])
 template_body ""
 description "cft for cft stack"
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
end

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
              "DomainName": "myelb-1-1932158363.us-east-1.elb.amazonaws.com",
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

define launch_handler(@drupal_cft) return $cft_template,@drupal_cft do
  call generate_cloudformation_template() retrieve $cft_template
  task_label("provision CFT Stack")
  $rds_cft = to_object(@drupal_cft)
  $rds_cft["fields"]["template_body"] = $cft_template
  @drupal_cft = $rds_cft
  provision(@drupal_cft)
end
