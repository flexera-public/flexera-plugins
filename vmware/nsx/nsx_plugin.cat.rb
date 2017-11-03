name 'VMware NSX Plugin'
short_description 'A RightScale Self-Service plugin for VMware NSX.'
long_description 'Version 1.0'
rs_ca_ver 20161221
type 'plugin'
package 'plugins/nsx'

import 'sys_log'

# parameter "nsx_wstunnel" do
#   type "string"
#   label "wstunnel Endpoint"
#   category "NSX Plugin"
# end

plugin 'nsx' do
  endpoint do
    # Currently plugins do not support XML payloads, heroku currently hosts an application to convert json to xml payloads.
    # Source available here: https://github.com/flaccid/j2xrp
    default_host 'j2xrp.herokuapp.com'
    default_scheme 'https'

    # Insert your wstunnel token here
    # Currently it's hard coded
    path "/_token/<token>"

    # TODO: wait for parser fix
    # request_content_type 'application/xml'

    headers do {
      'User-Agent' => 'RightScale Self-Service/20161221'
    } end

    # unfortunately, very common to be using self-signed or
    # not a public CA
    no_cert_check true
  end
  
  # parameter "wstunnelId" do
  #   type "string"
  #   label "NSX wstunnel ID"
  #   description "The wstunnel ID for the NSX api"
  # end
  
  type 'security_group' do
    href_templates "api/2.0/services/securitygroup/{{/securitygroup/objectId}}","api/2.0/services/securitygroup/{{/list/securitygroup/objectId}}"
      
    field 'name' do
      type 'string'
      required 'true'
    end

    field 'description' do
      type 'string'
    end

    field 'scope' do
      type 'object'
    end

    field 'isUniversal' do
      type 'boolean'
    end

    field 'inheritanceAllowed' do
      type 'boolean'
    end

    field 'dynamicMemberDefinition' do
      type 'object'
    end

    output_path '/securitygroup'
    
    output 'objectId','objectTypeName','revision','description','name'

    provision 'provision_resource'
    delete 'delete_resource'

    action 'delete' do
      path '$href'
      verb 'DELETE'
    end

    action 'create' do
      path 'api/2.0/services/securitygroup/bulk/globalroot-0'
      verb 'POST'
      type 'security_group'
    end

    action 'list' do
      path 'api/2.0/services/securitygroup/scope/globalroot-0'
      verb 'GET'
      output_path '/list/securitygroup'
      type 'security_group'
    end

    action 'get' do
      path '$href'
      verb 'GET'
    end
  end

  
  type 'security_tag' do
    href_templates "api/2.0/services/securitytags/tag/{{/securityTag/objectId}}","api/2.0/services/securitytags/tag/{{/securityTags/securityTag/objectId}}"
    
    field 'name' do
      type 'string'
      required true
    end

    field 'description' do
      type 'string'
    end

    provision 'provision_resource'
    delete 'delete_resource'
    
    action 'create' do
      path 'api/2.0/services/securitytags/tag'
      verb 'POST'
      type 'security_tag'
    end
    
    action 'list' do
      path 'api/2.0/services/securitytags/tag'
      verb 'GET'
      output_path '/securityTags/securityTag'
    end

    action 'delete' do
      path '$href'
      verb 'DELETE'
    end

    action 'get' do
      path '$href'
      verb 'GET'
    end

    action 'add_vm' do
      path '$href/vm/$vmId'
      verb 'PUT'
      field 'vmId' do
        location 'path'
      end
    end

    action 'rm_vm' do
      path '$href/vm/$vmId'
      verb 'DELETE'
      field 'vmId' do
        location 'path'
      end
    end
    
    output_path "/securityTag"
    output 'objectId', 'objectTypeName', 'name', 'description'

    output 'type' do
      type 'object'
    end

    output 'extendedAttributes' do
      type 'object'
    end 
  end

  # Distributed Firewall
  # The distributed firewall is in the global scope and consists of a single firewall configuration.
  # Rules are applied in the order they appear in the configuration, the first rule that matches is appled.
  # Firewall contains Sections which contain Rules
  type 'firewall' do
    href_templates "api/4.0/firewall/{{/firewallConfiguration/contextId}}/config"

    output 'firewallConfiguration' do
      type 'object'
    end

    output 'ETag' do
      header_name 'ETag'
    end
 
    action 'get' do
      path 'api/4.0/firewall/globalroot-0/config'
    end

    # action 'update' do
    #   path '$href'
    #   field 'ETag' do
    #     type 'string'
    #     location 'header'
    #   end
    #   field 'firewallConfiguration' do
    #     type 'string'
    #     location 'body'
    #   end
    # end
    
    # action 'force_sync_cluster' do
    # end

    # action 'force_sync_host' do
    # end

    # action 'add_vm_exclude' do
    # end

    # action 'del_vm_exclude' do
    # end

    action 'create_layer2section' do
      path 'api/4.0/firewall/globalroot-0/config/layer2sections'
      verb 'POST'
      field 'section' do
        location 'body'
      end
      type 'firewall_layer2section'
    end
    
    action 'create_layer3section' do
      path 'api/4.0/firewall/globalroot-0/config/layer3sections'
      verb 'POST'
      field 'section' do
        location 'body'
      end
      type 'firewall_layer3section'
    end
  end
  
  # # Distributed Firewall Layer2 Section
  # type 'firewall_layer2section' do
  #   href_templates "api/4.0/firewall/globalroot-0/config/layer2sections/{{/section/@id}}"
    
  #   field "section" do
  #     type 'object'
  #     location 'body'
  #     required true
  #   end
    
  #   output 'ETag' do
  #     header_name 'ETag'      
  #   end

  #   output 'objectId' do
  #     body_path '/section/@id'
  #   end
    
  #   provision 'provision_resource'
  #   delete 'delete_resource'
    
  #   action 'create' do
  #     path 'api/4.0/firewall/globalroot-0/config/layer2sections'
  #     verb 'POST'
  #     field 'section' do
  #       location 'body'
  #     end
  #   end

  #   action 'delete' do
  #     path '$href'
  #     verb 'DELETE'
  #   end

  #   action 'update' do
  #     path '$href'
  #     field 'ETag' do
  #       location 'header'
  #     end
  #     field 'section' do
  #       location 'body'
  #     end
  #   end

  #   action 'list' do
  #     path 'api/4.0/firewall/globalroot-0/config'
  #     verb 'GET'
  #     output_path '/firewallConfiguration/layer2Sections'
  #     type 'firewall_layer2section'
  #   end
    
  #   action 'add_firewall_rule' do
  #     path '$href/rules'
  #     verb 'POST'
  #     field 'rule' do
  #       location 'body'
  #     end
  #   end

  #   action 'list_firewall_rules' do
  #     path '$href'
  #     output_path '/section/rule'
  #     type 'firewall_layer2rule'
  #   end
  # end

    # Distributed Firewall Layer3 Section
  type 'firewall_layer3section' do
    href_templates "api/4.0/firewall/globalroot-0/config/layer3sections/{{/section/@id}}"

    field "section" do
      type "object"
      location 'body'
      required true
    end
    
    output 'ETag' do
      header_name 'ETag'      
    end

    output 'objectId' do
      body_path '/section/@id'
    end
    
    provision 'provision_resource'
    delete 'delete_resource'

    action 'create' do
      path 'api/4.0/firewall/globalroot-0/config/layer3sections'
      verb 'POST'
      field 'section' do
        location 'body'
      end
    end

    action 'delete' do
      path '$href'
      verb 'DELETE'
    end

    action 'update' do
      path '$href'
      field 'ETag' do
        location 'header'
      end
      field 'section' do
        location 'body'
      end
    end

    action 'show' do
      verb 'GET'
      field 'sectionId' do
        location 'path'
      end
      path 'api/4.0/firewall/globalroot-0/config/layer3sections/$sectionId'
    end
    
    action 'list' do
      path 'api/4.0/firewall/globalroot-0/config'
      verb 'GET'
      output_path '/firewallConfiguration/layer3Sections'
      type 'firewall_layer3section'
    end
    
    action 'add_firewall_rule' do
      path '$href/rules'
      verb 'POST'
      field 'rule' do
        location 'body'
      end
      type 'firewall_layer3rule'
    end

    action 'list_firewall_rules' do
      path '$href'
      output_path '/section/rule'
      type 'firewall_layer3rule'
    end
  end

  # # Distributed Firewall Rule
  # type 'firewall_layer2rule' do
  #   href_templates "api/4.0/firewall/globalroot-0/config/layer2sections/{{/rule/sectionId}}/rules"

  #   field "rule" do
  #     type "object"
  #     location "body"
  #     required true
  #   end

  #   field "sectionId" do
  #     type "string"
  #     location "path"
  #     required true
  #   end

  #   field "section_etag" do
  #     type "string"
  #     location "header"
  #     required true
  #     alias_for "If-Match"
  #   end
    
  #   output_path "/rule"

  #   output "ETag" do
  #     header_name "ETag"
  #   end
    
  #   provision 'provision_resource'
  #   delete 'delete_resource'

  #   action "create" do
  #     field "sectionId" do
  #       location "path"
  #     end
  #     field "rule" do
  #       location "body"
  #     end
  #     field "section_etag" do
  #       location "header"
  #       alias_for "If-Match"
  #     end

  #     verb "POST"
  #     path "api/4.0/firewall/globalroot-0/config/layer2sections/$sectionId/rules"
  #   end

  #   action "delete" do
  #     verb "DELETE"
  #     path "$href"
  #   end

  #   action "update" do
  #     verb "POST"
  #     path "$href"
  #     field "ETag" do
  #       location "header"
  #     end
  #     field "rule" do
  #       location "body"
  #     end
  #   end

  #   action "get" do
  #     verb "GET"
  #     path "$href"
  #   end
  # end    

  # Distributed Firewall Rule
  type 'firewall_layer3rule' do
    href_templates "api/4.0/firewall/globalroot-0/config/layer3sections/{{/rule/sectionId}}/rules/{{/rule/@id}}"

    field "rule" do
      type "object"
      location "body"
      required true
    end

    field "sectionId" do
      type "string"
      location "path"
      required true
    end

    field "section_etag" do
      type "string"
      location "header"
      required true
      alias_for "If-Match"
    end
    
    output_path "/rule"

    output "ETag" do
      header_name "ETag"
    end

    output "objectId" do
      body_path "/rule/@id"
    end
    
    provision 'provision_resource'
    delete 'delete_resource'

    action "create" do
      field "sectionId" do
        location "path"
      end
      field "rule" do
        location "body"
      end
      field "section_etag" do
        location "header"
        alias_for "If-Match"
      end
      verb "POST"
      path "api/4.0/firewall/globalroot-0/config/layer3sections/$sectionId/rules"
    end

    action "delete" do
      verb "DELETE"
      path "$href"
    end

    action "update" do
      verb "POST"
      path "$href"
      field "ETag" do
        location "header"
      end
      field "rule" do
        location "body"
      end
    end

    action "get" do
      verb "GET"
      path "$href"
    end
  end

  type 'application' do
    href_templates "api/2.0/services/application/{{/application/objectId}}"

    field "name" do
      type "string"
      location "body"
      required true
    end
    
    field "element" do
      type "object"
      location "body"
      required true
    end

    field "description" do
      type "string"
      location "body"
    end

    field "revision" do
      type "string"
      location "body"
    end
    
    output_path "/application"

    output "objectId","description","name","revision"

    output "element" do
      type "object"
    end
    
    provision 'provision_resource'
    delete 'delete_resource'

    action "create" do
      verb "POST"
      path "api/2.0/services/application/globalroot-0"
    end

    action "delete" do
      verb "DELETE"
      path "$href"
    end

    action "update" do
      verb "POST"
      path "$href"
    end

    action "get" do
      verb "GET"
      path "$href"
    end

    action "list" do
      verb "GET"
      path "api/2.0/services/application/scope/globalroot-0"
      output_path "/list/application"
    end
  end    

