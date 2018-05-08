name 'Digital Ocean Test CAT'
rs_ca_ver 20161221
short_description "Digital Ocean Plugin - Test CAT"
import "plugins/rs_do"

output "name" do
  label "Droplet Name"
  default_value @my_droplet.name
end

resource "my_droplet", type: "rs_do.droplet" do
  name join(["rightscale-",last(split(@@deployment.href, "/"))])
  region "nyc1"
  size "s-1vcpu-1gb"
  image "docker"
end
