name 'Lambda Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - Lambda"
import "plugins/rs_aws_lambda"

parameter "key1" do
  type "string"
  label "Key1 Value"
  default "Hello"
end

parameter "key2" do
  type "string"
  label "Key2 Value"
  default "World"
end

output "my_output" do
  label "Response"
end

resource "my_function", type: "rs_aws_lambda.function" do
  function_name last(split(@@deployment.href, "/"))
  description join(["launched from SS - ", last(split(@@deployment.href, "/"))])
  runtime "nodejs6.10"
  handler "hello-world.handler"
  role "arn:aws:iam::041819229125:role/lambda_basic_execution"
  code do {
    "S3Bucket" => "DF33_bucket",
    "S3Key" => "hello-world.zip"
  } end  
end

operation "launch" do
  definition "launch"
end

operation "invoke_code" do
  definition "invoke_code"
  output_mappings do {
    $my_output => $response
  } end
end

define launch(@my_function) return @my_function do
  provision(@my_function)
end

define invoke_code(@my_function,$key1,$key2) return @my_function,$response do
  $href = @my_function.href
  $payload = {}
  $payload["key1"] = $key1
  $payload["key2"] = $key2
  $response = @my_function.invoke($payload)
  $response = to_s($response)
  @my_function = rs_aws_lambda.get(href: $href)
end 