end

###
# Resource Pool(s)
###
resource_pool 'nsx' do
  plugin $nsx

  host "j2xrp.herokuapp.com"
  
  # parameter_values do
  #   wstunnelId $nsx_wstunnel
  # end

  auth 'nsx_auth', type: 'basic' do
    username cred('NSX_USER')
    password cred('NSX_PASSWORD')
  end
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

###
# Provisioning Definitions
###
define provision_resource(@declaration) return @resource on_error: stop_debugging() do

  $definition = to_object(@declaration)
  $ss_fields = $definition['fields']
  $ss_type = $definition['type']
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary(join(["Provision ",$ss_type]))
  call sys_log.detail(join(["Definition: ",$definition]))
  call sys_log.detail(join(["Type ",$ss_type]))

  call generate_resource_fields($ss_type,$ss_fields) retrieve $nsx_fields
  
  call sys_log.detail(join(["Resource Fields:", $nsx_fields]))

  call sys_log.detail("Provision Resource:")

  if $ss_type == 'firewall_layer3rule'
    # Make sure I have an etag
    if to_s($nsx_fields['section_etag']) == ""
      $section_id = $nsx_fields['sectionId']
      call start_debugging()
      @section = nsx.firewall_layer3section.show({sectionId: $section_id})
      call stop_debugging()
      call sys_log.detail(join(["Section: ",to_object(@section)]))
      sub timeout: 2m, on_timeout: skip do
        while @section.ETag == "" do
          sleep(10)
          call start_debugging()
          @section = @section.get()
          call stop_debugging()
          call sys_log.detail(join(["Section: ",to_object(@section)]))
        end
      end
      
      call start_debugging()
      $nsx_fields['section_etag'] = @section.ETag
      call stop_debugging()
    end
    
    call sys_log.detail(join(["Updated Resource Fields:", $nsx_fields]))
  end
  
  call start_debugging()
  @resource = nsx.$ss_type.create($nsx_fields)
  call stop_debugging()
  
  call sys_log.detail(join(["Resource Before Fix:",to_object(@resource)]))
  
  call nsx_fix_href(@resource) retrieve @fixed_resource
  @resource = @fixed_resource

  call sys_log.detail(join(["Resource After Fix:",to_object(@resource)]))
  call start_debugging()
  @resource = @resource.get()
  call stop_debugging()
  call sys_log.detail(join(["Resource After GET:",to_object(@resource)]))
