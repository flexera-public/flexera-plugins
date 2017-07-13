name 'rs_azure_sql'
type 'plugin'
rs_ca_ver 20161221
short_description "Amazon Web Services - Elastic Load Balancer"
package "plugins/rs_azure_sql"
import "sys_log"

plugin "rs_azure_sql" do
  endpoint do
    default_scheme "https"
    query do {
      "api-version" => "2014-04-01"
    } end
  end
end
