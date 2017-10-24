name 'SQS Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - SQS"
import "plugins/rs_aws_sqs"

parameter "queueUrl" do
  type "string"
  label "QueueUrl"
  default "https://sqs.us-west-2.amazonaws.com/954233984546/SOL-9000.fifo"
end

parameter "attributeName" do
  type "string"
  label "Attribute Name"
  default "AudioFile"
end

parameter "attributeValue" do
  type "string"
  label "Attribute Value"
  default "speech_20171018232943238.mp3"
end

parameter "body" do
  type "string"
  label "Body Value"
  default "HelloWorld"
end

parameter "deduplication_id" do
  type "string"
  label "Deduplication Id"
  default "1"
end
  
parameter "group_id" do
  type "string"
  label "Group Id"
  default "Creator"
end

operation "send_message" do
  definition "send_message"
end

define send_message($group_id,$deduplication_id,$attributeName,$attributeValue,$body,$queueUrl) do
  rs_aws_sqs.queue.send_message(
    MessageAttributeName: $attributeName,
    MessageAttributeValue: $attributeValue,
    MessageAttributeDataType: "String",
    MessageBody: $body,
    MessageDeduplicationId: $deduplication_id,
    MessageGroupId: $group_id,
    QueueUrl: $queueUrl)
end 
