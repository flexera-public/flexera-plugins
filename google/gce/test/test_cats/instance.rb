name 'GCE Instance Test CAT'
rs_ca_ver 20161221
short_description "GCE Instance - Test CAT"
import "sys_log"
import "gce"

# authenticate with Google
credentials "auth_google" do
  schemes "oauth2"
  label "Google"
  description "Select the Google Cloud Credential from the list."
  tags "provider=gce"
end

parameter "gce_project" do
  like $gce.project
end

parameter "gce_region" do
  type "string"
  label "GCE Region"
  category "GCE"
end

parameter "gce_zone" do
  type "string"
  label "GCE Zone"
  category "GCE"
end

parameter "network_1" do
  type "string"
  label "GCE Network 1"
  category "GCE Network"
end

parameter "sub_network_1" do
  type "string"
  label "GCE Sub Network 1"
  category "GCE Network"
end


resource "gce_ip", type: "gce.address" do
  region $gce_region
  name join(["fw-ip", last(split(@@deployment.href, "/"))])
end

resource "instance", type: "gce.instance" do
  name join(["instance-", last(split(@@deployment.href, "/"))])
  zone $gce_zone
  description "Self Service Instance"
  minCpuPlatform "Automatic"
  machineType join(["projects/", $gce_project, "/zones/", $gce_zone, "/machineTypes/n1-standard-4"])
  tags do {
    "items" => [
     $firewall_tag
    ]
  } end
  canIpForward true
  networkInterfaces [
    {
      "network": join(["projects/", $gce_project,"/global/networks/", $network_1]),
      "subnetwork": join(["projects/", $gce_project,"/regions/", $gce_region,"/subnetworks/", $sub_network_1]),
      "name": "nic0",
      "accessConfigs": [
        {
          "type": "ONE_TO_ONE_NAT",
          "name": "external-nat",
          "natIP": @gce_ip.address
        }
      ]
    }
  ]
  disks [
    {
      "type": "PERSISTENT",
      "boot": true,
      "mode": "READ_WRITE",
      "autoDelete": true,
      "deviceName": join(["instance", last(split(@@deployment.href, "/"))]),
      "licenses": [
        "projects/centos-cloud/global/licenses/centos-stream"
       ],
      "interface": "SCSI",
      "initializeParams": {
        "sourceImage": join(["projects/", $gce_project, "/global/images/centos-stream-8-v20211214"]),
        "diskType": join(["projects/", $gce_project, "/zones/", $gce_zone, "/diskTypes/pd-balanced"]),
        "diskSizeGb": "80"
      }
    }
  ]
  serviceAccounts [
    {
     "email": $service_account,
     "scopes": [
      "https://www.googleapis.com/auth/cloud-platform"
     ]
    }
  ]
  scheduling do {
    "onHostMaintenance": "MIGRATE",
    "automaticRestart": true,
    "preemptible": false
  } end
  cpuPlatform "Intel Haswell"
  deletionProtection false
end

operation "launch" do
 description "Launch the application"
 definition "launch_handler"
 output_mappings do {
 } end
end

define launch_handler(@gce_ip,@instance) return @gce_ip,@instance do
  provision(@gce_ip)
  provision(@instance)
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
