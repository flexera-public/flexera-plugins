name "rs_riverbed_netprofiler"
type "plugin"
rs_ca_ver 20161221
short_description "Riverbed Netprofiler Plugin"
long_description "Version: 1.0"
package "plugins/rs_riverbed_netprofiler"
import "sys_log"

plugin "rs_riverbed_steelhead_mgmt_til_networking" do
  endpoint do
    default_host "https://wstunnel1-1.rightscale.com"
    default_scheme "https"
    path "_token/$tunnel_token"
  end

  parameter "tunnel_token" do
    type "string"
    label "wsTunnel token"
    description "wsTunnel token"
  end

  type "applications" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "app_id" do
      type "number"
      location "body"
    end

    field "config" do
      type "object"
      location "body"
      required true
    end

    field "enabled" do
      type "string"
      location "body"
      required true
    end

    field "id" do
      type "number"
      location "body"
    end

    field "name" do
      type "string"
      location "body"
      required true
    end
    
    field "override" do
      type "string"
      location "body"
      required true
    end
    
    field "priority" do
      type "number"
      location "body"
    end
    
    field "signatures" do
      type "array"
      location "body"
      required true
    end
    
    field "sources" do
      type "array"
      location "body"
    end
    
    field "limit" do
      type "number"
      location "query"
    end
    
    field "offset" do
      type "number"
      location "query"
    end
    
    field "enabled" do
      type "string"
      location "query"
    end
    
    field "sort" do
      type "string"
      location "query"
    end
    
    field "sortby" do
      type "string"
      location "query"
    end
    
    field "sources" do
      type "string"
      location "query"
    end
    
    field "type" do
      type "string"
      location "query"
    end
    
    field "override" do
      type "string"
      location "query"
    end
    
    field "priority" do
      type "number"
      location "query"
    end
  end

  type "autonomous_systems" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "id" do
      type "number"
      location "body"
      required true
    end
    
    field "is_public" do
      type "string"
      location "body"
      required true
    end
    
    field "name" do
      type "string"
      location "body"
      required true
    end
    
    field "limit" do
      type "number"
      location "query"
    end
    
    field "offset" do
      type "number"
      location "query"
    end
  end

  type "cbqos" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "limit" do
      type "number"
      location "query"
    end
    
    field "offset" do
      type "number"
      location "query"
    end
  end 

  type "devices" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "cidr" do
      type "string"
      location "query"
    end
    
    field "type_id" do
      type "number"
      location "query"
    end
  end

  type "dscps" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "description" do
      type "string"
      location "body"
      required true
    end
    
    field "id" do
      type "number"
      location "body"
      required true
    end
    
    field "name" do
      type "string"
      location "body"
      required true
    end
  end 

  type "hns" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"
  end

  type "host_group_types" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "config" do
      type "array"
      location "body"
    end
    
    field "description" do
      type "string"
      location "body"
      required true
    end
    
    field "favorite" do
      type "string"
      location "body"
      required true
    end
    
    field "name" do
      type "string"
      location "body"
      required true
    end
    
    field "limit" do
      type "number"
      location "query"
    end
    
    field "offset" do
      type "number"
      location "query"
    end
    
    field "sort" do
      type "string"
      location "query"
    end
    
    field "favorite" do
      type "string"
      location "query"
    end
    
    field "sortby" do
      type "string"
      location "query"
    end
    
    field "type" do
      type "string"
      location "query"
    end
  end

  type "interfaces" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "ipaddr" do
      type "string"
      location "query"
    end
    
    field "limit" do
      type "number"
      location "query"
    end
    
    field "offset" do
      type "number"
      location "query"
    end
    
    field "include_modified" do
      type "string"
      location "query"
    end
    
    field "report_id" do
      type "string"
      location "query"
      required true
    end
  end

  type "load_balancers" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "hostportlist" do
      type "array"
      location "body"
    end
    
    field "id" do
      type "number"
      location "body"
    end
    
    field "name" do
      type "string"
      location "body"
      required true
    end
    
    field "password" do
      type "string"
      location "body"
    end
    
    field "status" do
      type "object"
      location "body"
    end
    
    field "type" do
      type "string"
      location "body"
      required true
    end
    
    field "username" do
      type "string"
      location "body"
    end
    
    field "virtualservers" do
      type "array"
      location "body"
    end
    
    field "overwrite" do
      type "string"
      location "query"
    end
    
    field "limit" do
      type "number"
      location "query"
    end
    
    field "offset" do
      type "number"
      location "query"
    end
    
    field "sort" do
      type "string"
      location "query"
    end
    
    field "sortby" do
      type "string"
      location "query"
    end
    
    field "exact_name" do
      type "string"
      location "query"
    end
    
    field "vs_host" do
      type "string"
      location "query"
    end
    
    field "vs_name" do
      type "string"
      location "query"
    end
    
    field "vs_port" do
      type "number"
      location "query"
    end
    
    field "vs_protocol" do
      type "number"
      location "query"
    end
    
    field "lbid" do
      type "number"
      location "query"
    end
  end 

  type "ping" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"
  end 

  type "port_groups" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "definitions" do
      type "array"
      location "body"
      required true
    end
    
    field "id" do
      type "number"
      location "body"
    end
    
    field "name" do
      type "string"
      location "body"
      required true
    end
  end

  type "port_names" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "limit" do
      type "number"
      location "query"
    end
    
    field "name" do
      type "string"
      location "query"
    end
    
    field "offset" do
      type "number"
      location "query"
    end
  end

  type "protocols" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"
  end

  type "recipients" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"
  end

  type "reporting" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "criteria" do
      type "object"
      location "body"
    end
    
    field "name" do
      type "string"
      location "body"
    end
    
    field "template_id" do
      type "number"
      location "body"
      required true
    end
    
    field "timeout" do
      type "number"
      location "body"
    end
    
    field "description" do
      type "string"
      location "body"
    end
    
    field "disabled" do
      type "string"
      location "body"
    end
    
    field "id" do
      type "number"
      location "body"
    end
    
    field "img" do
      type "object"
      location "body"
    end
    
    field "last_added_section_id" do
      type "number"
      location "body"
    end
    
    field "last_added_widget_id" do
      type "number"
      location "body"
    end
    
    field "layout" do
      type "array"
      location "body"
    end
    
    field "live" do
      type "string"
      location "body"
      required true
    end
    
    field "scheduled" do
      type "string"
      location "body"
    end
    
    field "sections" do
      type "array"
      location "body"
    end
    
    field "shared" do
      type "string"
      location "body"
    end
    
    field "sharing" do
      type "object"
      location "body"
    end
    
    field "timestamp" do
      type "string"
      location "body"
    end
    
    field "traffic_expression" do
      type "string"
      location "body"
    end
    
    field "user_id" do
      type "number"
      location "body"
    end
    
    field "version" do
      type "string"
      location "body"
    end
    
    field "wizard" do
      type "object"
      location "body"
    end
    
    field "attributes" do
      type "object"
      location "body"
    end
    
    field "config" do
      type "object"
      location "body"
      required true
    end
    
    field "title" do
      type "string"
      location "body"
      required true
    end
    
    field "user_attributes" do
      type "object"
      location "body"
    end
    
    field "widget_id" do
      type "number"
      location "body"
    end
    
    field "collapsible" do
      type "string"
      location "body"
    end
    
    field "colspan" do
      type "number"
      location "body"
    end
    
    field "display_host_group_type" do
      type "string"
      location "body"
    end
    
    field "edge_thickness" do
      type "string"
      location "body"
    end
    
    field "extend_to_zero" do
      type "string"
      location "body"
    end
    
    field "format_bytes" do
      type "string"
      location "body"
    end
    
    field "height" do
      type "number"
      location "body"
    end
    
    field "high_threshold" do
      type "string"
      location "body"
    end
    
    field "line_scale" do
      type "string"
      location "body"
    end
    
    field "line_style" do
      type "string"
      location "body"
    end
    
    field "low_threshold" do
      type "string"
      location "body"
    end
    
    field "modal_links" do
      type "number"
      location "body"
    end
    
    field "moveable_nodes" do
      type "string"
      location "body"
    end
    
    field "n_items" do
      type "number"
      location "body"
    end
    
    field "open_nodes" do
      type "array"
      location "body"
    end
    
    field "orientation" do
      type "string"
      location "body"
    end
    
    field "pan_zoomable" do
      type "string"
      location "body"
    end
    
    field "percent_of_total" do
      type "string"
      location "body"
    end
    
    field "show_images" do
      type "string"
      location "body"
    end
    
    field "width" do
      type "number"
      location "body"
    end
    
    field "name" do
      type "string"
      location "query"
    end
    
    field "template" do
      type "number"
      location "query"
      required true
    end
    
    field "dest_template" do
      type "number"
      location "query"
      required true
    end
    
    field "src_template" do
      type "number"
      location "query"
      required true
    end
    
    field "widget" do
      type "number"
      location "query"
      required true
    end
    
    field "duration" do
      type "number"
      location "query"
    end
    
    field "columns" do
      type "string"
      location "query"
    end
    
    field "limit" do
      type "number"
      location "query"
    end
    
    field "offset" do
      type "number"
      location "query"
    end
    
    field "area" do
      type "string"
      location "query"
    end
    
    field "category" do
      type "string"
      location "query"
    end
    
    field "centricity" do
      type "string"
      location "query"
    end
    
    field "direction" do
      type "string"
      location "query"
    end
    
    field "group_by" do
      type "string"
      location "query"
    end
    
    field "metric" do
      type "string"
      location "query"
    end
    
    field "rate" do
      type "string"
      location "query"
    end
    
    field "realm" do
      type "string"
      location "query"
    end
    
    field "role" do
      type "string"
      location "query"
    end
    
    field "severity" do
      type "string"
      location "query"
    end
    
    field "statistic" do
      type "string"
      location "query"
    end
    
    field "unit" do
      type "string"
      location "query"
    end
    
    field "access" do
      type "string"
      location "query"
    end
    
    field "filter" do
      type "string"
      location "query"
    end
    
    field "live" do
      type "string"
      location "query"
    end
  end

  type "services" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "alert_notification" do
      type "object"
      location "body"
      required true
    end
    
    field "components" do
      type "array"
      location "body"
      required true
    end
    
    field "description" do
      type "string"
      location "body"
      required true
    end
    
    field "id" do
      type "number"
      location "body"
    end
    
    field "locked_by_user_id" do
      type "number"
      location "body"
    end
    
    field "name" do
      type "string"
      location "body"
      required true
    end
    
    field "policies" do
      type "array"
      location "body"
      required true
    end
    
    field "segments" do
      type "array"
      location "body"
      required true
    end
    
    field "limit" do
      type "number"
      location "query"
    end
    
    field "offset" do
      type "number"
      location "query"
    end
    
    field "sort" do
      type "string"
      location "query"
    end
    
    field "sortby" do
      type "string"
      location "query"
    end
    
    field "height" do
      type "number"
      location "query"
    end
    
    field "width" do
      type "number"
      location "query"
    end
  end

  type "sharks" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"
  end

  type "steelheads" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "code" do
      type "string"
      location "body"
      required true
    end
  end

  type "system" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"
  end

  type "users" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "password" do
      type "string"
      location "body"
      required true
    end
    
    field "username" do
      type "string"
      location "body"
      required true
    end
    
    field "server" do
      type "string"
      location "query"
      required true
    end
    
    field "password" do
      type "string"
      location "query"
      required true
    end
    
    field "username" do
      type "string"
      location "query"
      required true
    end
  end

  type "user_defined_policies" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "alert_notification" do
      type "object"
      location "body"
      required true
    end
    
    field "deleted" do
      type "string"
      location "body"
    end
    
    field "description" do
      type "string"
      location "body"
      required true
    end
    
    field "enabled" do
      type "string"
      location "body"
      required true
    end
    
    field "filters" do
      type "object"
      location "body"
      required true
    end
    
    field "id" do
      type "number"
      location "body"
    end
    
    field "name" do
      type "string"
      location "body"
      required true
    end
    
    field "revision_id" do
      type "number"
      location "body"
    end
    
    field "schedule" do
      type "object"
      location "body"
      required true
    end
    
    field "threshold" do
      type "object"
      location "body"
      required true
    end
    
    field "type" do
      type "string"
      location "body"
      required true
    end
    
    field "limit" do
      type "number"
      location "query"
    end
    
    field "name" do
      type "string"
      location "query"
    end
    
    field "offset" do
      type "number"
      location "query"
    end
    
    field "sort" do
      type "string"
      location "query"
    end
    
    field "sortby" do
      type "string"
      location "query"
    end
    
    field "id" do
      type "string"
      location "query"
    end
  end

  type "vnis" do
    href_templates ""
    provision "provision_resource"
    delete "delete_resource"

    field "description" do
      type "string"
      location "body"
    end
    
    field "id" do
      type "number"
      location "body"
      required true
    end
    
    field "name" do
      type "string"
      location "body"
    end
  end
end

resource_pool "rs_riverbed_netprofiler" do
  plugin $rs_riverbed_netprofiler
  auth "netprofiler", type: "basic" do
    username cred('NETPROFILER_USERNAME')
    password cred('NETPROFILER_PASSWORD')
  end
  parameter_values do
    tunnel_token "WSTUNNEL_TOKEN" # REPLACE with the wsTunnel token BEFORE uploading
  end
end