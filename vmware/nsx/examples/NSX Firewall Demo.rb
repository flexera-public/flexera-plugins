name 'NSX Firewall Demo'
short_description "![Gist](http://blogs.vmware.com/kb/files/2015/08/NSX.png =128x66) \n
NSX Firewall Demo."
long_description "![Gist](http://blogs.vmware.com/kb/files/2015/08/NSX.png =128x66) \n
This demo launches 2 instances and applies firewall rules such that WEB1 can only access WEB2 over a single port."

type 'application'

rs_ca_ver 20161221

import 'sys_log'
import 'plugins/nsx'

###
# User Inputs
###
parameter 'stack_name' do
  label 'Name'
  description 'The name of the stack. Will prepend to resources.'
  category 'NSX FW Demo'
  type 'string'
  min_length 2
  default "fw-demo"
end

resource 'stack_security_tag', type: 'nsx.security_tag' do
  # Tag to be applied to web1 dynamically associates it with web1_security_group
  name join([$stack_name,"-","stack-st"])
  description join(["stack_secuirty_tag for ",$stack_name,"."])
end

resource 'stack_security_group', type: 'nsx.security_group' do
  # Security Group composed of web1_security_tag instances used in firewall rules
  name join([$stack_name,"-","stack-sg"])
  description join(["stack_secuirty_group for ",$stack_name,"."])
  dynamicMemberDefinition do {
'dynamicSet' => {
'operator' => 'OR',
'dynamicCriteria' => {
  'operator' => 'OR',
  'key' => 'ENTITY',
  'criteria' => 'belongs_to',
  'value' => @stack_security_tag.objectId
}
}
  }end
end

resource 'client_security_tag', type: 'nsx.security_tag' do
  # Tag to be applied to web1 dynamically associates it with web1_security_group
  name join([$stack_name,"-","client-st"])
  description join(["client_secuirty_tag for ",$stack_name,"."])
end

resource 'client_security_group', type: 'nsx.security_group' do
  # Security Group composed of web1_security_tag instances used in firewall rules
  name join([$stack_name,"-","client-sg"])
  description join(["client_secuirty_group for ",$stack_name,"."])
  dynamicMemberDefinition do {
'dynamicSet' => {
'operator' => 'OR',
'dynamicCriteria' => {
  'operator' => 'OR',
  'key' => 'ENTITY',
  'criteria' => 'belongs_to',
  'value' => @client_security_tag.objectId
}
}
  }end
end

resource 'server_security_tag', type: 'nsx.security_tag' do
  # Tag to be applied to web2 dynamically associates it with web2_security_group
  name join([$stack_name,"-","server-st"])
  description join(["server_secuirty_tag for ",$stack_name,"."])
end

resource 'server_security_group', type: 'nsx.security_group' do
  # Security Group composed of web1_security_tag instances used in firewall rules
  name join([$stack_name,"-","server-sg"])
  description join(["server_secuirty_group for ",$stack_name,"."])
  dynamicMemberDefinition do {
'dynamicSet' => {
'operator' => 'OR',
'dynamicCriteria' => {
  'operator' => 'OR',
  'key' => 'ENTITY',
  'criteria' => 'belongs_to',
  'value' => @server_security_tag.objectId
}
}
  }end
end

resource 'fw_demo_fw_l3section_deny', type: 'nsx.firewall_layer3section' do
  # Add a layer3 section to the firewall to contain all the rules for the firewall demo
  section do {
    '-name' => join([$stack_name,"-","fw-l3section-deny"])
  } end
end

resource 'fw_demo_fw_l3section_allow', type: 'nsx.firewall_layer3section' do
  # Add a layer3 section to the firewall to contain all the rules for the firewall demo
  section do {
    '-name' => join([$stack_name,"-","fw-l3section-allow"])
  } end
end

resource 'demo_app', type: 'nsx.application' do
  # Create an application which listens on tcp:8080
  name join([$stack_name,"-","demo-app"])
  description join(["application for ",$stack_name,"."])
  element do {
'applicationProtocol' => 'TCP',
'value' => '8080'
}end
end

# Rely on l3section delete to also delete the rules
# Plugin/API limitation prevents firewall rules from getting an href
# So can be created but not updated, retrieved or deleted.
resource 'default_inbound_deny', type: 'nsx.firewall_layer3rule' do
  # Deny all inbound traffic
  sectionId @fw_demo_fw_l3section_deny.objectId
  rule do {
'name' => join([$stack_name,"-","default-deny"]),
'action' => 'reject',
'appliedToList' => {
  'appliedTo' => {
    'name' => 'client',
    'value' => @stack_security_group.objectId,
    'type' => 'SecurityGroup',
    'isValid' => true
  }
},
  'sectionId' => @fw_demo_fw_l3section_deny.objectId,
  'direction' => 'in',
  'packetType' => 'any'
}end
  section_etag @fw_demo_fw_l3section_deny.ETag
end

