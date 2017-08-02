name "rs_riverbed_steelhead_mgmt_newsfeeds"
type "plugin"
rs_ca_ver 20161221
short_description "Riverbed Steelhead Plugin"
long_description "Version: 1.0"
package "plugins/rs_riverbed_steelhead_mgmt_newsfeeds"
import "sys_log"

parameter "subscription_id" do
  type  "string"
  label "Subscription ID"
end

plugin "rs_riverbed_steelhead_mgmt_newsfeeds" do
  endpoint do
    default_host cred("STEELHEAD_HOST")
    default_scheme "https"
    headers do {
      "Content-Type": "application/json"
    } end
  end

  type "feeds" do
    href_templates "/api/mgmt.newsfeeds/1.0/feeds"
    provision "no_operation"
    delete "no_operation"

    action "show" do
      type "availability_set"
      path "/api/mgmt.newsfeeds/1.0/feeds"
      verb "GET"
    end
    outputs "items"
  end
  
  type "feed" do
    href_templates "/api/mgmt.newsfeeds/1.0/feeds/items/{name}"
    provision "no_operation"
    delete "no_operation"
    
    field "name" do
      type "string"
      location "path"
    end

    action "show" do
      type "mgmt_newsfeeds_feed"
      verb "GET"
      path "$href"
    end
    outputs "name", "categories"
  end

  type "summary" do
    href_templates "/api/mgmt.newsfeeds/1.0/feeds/items/{name}/items/{id}"
    provision "no_operation"
    delete "no_operation"

    field "name" do
      type "string"
      location "path"
    end

    field "id" do
      type "string"
      location "path"
    end

    action "show" do
      type "mgmt_newsfeeds_summary"
      verb "GET"
      path "$href"
    end

    outputs "id","summary"
  end

  type "news" do
    href_templates "/api/mgmt.newsfeeds/1.0/news"
    provision "no_operation"
    delete "no_operation"
    
    field "remote_user" do
      type "string"
      location "query"
    end

    field "severity" do
      type "string"
      location "query"
    end

    field "audit_id" do
      type "string"
      location "query"
    end

    field "feed_category" do
      type "string"
      location "query"
    end

    field "feed_name" do
      type "string"
      location "query"
    end

    field "source" do
      type "string"
      location "query"
    end

    field "feed_id" do
      type "string"
      location "query"
    end

    field "limit"  do
      type "string"
      location "query"
    end

    field "user" do
      type "string"
      location "query"
    end

    field "offset" do
      type "string"
      location "query"
    end

    field "start_time" do
      type "string"
      location "query"
    end

    field "end_time" do
      type "string"
      location "query"
    end

    action "show" do
      type "mgmt_newsfeeds_news"
      verb "GET"
      path "$href"
    end

    action "create" do
      type "mgmt_newsfeeds_news_item"
      verb "POST"
      path "/api/mgmt.newsfeeds/1.0/news"
    end

    action "set" do
      type "mgmt_newsfeeds_news"
      verb "PUT"
      path "/api/mgmt.newsfeeds/1.0/news"
    end

    outputs "items"
  end

  type "news_item" do
    href_templates "/api/mgmt.newsfeeds/1.0/news/items/{id}"
    provision "provision_resource"
    delete "no_operation"

    field "remote_user" do
      type "string"
      location "query"
    end

    field "severity" do
      type "string"
      location "query"
    end

    field "audit_id" do
      type "string"
      location "query"
    end

    field "feed_category" do
      type "string"
      location "query"
    end

    field "feed_name" do
      type "string"
      location "query"
    end

    field "source" do
      type "string"
      location "query"
    end

    field "feed_id" do
      type "string"
      location "query"
    end

    field "limit"  do
      type "string"
      location "query"
    end

    field "user" do
      type "string"
      location "query"
    end

    field "offset" do
      type "string"
      location "query"
    end

    field "start_time" do
      type "string"
      location "query"
    end

    field "end_time" do
      type "string"
      location "query"
    end

    action "show" do
      type "mgmt_newsfeeds_news_item"
      verb "GET"
      path "/api/mgmt.newsfeeds/1.0/news/items/$id"

      field "id" do
        type "string"
        location "path"
      end
    end

    action "create" do
      type "mgmt_newsfeeds_news_item"
      verb "POST"
      path "/api/mgmt.newsfeeds/1.0/news"
    end

    outputs "id","timestamp","feed_name","feed_category","feed_id","user","remote_user","audit_id","source","severity","details","resources"
  end
end

resource_pool "rs_riverbed_steelhead" do
  plugin $rs_riverbed_steelhead_mgmt_newsfeeds
  auth "basic_auth", type: "basic" do
    username "admin"
    password "admin"
  end
end

define skip_known_error() do
  # If all errors were concurrent resource group errors, skip
  $_error_behavior = "skip"
  foreach $e in $_errors do
    call sys_log.detail($e)
    if $e["error_details"]["summary"] !~ /Concurrent process is creating resource group/
      $_error_behavior = "raise"
    end
  end
end

define stop_debugging_and_raise() do
  call stop_debugging()
  raise $_errors
end

define no_operation(@declaration) do
  $object = to_object(@declaration)
  call sys_log.detail("declaration:" + to_s($object))
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

define provision_resource(@declaration) return @resource do
  sub on_error: stop_debugging() do
    $object = to_object(@declaration)
    $fields = $object["fields"]
    call sys_log.detail(join(["fields", $fields]))
    $type = $object["type"]
    $name = $fields["name"]
    $resource_group = $fields["resource_group"]
    call sys_log.set_task_target(@@deployment)
    call sys_log.summary(join(["Provision ", $type]))
    call sys_log.detail($object)
    call start_debugging()
    @operation = rs_azure_compute.$type.create($fields)
    call sys_log.detail(to_object(@operation))
    @resource = @operation.show(resource_group: $resource_group, name: $name)
    call sys_log.detail(to_object(@resource))
    call stop_debugging()
  end
end

define delete_resource(@declaration) do
  call start_debugging()
  sub on_error: skip do
    @declaration.destroy()
  end
  call stop_debugging()
end