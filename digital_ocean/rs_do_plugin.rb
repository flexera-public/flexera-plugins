name "rs_do"
type "plugin"
rs_ca_ver 20161221
short_description "Digital Ocean Plugin"
long_description "Version: 1.0"
package "plugins/rs_do"
import "sys_log"

plugin "do" do

  credential "DO_TOKEN"

  endpoint do
    host "https://api.digitalocean.com"
    path "/v2"
    headers do {
      "Authorization" => "Bearer $DO_TOKEN"
    } end
  end

  type "droplet" do
    href_templates "/droplets/:droplet.id:", "/droplets/:droplets[*].id:"
    provision "provision_droplet"
    delete "delete_droplet"

    field "name" do
      type "string"
      required true
    end
    field "region" do
      type "string"
      required true
    end
    field "size" do
      type "string"
      required true
    end
    field "image" do
      type "number"
      required true
    end
    field "ssh_keys" do
      type "array"
    end
    field "backups" do
      type "boolean"
    end
    field "ipv6" do
      type "boolean"
    end
    field "private_networking" do
      type "boolean"
    end
    field "user_data" do
      type "string"
    end

    output "id", "name", "memory", "vcpus", "disk", "locked", "created_at", "status", "features","region", "image", "size", "size_slug", "networks", "kernel", "next_backup_window"

    action "list", "show", "create", "destroy"
    action "operate" do
      path "/droplets/:id/actions"
      type "action"
    end
    action "kernels" do
      verb "GET"
      path "/droplets/:id/kernels"
    end

    link "actions" do
      type "action"
      href "/droplets/:id/actions"
    end
    link "snapshots" do
      type "image"
      href "/droplets/:id/snapshots"
    end
    link "backups" do
      type "image"
      href "/droplets/:id/backups"
    end
    link "neighbors" do
      type "droplet"
      href "/droplets/:id/neighbors"
    end
    link "last" do
      type "droplet"
      url "links.pages.last"
    end
    link "next" do
      type "droplet"
      url "links.pages.next"
    end

  end

  type "domain" do
    href_templates "/domains/:domain.name:", "/domains/:domains[*].name:"

    field "name" do
      type "string"
      required true
    end

    field "ip_address" do
      type "string"
      required true
      regex "(([A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}|([0-9]{1,3}\.){3}[0-9]{1,3})"
    end

    output "name", "ttl", "zone_file"

    action "list", "show", "create", "delete"
  end

  type "record" do
    href_templates "/domains/$domain_name/records/:domain_record.id:", "/domains/$domain_name/records/:domain_records[*].id:"

    field "type" do
      type "string"
      required true
      enum "A", "MX", "CNAME", "TXT", "AAAA", "SRV", "NS"
    end

    field "name" do
      type "string"
    end

    field "data" do
      type "string"
    end

    field "priority" do
      type "number"
    end

    field "port" do
      type "number"
    end

    field "weight" do
      type "number"
    end

    output "id", "type", "name", "data", "priority", "port", "weight"
  end

  type "action" do
    href_templates "/:action.id:", "/:actions[*].id:"

    output "id", "status", "type", "started_at", "completed_at", "resource_id", "resource_type","region", "region_slug"

    action "list", "show"

    link "last" do
      type "action"
      url "links.pages.last"
    end

    link "next" do
      type "action"
      url "links.pages.next"
    end

  end

  type "image" do
    href_templates "/:images[*].id:"

    output "id", "name", "type", "distribution", "slug", "public", "regions", "min_disk_size"

    action "list", "show", "update", "delete"

    action "operate" do
      path "/images/:id/actions"
      type "action"
    end

    link "last" do
      type "image"
      url "links.pages.last"
    end

    link "next" do
      type "image"
      url "links.pages.next"
    end

  end

  type "ssh_key" do
    href_templates "/:ssh_key.id:", "/:ssh_keys[*].id:"

    field "name" do
      type "string"
      required true
    end

    field "public_key" do
      type "string"
      required true
    end

    output "id", "name", "fingerprint", "public_key"

    link "last" do
      type "ssh_key"
      url "links.pages.last"
    end

    link "next" do
      type "ssh_key"
      url "links.pages.next"
    end
  end

  type "region" do
    href_templates "/:regions[*].slug:"
    output "slug", "name", "sizes", "features", "available", "sizes"
    action "list"
  end

  type "size" do
    href_templates "/:sizes[*].slug:"
    output "slug", "memory", "vcpus", "disk", "transfer", "price_monthly", "price_hourly",
           "available", "regions"
    action "list"
  end

end