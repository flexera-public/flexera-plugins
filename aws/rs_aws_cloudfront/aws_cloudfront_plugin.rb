name 'aws_cloudfront_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - CloudFront"
long_description "Version: 1.0"
package "plugins/rs_aws_cloudfront"
import "sys_log"

plugin "rs_aws_cloudfront" do
  endpoint do
    default_scheme "https"
    path "/2017-10-30"
    request_content_type "application/xml"
  end

  # https://docs.aws.amazon.com/cloudfront/latest/APIReference/Welcome.html
  type "distribution" do
    href_templates "/distribution/{{//Distribution/Id}}"

    field "distribution_config" do
      alias_for "DistributionConfig"
      type "composite"
      required true
      location "body"
    end

    output "ActiveTrustedSigners","ARN","DistributionConfig","DomainName","Id","InProgressInvalidationBatches","LastModifiedTime","Status"

    # https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_CreateDistribution.html
    action "create" do
      verb "POST"
      path "/distribution"
      output_path "//Distribution"
    end

    # hhttps://docs.aws.amazon.com/cloudfront/latest/APIReference/API_DeleteDistribution.html
    action "destroy" do
      verb "DELETE"
      path "$href"

      field "if_match" do
        alias_for "If-Match"
        location "header"
      end
    end

    # https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_GetDistribution.html
    action "get" do
      verb "GET"
      path "$href"
      output_path "//Distribution"
    end

    action "show" do
      verb "GET"
      path "distribution/$id"
      output_path "//Distribution"

      field "id" do
        location "path"
      end
    end

    # https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_GetDistributionConfig.html
    action "get_config" do
      verb "GET"
      path "$href/config"
    end

    # https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_ListDistributions.html
    action "list" do
      verb "GET"
      path "/distribution"
      output_path "//DistributionList/Items/DistributionSummary/"
    end

    # https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_UpdateDistribution.html
    action "update" do
      verb "PUT"
      path "$href/config"
      output_path "//Distribution"

      field "if_match" do
        alias_for "If-Match"
        location "header"
      end
    end

    provision "provision_distribution"

    delete    "delete_distribution"
  end

end

resource_pool "cloudfront" do
  plugin $rs_aws_cloudfront
  host "cloudfront.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'cloudfront'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define provision_distribution(@declaration) return @resource do
  sub on_error: stop_debugging() do
    call start_debugging()
    $object = to_object(@declaration)
    $fields = $object["fields"]
    call sys_log.detail("fields: "+to_s($fields))
    @operation = rs_aws_cloudfront.distribution.create($fields)
    $status = @operation.Status
    sub on_error: skip do
      while $status != "Deployed" do
        $status = @operation.Status
        sleep(10)
      end
    end
    @resource = @operation.get()
    call stop_debugging()
  end
end

define delete_distribution(@declaration) do
#  call start_debugging()
#  sub on_error: stop_debugging() do
#    # Get Config
#    $id = @declaration.Id
#    call get_config($id) retrieve $config1,$etag1

    # EDIT: Update entire hash
#    $config1["Enabled"] = "false"
#    @declaration.update(if_match: $etag1, distribution_config: $config1)
#    $status = @my_distribution.Status
#    while $status != "Deployed" do
#      $status = @my_distribution.Status
#      sleep(10)
#    end

    # Delete
#    call get_config($id) retrieve $config2,$etag2
#    @declaration.destroy(if_match: $etag2)
#  end
#  call stop_debugging()
end

define get_config($distribution_id) return $config,$etag do
  call rs_aws_cloudfront.start_debugging()
  sub on_error: rs_aws_cloudfront.stop_debugging() do
    $response = http_get(
      url: 'https://cloudfront.amazonaws.com/2017-10-30/distribution/'+$distribution_id+"/config",
      signature: { type: "aws" }
    )
    $etag = $response["headers"]["Etag"]
    call sys_log.detail("ETAG: "+ to_s($etag))
    $config = $response["body"]["Distribution"]
  end
  call rs_aws_cloudfront.stop_debugging()
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