name 'ARM Template Test CAT'
rs_ca_ver 20161221
short_description "ARM Template Test CAT"
import "plugins/rs_azure_template"

parameter "subscription_id" do
  like $rs_azure_template.subscription_id
end

resource "my_template", type: "rs_azure_template.deployment" do
  name join(["SS-test", last(split(@@deployment.href, "/"))])
  resource_group "DF-Testing"
  properties do {
    "templateLink" => { 
      "uri" => "https://dftestingdiag134.blob.core.windows.net/rs-plugin-template-test/template.json" },
    "parameters" => "",
    "mode" => "Incremental"
  } end
end 

operation "launch" do
  definition "launch"
end 

define launch(@my_template) return @my_template do
  call get_arm_template_params() retrieve $params
  $object = to_object(@my_template)
  $object["fields"]["properties"]["parameters"] = $params
  @my_template = $object
  provision(@my_template)
end 

define get_arm_template_params() return $params do
  $params = {
    "administratorLogin": {
        "value": "foobar"
    },
    "location": {
        "value": "centralus"
    },
    "serverName": {
        "value": "df-manual"
    }
}
end 