name "GCE Plugin Master Test"
rs_ca_ver 20161221
short_description "Master test CAT for the GCE Plugin"
type 'application'

import "sys_log"
import "plugins/gce/address"

parameter "gce_project" do
  like $address.gce_project
  default "rightscale.com:services1"
end

parameter "gce_region" do
  like $address.gce_region
  default "us-east1"
end

output "insert_min" do
  like $address.insert_min
end

operation "launch" do
  definition "launch"
end

define launch() do
end
