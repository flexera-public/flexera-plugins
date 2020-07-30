name "Google Cloud Storage"
type "plugin"
rs_ca_ver 20161221
short_description "Google cloud storage bucket details"
long_description ""
info(
      provider: "Google",
      service: "Storage"
    )

pagination "gce_pagination" do
  get_page_marker do
    body_path "nextPageToken"
  end
  set_page_marker do
    query "pageToken"
  end
end

plugin "google_cloud_storage" do

  short_description "GCE Cloud storage"
  long_description "Supports polling activity for google cloud storage bucket with support for pagination"
  version "v2.0.0"
  json_query_language 'jq'
  
  documentation_link "source" do
    label "Source"
    url "https://github.com/flexera/flexera-plugins/blob/master/google/google_cloud_storage/google_cloud_storage.rb"
  end

  documentation_link "readme" do
    label "ReadMe"
    url "https://github.com/flexera/flexera-plugins/blob/master/google/google_cloud_storage/README.md"
  end

  parameter "project_id" do
    type "string"
    label "Project Id"
    description "Project identifier for which storage bucket details are fetched"
  end

  endpoint do
    default_host "storage.googleapis.com"
    default_scheme "https"
    path "/"
  end

  type "storage_buckets" do
    href_templates "{{.items[].id}}"

    output_path ".items[]"
    output "id" do
      body_path ".id"
    end

    output "name" do
      body_path ".name"
    end

    output "region" do
      body_path ".location"
    end

    output "storage_class" do
      body_path ".storageClass"
    end

    output "labels" do
      body_path ".labels"
    end

    output "updated" do
      body_path ".updated"
    end

    action "list" do
      verb "GET"
      path "storage/v1/b"
      field "projectId" do
        type "string"
        location "query"
        alias_for "project"
      end
    end

    polling do
      field_values do
        projectId $project_id
      end
      period 60
      action "list"
    end

    link "bucket_permission" do
      path "/bucket/{{id}}"
      type "bucket_permission"
    end

    link "bucket_size" do
      path "/bucket/{{id}}"
      type "bucket_size"
    end
  end
  
  type "bucket_permission" do
    href_templates "{{.resourceId | .[19:]}}"

    output "public_access" do
      body_path '[.bindings[].members[] | select(. == "allUsers" or . =="allAuthenticatedUsers")] | length>0'
    end

    action "list" do
      verb "GET"
      path "storage/v1/b/$bucket_name/iam"
      field 'bucket_name' do
        type 'string'
        location 'path'
      end
    end

    polling do
      field_values do
        bucket_name parent_field("id")
      end
      parent "storage_buckets"
      period 60
      action "list"
    end
  end
  
  type "bucket_size" do
    href_templates '{{[.items[].bucket] | first}}'

    output "size" do
      body_path '[.items[].size | tonumber ] | add | tostring | .+ " bytes"'
    end

    action "list" do
      verb "GET"
      path "storage/v1/b/$bucket_name/o"
      field "bucket_name" do
        type "string"
        location "path"
      end
    end

    polling do
      field_values do
        bucket_name parent_field("id")
      end
      parent "storage_buckets"
      period 60
      action "list"
    end
  end
end