resource 'client_to_server_app_allow', type: 'nsx.firewall_layer3rule' do
  # Allow inbound to demo_app
  sectionId @fw_demo_fw_l3section_allow.objectId
  rule do {
'name' => join([$stack_name,"-","client-to-server-app-allow"]),
'action' => 'allow',
'appliedToList' => {
  'appliedTo' => {
    'name' => @stack_security_group.name,
    'value' => @stack_security_group.objectId,
    'type' => 'SecurityGroup',
    'isValid' => true
  }
},
  'sectionId' => @fw_demo_fw_l3section_allow.objectId,
  'sources' => {
    '-excluded' => "false",
    'source' => {
      'name' => @client_security_group.name,
      'value' => @client_security_group.objectId,
      'type' => 'SecurityGroup',
      'isValid' => true
    }
  },
  'destinations' => {
    '-excluded' => 'false',
    'destination' => {
      'name' => @server_security_group.name,
      'value' => @server_security_group.objectId,
      'type' => 'SecurityGroup',
      'isValid' => true
    }
  },
  'services' => {
    'service' => {
      'name' => @demo_app.name,
      'value' => @demo_app.objectId,
      'type' => 'Application',
      'isValid' => true
    }
  },
  'direction' => 'inout',
  'packetType' => 'any'
}end
  section_etag @fw_demo_fw_l3section_allow.ETag
end

resource "server", type: "rs_cm.server" do
  name join([$stack_name,"-server"])
  cloud "CSXgen2LAB"
  datacenter "VMware_Zone_1"
  subnets "vxw-dvs-10-virtualwire-5-sid-5004-Rightscale (VMware_Zone_1)"
  instance_type "1 CPU, 4GB RAM"
  ssh_key "RS - NSX Development"
  server_template find("NSX - Firewall Demo (CSXgen2LAB)",{revision: "HEAD"})
  inputs do {
             "PORT1" => "text:8080",
             "PORT2" => "text:8081"
    }
  end
end

resource "client", type: "rs_cm.server" do
  name join([$stack_name,"-client"])
  cloud "CSXgen2LAB"
  datacenter "VMware_Zone_1"
  subnets "vxw-dvs-10-virtualwire-5-sid-5004-Rightscale (VMware_Zone_1)"
  instance_type "1 CPU, 4GB RAM"
  ssh_key "RS - NSX Development"
  server_template find("NSX - Firewall Demo (CSXgen2LAB)",{revision: "HEAD"})
  inputs do {
             "PORT1" => "text:8080",
             "PORT2" => "text:8081"
    }
  end
end

operation 'attach_vms_to_tag' do
  definition 'attach_vms'
end

operation 'detach_vms_from_tag' do
  definition 'detach_vms'
end

operation 'launch' do
  definition 'launch'
end

operation 'terminate' do
  definition 'terminate'
end

define launch(@server,@client) return @server,@client do
  concurrent return @server,@client do
    sub do
      provision(@server)
    end
    sub do
      provision(@client)
    end
  end
end

define terminate(@server,@client,@demo_app,@fw_demo_fw_l3section_allow,@fw_demo_fw_l3section_deny,@server_security_group,@server_security_tag,@client_security_group,@client_security_tag,@stack_security_group,@stack_security_tag) do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Terminate Begin")

  # Rely on l3section delete to also delete the rules
  # Plugin/API limitation prevents firewall rules from getting an href
  # So can be created but not updated, retrieved or deleted.
  delete(@fw_demo_fw_l3section_allow)
  delete(@fw_demo_fw_l3section_deny)

  concurrent return @server,@client do
    sub do
      delete(@server)
    end
    sub do
      delete(@client)
    end
  end

  delete(@server_security_tag)
  delete(@client_security_tag)
  delete(@stack_security_tag)
  delete(@server_security_group)
  delete(@client_security_group)
  delete(@stack_security_group)
  delete(@demo_app)
end

define attach_vms(@server,@client,@server_security_tag,@client_security_tag,@stack_security_tag) do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Attach VM's to tag")
  call start_debugging()
  @stack_security_tag.add_vm({'vmId' => @server.resource_uid})
  call stop_debugging()
  call start_debugging()
  @stack_security_tag.add_vm({'vmId' => @client.resource_uid})
  call stop_debugging()
  call start_debugging()
  @server_security_tag.add_vm({'vmId' => @server.resource_uid})
  call stop_debugging()
  call start_debugging()
  @client_security_tag.add_vm({'vmId' => @client.resource_uid})
  call stop_debugging()
end

define detach_vms(@server,@client,@server_security_tag,@client_security_tag,@stack_security_tag) do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Detach VM's to tag")
  call start_debugging()
  @stack_security_tag.rm_vm({'vmId' => @server.resource_uid})
  call stop_debugging()
  call start_debugging()
  @stack_security_tag.rm_vm({'vmId' => @client.resource_uid})
  call stop_debugging()
  call start_debugging()
  @server_security_tag.rm_vm({'vmId' => @server.resource_uid})
  call stop_debugging()
  call start_debugging()
  @client_security_tag.rm_vm({'vmId' => @client.resource_uid})
  call stop_debugging()
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