end

define delete_resource(@resource) do
  call sys_log.set_task_target(@@deployment)
  $resource = to_object(@resource)
  $type = $resource["type"]
  call sys_log.summary(join(["Delete Resource ",$type]))
  if !empty?(@resource)
    call sys_log.detail("Resource Exists")
    sub on_error: skip_not_found_error() do
      call start_debugging()
      @resource.destroy()
      call stop_debugging()
    end
  else
    call sys_log.detail("Resource Does Not Exist")
  end
end

define skip_not_found_error() do
  call stop_debugging()
  if $_error["message"] =~ "/could not be found/i"
    call sys_log.detail($_error["type"] + ": " + $_error["message"])
    $_error_behavior = "skip"
  end
end


define generate_resource_fields($ss_type,$ss_fields) return $nsx_fields do
  $nsx_fields = {}
  call sys_log.detail($ss_type)
  if $ss_type == "security_group"
    call generate_security_group_fields($ss_fields) retrieve $fields
    $nsx_fields = $fields
  elsif $ss_type == "security_tag"
    call generate_security_tag_fields($ss_fields) retrieve $fields
    $nsx_fields = $fields
  elsif $ss_type == "application"
    call generate_application_fields($ss_fields) retrieve $fields
    $nsx_fields = $fields
  end
  
  if $nsx_fields == {}
    $nsx_fields = $ss_fields
  end

  call sys_log.detail("generate_resource_fields")
  call sys_log.detail($nsx_fields)
