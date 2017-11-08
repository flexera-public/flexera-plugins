name 'aws_s3_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - S3 Plugin"
long_description "Version 1.0"
package "plugins/rs_aws_s3"
import "sys_log"

plugin "rs_aws_s3" do
  endpoint do
    default_host "s3.amazonaws.com"
    default_scheme "https"
    query do {
        "Version" => "2012-10-17"
    } 
    end
  end

type "bucket" do
        # bucket acl
        field "bucket_name" do
          type "string"
          required true
          location "path"
        end

        # bucket acl
        #field "bucket_owner_id" do
        #    alias_for "ID"
        #    type "string"
        #end

        # bucket acl
        #field "permission_given_to_the_grantee_for_bucket" do
        #    alias_for "Permission"
        #    type "string"
        #end

        #http://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonRequestHeaders.html
        # common header
        #field "the_date_and_time_amazon_S3_responded" do
        #    alias_for "Date"
        #    type "string"
        #end

        # common header
        #field "the_name_of_the_server_that_created_the_response" do
        #    alias_for "Server"
        #    type "string"
        #end

         output "DisplayName","ID", "Permission","Date","Server"


          #http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGETpolicy.html
          action "policy" do
            verb "GET"
            path "/$Bucket_Name?policy"
          end
        
          #http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGETacl.html
          action "acl" do
            verb "GET"
            path "/$Bucket_Name?acl"   

          end   

          provision "no_operation"
          delete "no_operation"
      
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


   operation "launch" do
    label "Launch"
    definition "gen_launch"
  end

   resource "my_bucketinfo", type: "rs_aws_s3.bucket" do
    bucket_name "tushar-rightscale"
  end

  define gen_launch(@my_bucketinfo) return @my_bucketinfo do
    call start_debugging()
    sub on_error:stop_debugging() do
       provision(@my_bucketinfo)
      end
    call stop_debugging()
  end