name "rs_do"
type "plugin"
rs_ca_ver 20161221
short_description "Digital Ocean Plugin"
long_description "Version: 1.0"
package "plugins/rs_do"
import "sys_log"
import "plugin_generics"

plugin "rs_do" do

  endpoint do
    default_host "api.digitalocean.com"
    default_scheme "https"
    path "/v2"
    headers do {
      "Content-Type" => "application/json"
    } end
  end

  type "droplet" do
    href_templates "/droplets/{{droplet.id}}", "/droplets/{{droplets[*].id}}:"
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
      type "string"
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

    field "monitoring" do
      type "string"
    end

    field "volumes" do
      type "array"
    end

    field "tags" do
      type "array"
    end

    output_path "droplet"

    output "id", "name", "memory", "vcpus", "disk", "locked", "created_at", "status", "features","region", "image", "size", "size_slug", "networks", "kernel", "next_backup_window", "backup_ids", "snapshot_ids", "volume_ids", "tags"

    action "get" do
      path "$href"
      verb "GET"
    end

    action "list" do
      path "/droplets"
      verb "GET"
      output_path "droplets[]"
    end

    action "show" do
      path "/droplets/$id"
      verb "GET"

      field "id" do
        location "path"
      end
    end

    action "create" do
      path "/droplets"
      verb "POST"
    end

    action "destroy" do
      path "$href"
      verb "DELETE"
    end

  end

end

resource_pool "rs_do" do
  plugin $rs_do
  auth "key", type: "api_key" do
    key cred("DIGITAL_OCEAN_API_KEY")
    location "header"
    field "Authorization"
    type "Bearer"
  end
end

define provision_droplet(@declaration) return @resource do
  call plugin_generics.start_debugging()
  sub on_error: plugin_generics.stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    $type = $object["type"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail(to_s($object))
    @operation = rs_do.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    $status = @operation.status
    sub on_error: skip, timeout: 10m do
      while $status != "active" do
        $status = @operation.status
        sleep(10)
      end
    end
    @resource = @operation.get()
    call sys_log.detail(to_object(@resource))
  end
  call plugin_generics.stop_debugging()
end

define delete_droplet(@declaration) do
  call plugin_generics.start_debugging()
  sub on_error: plugin_generics.stop_debugging() do
    @declaration.destroy()
  end
  call plugin_generics.stop_debugging()
end