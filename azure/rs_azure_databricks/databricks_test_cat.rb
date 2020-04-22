name 'Azure Databricks - Test CAT'
rs_ca_ver 20161221
short_description "Azure Databricks - Test CAT"
import "sys_log"
import "plugins/rs_azure_databricks"

parameter "subscription_id" do
  like $rs_azure_databricks.subscription_id
  default "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
end

parameter "resource_group" do
  type "string"
  label "Resource Group"
end 

resource "databricks", type: "rs_azure_databricks.workspace" do
  name join(["databricks-",last(split(@@deployment.href, "/"))])
  resource_group $resource_group
  location "centralus"
  sku do {
    "name" => "trial"
  } end
  properties do {
    "managedResourceGroupId" => join(["/subscriptions/",$subscription_id,"/resourceGroups/databricks-foo-test"])
  } end 
  tags do {
      "costcenter" => "12345",
      "envrionment" => "dev",
      "department" => "engineering"
  } end
end 

operation "launch" do
  description "Launch the application"
  definition "launch_handler"
end
 
 define launch_handler(@databricks) return @databricks do
   call start_debugging()
   provision(@databricks)
   call stop_debugging()
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