end

define generate_security_group_fields($ss_fields) return $nsx_fields do
  # set the default fields needed for creation
  $ss_fields['objectTypeName'] = 'SecurityGroup'
  $ss_fields['type'] = {}
  $ss_fields['type']['typeName'] = 'SecurityGroup'
  $ss_fields['scope'] = {}
  $ss_fields['scope']['id'] = 'globalroot-0'
  $ss_fields['scope']['objectTypeName'] = 'GlobalRoot'
  $ss_fields['scope']['name'] = 'Global'
  call create_xml_parent_node("securitygroup",$ss_fields) retrieve $nsx_fields
  call sys_log.detail("generate_security_group_fields")
  call sys_log.detail($nsx_fields)
end

define generate_security_tag_fields($ss_fields) return $nsx_fields do
  # set the default fields needed for creation
  $ss_fields['objectTypeName'] = 'SecurityTag'
  $ss_fields['type'] = {}
  $ss_fields['type']['typeName'] = 'SecurityTag'
  call create_xml_parent_node("securityTag",$ss_fields) retrieve $nsx_fields
end

define generate_application_fields($ss_fields) return $nsx_fields do
  # set the default fields needed for creation
  $ss_fields['objectTypeName'] = 'Application'
  $ss_fields['type'] = {}
  $ss_fields['type']['typeName'] = 'Application'
  $ss_fields['scope'] = {}
  $ss_fields['scope']['id'] = 'globalroot-0'
  $ss_fields['scope']['objectTypeName'] = 'GlobalRoot'
  $ss_fields['scope']['name'] = 'Global'
  call create_xml_parent_node("application",$ss_fields) retrieve $nsx_fields
