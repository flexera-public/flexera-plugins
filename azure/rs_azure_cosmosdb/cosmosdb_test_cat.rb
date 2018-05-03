name 'Azure CosmosDB - Test CAT'
rs_ca_ver 20161221
short_description "Azure CosmosDB - Test CAT"
import "sys_log"
import "plugins/rs_azure_cosmosdb"

parameter "subscription_id" do
  like $rs_azure_cosmosdb.subscription_id
  default "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
end

resource "rg", type: "rs_cm.resource_group" do
  name join(["cosmosdb-rg-",last(split(@@deployment.href, "/"))])
  cloud "AzureRM Central US"
end

resource "cosmosdb", type: "rs_azure_cosmosdb.db_account" do
  name join(["cosmosdb-",last(split(@@deployment.href, "/"))])
  resource_group @rg.name
  location "centralus"
  kind "GlobalDocumentDB"
  properties do {
    "databaseAccountOfferType" => "Standard",
    "locations" => [
      {
        "failoverPriority" => "0",
        "locationName" => "westus"
      },
      {
        "failoverPriority" => "1",
        "locationName" => "eastus"
      },
    ],
    "consistencyPolicy" => {
      "defaultConsistencyLevel" => "Session",
      "maxIntervalInSeconds" => "5",
      "maxStalenessPrefix" => "100"
    }
  } end 
  tags do {
      "defaultExperience" => "DocumentDB",
      "costcenter" => "12345",
      "envrionment" => "dev",
      "department" => "engineering"
  } end
end 

output "output_uri" do
  label "Azure CosmosDB URI"
end

output "output_read_locations" do
  label "Azure CosmosDB Read Locations"
end

output "output_write_locations" do
  label "Azure CosmosDB Write Locations"
end

operation "launch" do
  description "Launch the application"
  definition "launch_handler"
  output_mappings do {
    $output_uri => $uri,
    $output_read_locations => $read_locations,
    $output_write_locations => $write_locations
  } end
 end
 
 define launch_handler(@rg,@cosmosdb) return $uri,$read_locations,$write_locations,@cosmosdb,@rg do
   call start_debugging()
   provision(@rg)
   provision(@cosmosdb)
   call stop_debugging()
   $uri = "https://" + @cosmosdb.name + ".documents.azure.com:443/"
   $read_locations = to_s(@cosmosdb.readLocations)
   $write_locations = to_s(@cosmosdb.writeLocations)
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