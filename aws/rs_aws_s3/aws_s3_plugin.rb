name 'aws_s3_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - S3 Plugin"
long_description "Version 1.0"
package "plugins/rs_aws_s3"
import "sys_log"

plugin "rs_aws_s3" do
  endpoint do
    default_host "s3-website-us-east-1.amazonaws.com"
    default_scheme "https"
    query do {
        "Version" => "2012-10-17"
    } 
    end
  end

type "s3" do
    #  field "aws_access_key_id" do
    #    alias_for "AWS Access Key ID"
    #    type      "string"
    #    location  "query"
    #    required true
    #  end
    
    #  field "aws_secret_access_key_id" do
    #    alias_for "AWS Secret Access Key ID"
    #    type      "string"
    #    location  "query"
    #    required true
    #  end
    
    #  field "default_region_name" do
    #    alias_for "default region name"
    #    type      "string"
    #    location  "query"
    #    required true  
    #  end
        
        # bucket acl
        field "display_name" do
          alias_for "DisplayName"
          type "string"
        end

        # bucket acl
        field "bucket_owner_id" do
            alias_for "ID"
            type "string"
        end

        # bucket acl
        field "permission_given_to_the_grantee_for_bucket" do
            alias_for "Permission"
            type "string"
        end

        #http://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonRequestHeaders.html
        # common header
        field "the_date_and_time_amazon_S3_responded" do
            alias_for "Date"
            type "string"
        end

        # common header
        field "the_name_of_the_server_that_created_the_response" do
            alias_for "Server"
            type "string"
        end

         output "DisplayName","ID", "Permission","Date","Server"

          #http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGETpolicy.html
          action "policy" do
            verb "GET"
            path "/?policy HTTP/1.1"
          end
        
          #http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGETacl.html
          action "acl" do
            verb "GET"
            path "/?acl HTTP/1.1"

          end   
    end
    
end

resource_pool "s3" do
    plugin $rs_aws_s3
    host "s3.amazonaws.com"
    auth "key", type: "aws" do
      version     4
      service    's3'
      region     'us-east-1'
      access_key cred('AWS_ACCESS_KEY_ID')
      secret_key cred('AWS_SECRET_ACCESS_KEY')
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