end

define create_xml_parent_node($parent,$fields) return $fields_with_parent do
  # wrap the fields in a securitygroup element
  call sys_log.detail("create_xml_parent_node")
  call sys_log.detail($fields)
  $fields_with_parent = {}
  $fields_with_parent[$parent] = $fields
end

define generate_resource_href($objectId,$originalHref) return $href do
  $href = $originalHref
  if $ss_type == "security_group"
    $href = join(["api/2.0/services/securitygroup/",$objectId])
  elsif $ss_type == "security_tag"
    $href = join(["/api/2.0/services/securitytags/tag/",$objectId])
  elsif $ss_type == "firewall_layer2section"
    $href = join(["/api/4.0/firewall/globalroot-0/config/layer2sections/",$objectId])
  elsif $ss_type == "firewall_layer3section"
    $href = join(["/api/4.0/firewall/globalroot-0/config/layer3sections/",$objectId])
  # elsif $ss_type == "firewall_layer2rule"
  #   $href = join(["/api/4.0/firewall/globalroot-0/config/layer2sections/??/rules/",$objectId])
  # elsif $ss_type == "firewall_layer3rule"
    #   $href = join(["/api/4.0/firewall/globalroot-0/config/layer3sections/??/rules/",$objectId])
  end
end

define nsx_fix_href(@resource) return @fixed_resource do
  $resource = to_object(@resource)
  $hrefs = $resource["hrefs"]
  if size($hrefs) == 1
    $href = $hrefs[0]
    $href_parts = split($href, "/")
    $id = last($href_parts)
    call generate_resource_href($id,$href) retrieve $fixed_href
    $resource["hrefs"] = [$fixed_href]
  end
  @fixed_resource = $resource
  call sys_log.detail(to_object(@fixed_resource))
end
