name 'aws_lambda_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Lambda"
long_description "Version: 1.0"
package "plugins/rs_aws_lambda"
import "sys_log"

plugin "rs_aws_lambda" do
  endpoint do
    default_scheme "https"
    path "/2015-03-31"
  end
  
  type "function" do
    href_templates "/functions/{{FunctionName}}?Qualifier={{Version}}","/functions/{{Functions[*].FunctionName}}?Qualifier={{Functions[*].Version}}","/functions/{{Configuration.FunctionName}}?Qualifier={{Configuration.Version}}"
    provision "provision_resource"
    delete    "delete_resource"

    field "code" do
      alias_for "Code"
      type "composite"
      required true
    end
 
    field "dead_letter_config" do
      alias_for "DeadLetterConfig"
      type      "composite"
    end

    field "description" do
      alias_for "Description"
      type "string"
    end 

    field "environment" do
      alias_for "Environment"
      type "composite"
    end 

    field "function_name" do
      alias_for "FunctionName"
      type "string"
      required true
    end

    field "handler" do
      alias_for "Handler"
      type "string"
      required true
    end

    field "kms_key_arn" do
      alias_for "KMSKeyArn"
      type "string"
    end

    field "memory_size" do
      alias_for "MemorySize"
      type "number"
    end

    field "publish" do
      alias_for "Publish"
      type "boolean"
    end

    field "role" do
      alias_for "Role"
      type "string"
      required true
    end

    field "runtime" do
      alias_for "Runtime"
      type "string"
      required true
    end

    field "tags" do
      alias_for "Tags"
      type "composite"
    end

    field "timeout" do
      alias_for "Timeout"
      type "number"
    end

    field "tracing_config" do
      alias_for "TracingConfig"
      type "composite"
    end

    field "vpc_config" do
      alias_for "VpcConfig"
      type "composite"
    end

    # http://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html
    action "create" do
      verb "POST"
      path "/functions"
    end

    # http://docs.aws.amazon.com/lambda/latest/dg/API_DeleteFunction.html
    action "destroy" do
      verb "DELETE"
      path "/functions/$FunctionName"
    end

    action "destroy_version" do
      verb "DELETE"
      path "/function/$FunctionName?Qualifier=$version"

      field "version" do
        location "path"
      end
    end
    
    # http://docs.aws.amazon.com/lambda/latest/dg/API_GetFunction.html
    action "get" do
      verb "GET"
      path "$href"
      output_path "Configuration"
    end
    
    # http://docs.aws.amazon.com/lambda/latest/dg/API_ListFunctions.html
    action "list" do
      verb "GET"
      path "/functions"

      field "function_version" do
        alias_for "FunctionVersion"
        location "query"
      end

      field "marker" do
        alias_for "Marker"
        location "query"
      end 

      field "master_region" do
        alias_for "MasterRegion"
        location "query"
      end

      field "max_items" do
        alias_for "MaxItems"
        location "query"
      end

      output_path "Functions[]"

    end

    # http://docs.aws.amazon.com/lambda/latest/dg/API_GetFunction.html
    action "get_code" do
      verb "GET"
      path "$href"
      output_path "Code"
    end

    # http://docs.aws.amazon.com/lambda/latest/dg/API_UpdateFunctionCode.html
    action "update_code" do
      verb "PUT"
      path "/functions/$FunctionName/code"

      field "dry_run" do
        alias_for "DryRun"
      end

      field "publish" do
        alias_for "Publish"
      end

      field "s3_bucket" do
        alias_for "S3Bucket"
      end

      field "s3_key" do
        alias_for "S3Key"
      end

      field "s3_object_version" do
        alias_for "S3ObjectVersion"
      end

    end 

    # http://docs.aws.amazon.com/lambda/latest/dg/API_UpdateFunctionConfiguration.html
    action "update_config" do
      verb "PUT"
      path "/functions/$FunctionName/configuration" 
    end
    
    # http://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html
    action "invoke" do
      verb "POST"
      path "/functions/$FunctionName/invocations?Qualifier=$Version"
    end 
    
    output "CodeSha256","CodeSize","Description","FunctionArn","FunctionName","Handler","KMSKeyArn","LastModified","MasterArn","MemorySize","Role","Runtime","Timeout","Version"
    
    output "DeadLetterConfig" do
      body_path "DeadLetterConfig.TargetArn"
    end

    output "EnvironmentErrorCode" do
      body_path "Environment.Error.ErrorCode"
    end 

    output "EnvironmentErrorMessage" do
      body_path "Environment.Error.Message"
    end

    output "EnvironmentVariables" do
      body_path "Environment.Variables"
    end

    output "TracingConfigMode" do
      body_path "TracingConfig.Mode"
    end

    output "SecurityGroupIds" do
      body_path "VpcConfig.SecurityGroupIds"
    end

    output "SubnetIds" do
      body_path "VpcConfig.SubnetIds"
    end

    output "VpcId" do
      body_path "VpcConfig.VpcId"
    end

  end
end

resource_pool "rs_aws_lambda" do
  plugin $rs_aws_lambda
  host "lambda.us-east-1.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'lambda'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end

define provision_resource(@declaration) return @resource do
  call start_debugging()
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    @operation = rs_aws_lambda.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.get()
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define delete_resource(@resource) do
  sub on_error: skip do
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary("Destroy Resource")
    call sys_log.detail(to_object(@resource))
  end
  $version = @resource.Version
  if $version == "$LATEST"
    @resource.destroy()
  else 
    @resource.destroy_version(version: $version)
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
