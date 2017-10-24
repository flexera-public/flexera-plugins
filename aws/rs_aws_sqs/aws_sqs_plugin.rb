name 'aws_sqs_plugin'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - SQS"
long_description "API Version 2012-11-05"
package "plugins/rs_aws_sqs"
import "sys_log"

plugin "rs_aws_sqs" do
  endpoint do
    default_scheme "https"
    path "/"
    query do {
      "Version" => "2012-11-05"
    }end
  end
  
  type "queue" do
    href_templates "{{//QueueUrl}}"

    # http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_ListQueues.html
    action "list" do
        field "QueueNamePrefix" do
          location "query"
        end
            
      verb "POST"
      path "?Action=ListQueues"
    end

    # http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/sqs-api.pdf#API_GetQueueUrl
    # action "get" do

    # end

    action "send_message" do
      field "MessageAttributeName" do
          alias_for "MessageAttribute.1.Name"
          location "query"
      end

      field "MessageAttributeValue" do
          alias_for "MessageAttribute.1.Value.StringValue"
          location "query"
      end

      field "MessageAttributeDataType" do
        alias_for "MessageAttribute.1.Value.DataType"
        location "query"
      end
      
      field "MessageBody" do
        location "query"
      end
      field "MessageDeduplicationId" do
        location "query"
      end
      field "MessageGroupId" do
        location "query"
      end
      field "QueueUrl" do
        location "query"
      end
      
      verb "POST"
      path "?Action=SendMessage"
    end 

    output "QueueUrl" do
      body_path "/Queu"
    end

  end
end

resource_pool "rs_aws_sqs" do
  plugin $rs_aws_sqs
  host "sqs.us-west-2.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'sqs'
    region     'us-west-2'
    access_key cred('SOL_AWS_ACCESS_KEY_ID')
    secret_key cred('SOL_AWS_SECRET_ACCESS_KEY')
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
