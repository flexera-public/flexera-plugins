# Copyright (c) 2017 RightScale-Engineering

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# RightScale Cloud Application Template (CAT)

# DESCRIPTION
# Example Application CAT for creating an Internal HTTP Load Balancer.
# This CAT was developed using the documentation below.
# https://cloud.google.com/compute/docs/load-balancing/internal

name "Google Internal TCP LB Implementation"
rs_ca_ver 20161221
short_description "Example Google Internal TCP LB Implementation"
long_description "Example Application CAT for creating an Internal TCP LoadBalancer\n
See the [README](README.md) for details about this CAT.\n
[GCE Internal Loadbalancer Docs](https://cloud.google.com/compute/docs/load-balancing/internal)"
type 'application'

import "sys_log"
import "plugins/gce"

parameter "gce_project" do
  like $gce.gce_project
end

# gcloud compute networks create my-custom-network --mode custom
resource "my_custom_network", type: "gce.network" do
  name join(["my-custom-network-",last(split(@@deployment.name,'-'))])
  autoCreateSubnetworks false
end

# gcloud compute networks subnets create my-custom-subnet \
#    --network my-custom-network \
#    --range 10.128.0.0/20 \
#    --region us-central1
resource "my_custom_subnet", type: "gce.subnetwork" do
  name join(["my-custom-subnet-",last(split(@@deployment.name,'-'))])
  region "us-central1"
  network @my_custom_network
  ipCidrRange "10.128.0.0/20"
end

# gcloud compute firewall-rules create allow-all-10-128-0-0-20 \
#     --network my-custom-network \
#     --allow tcp,udp,icmp \
#     --source-ranges 10.128.0.0/20
resource "allow_all_10_128_0_0_20", type: "gce.firewall" do
  name join(["allow-all-10-128-0-0-20-",last(split(@@deployment.name,'-'))])
  network @my_custom_network
  allowed do [
    {"IPProtocol": "tcp"},
    {"IPProtocol": "udp"},
    {"IPProtocol": "icmp"}
  ]end
  sourceRanges do [
    "10.128.0.0/20"
  ]end
end

# gcloud compute firewall-rules create allow-tcp22-tcp3389-icmp \
#     --network my-custom-network \
#     --allow tcp:22,tcp:3389,icmp
resource "allow_tcp22_tcp3389_icmp", type: "gce.firewall" do
  name join(["allow-tcp22-tcp3389-icmp-",last(split(@@deployment.name,'-'))])
  network @my_custom_network
  allowed do [
    {"IPProtocol": "tcp",
     "ports": ["22","3389"]},
    {"IPProtocol": "icmp"}    
  ]end
end

# gcloud compute instances create ig-us-central1-1 \
#     --image-family debian-8 \
#     --image-project debian-cloud \
#     --tags int-lb \
#     --zone us-central1-b \
#     --subnet my-custom-subnet \
#     --metadata startup-script="#! /bin/bash
#       apt-get update
#       apt-get install apache2 -y
#       a2ensite default-ssl
#       a2enmod ssl
#       service apache2 restart
#       echo '<!doctype html><html><body><h1>ig-us-central1-1</h1></body></html>' | tee /var/www/html/index.html
#       EOF"
resource "ig_us_central1_1", type: "gce.instance" do
  name join(["ig-us-central1-1","-",last(split(@@deployment.name,'-'))])
  zone "us-central1-b"
  # Using f1-micro due to resource availabillity in this zone
  machineType "zones/us-central1-b/machineTypes/f1-micro"
  tags do {
    "items": ["int-lb"]
  }end
  disks do [
    {"boot": true,
      "initializeParams": {
                           "sourceImage": "projects/debian-cloud/global/images/family/debian-8"
                         }
    }
  ]end
  networkInterfaces do [
    {
      "accessConfigs": [
                         {
                           "name": "external-nat"
                         }
                       ],
     "subnetwork": @my_custom_subnet
    }
  ]end
  metadata do {
"items": [
           {
             "key": "startup-script",
            "value": join(["#! /bin/bash","\n","apt-get update","\n","apt-get install apache2 -y","\n","a2ensite default-ssl","\n","a2enmod ssl","\n","service apache2 restart","\n","echo '<!doctype html><html><body><h1>","ig-us-central1-1","-",last(split(@@deployment.name,'-')),"</h1></body></html>' | tee /var/www/html/index.html","\n","EOF"])
           }
         ]
  }end
end

# gcloud compute instances create ig-us-central1-2 \
#     --image-family debian-8 \
#     --image-project debian-cloud \
#     --tags int-lb \
#     --zone us-central1-b \
#     --subnet my-custom-subnet \
#     --metadata startup-script="#! /bin/bash
#       apt-get update
#       apt-get install apache2 -y
#       a2ensite default-ssl
#       a2enmod ssl
#       service apache2 restart
#       echo '<!doctype html><html><body><h1>ig-us-central1-2</h1></body></html>' | tee /var/www/html/index.html
#       EOF"
resource "ig_us_central1_2", type: "gce.instance" do
  name join(["ig-us-central1-2","-",last(split(@@deployment.name,'-'))])
  zone "us-central1-b"
  # Using f1-micro due to resource availabillity in this zone
  machineType "zones/us-central1-b/machineTypes/f1-micro"
  tags do {
    "items": ["int-lb"]
  }end
  disks do [
    {"boot": true,
      "initializeParams": {
                           "sourceImage": "projects/debian-cloud/global/images/family/debian-8"
                         }
    }
  ]end
  networkInterfaces do [
    {
      "accessConfigs": [
                         {
                           "name": "external-nat"
                         }
                       ],
      "subnetwork": @my_custom_subnet
    }
  ]end
  metadata do {
"items": [
           {
             "key": "startup-script",
            "value": join(["#! /bin/bash","\n","apt-get update","\n","apt-get install apache2 -y","\n","a2ensite default-ssl","\n","a2enmod ssl","\n","service apache2 restart","\n","echo '<!doctype html><html><body><h1>","ig-us-central1-2","-",last(split(@@deployment.name,'-')),"</h1></body></html>' | tee /var/www/html/index.html","\n","EOF"])
           }
         ]
  }end
end

# gcloud compute instances create ig-us-central1-3 \
#     --image-family debian-8 \
#     --image-project debian-cloud \
#     --tags int-lb \
#     --zone us-central1-c \
#     --subnet my-custom-subnet \
#     --metadata startup-script="#! /bin/bash
#       apt-get update
#       apt-get install apache2 -y
#       a2ensite default-ssl
#       a2enmod ssl
#       service apache2 restart
#       echo '<!doctype html><html><body><h1>ig-us-central1-3</h1></body></html>' | tee /var/www/html/index.html
#       EOF"
resource "ig_us_central1_3", type: "gce.instance" do
  name join(["ig-us-central1-3","-",last(split(@@deployment.name,'-'))])
  zone "us-central1-c"
  # Using f1-micro due to resource availabillity in this zone
  machineType "zones/us-central1-c/machineTypes/f1-micro"
  tags do {
    "items": ["int-lb"]
  }end
  disks do [
    {"boot": true,
      "initializeParams": {
                           "sourceImage": "projects/debian-cloud/global/images/family/debian-8"
                         }
    }
  ]end
  networkInterfaces do [
    {
      "accessConfigs": [
                         {
                           "name": "external-nat"
                         }
                       ],
     "subnetwork": @my_custom_subnet
    }
  ]end
  metadata do {
"items": [
           {
             "key": "startup-script",
            "value": join(["#! /bin/bash","\n","apt-get update","\n","apt-get install apache2 -y","\n","a2ensite default-ssl","\n","a2enmod ssl","\n","service apache2 restart","\n","echo '<!doctype html><html><body><h1>","ig-us-central1-3","-",last(split(@@deployment.name,'-')),"</h1></body></html>' | tee /var/www/html/index.html","\n","EOF"])
           }
         ]
  }end
end

# gcloud compute instances create ig-us-central1-4 \
#     --image-family debian-8 \
#     --image-project debian-cloud \
#     --tags int-lb \
#     --zone us-central1-c \
#     --subnet my-custom-subnet \
#     --metadata startup-script="#! /bin/bash
#       apt-get update
#       apt-get install apache2 -y
#       a2ensite default-ssl
#       a2enmod ssl
#       service apache2 restart
#       echo '<!doctype html><html><body><h1>ig-us-central1-4</h1></body></html>' | tee /var/www/html/index.html
#       EOF"
resource "ig_us_central1_4", type: "gce.instance" do
  name join(["ig-us-central1-4","-",last(split(@@deployment.name,'-'))])
  zone "us-central1-c"
  # Using f1-micro due to resource availabillity in this zone
  machineType "zones/us-central1-c/machineTypes/f1-micro"
  tags do {
    "items": ["int-lb"]
  }end
  disks do [
    {"boot": true,
      "initializeParams": {
                           "sourceImage": "projects/debian-cloud/global/images/family/debian-8"
                         }
    }
  ]end
  networkInterfaces do [
    {
      "accessConfigs": [
                         {
                           "name": "external-nat"
                         }
                       ],
      "subnetwork": @my_custom_subnet
    }
  ]end
  metadata do {
"items": [
           {
             "key": "startup-script",
            "value": join(["#! /bin/bash","\n","apt-get update","\n","apt-get install apache2 -y","\n","a2ensite default-ssl","\n","a2enmod ssl","\n","service apache2 restart","\n","echo '<!doctype html><html><body><h1>","ig-us-central1-4","-",last(split(@@deployment.name,'-')),"</h1></body></html>' | tee /var/www/html/index.html","\n","EOF"])
           }
         ]
  }end
end


# gcloud compute instance-groups unmanaged create us-ig1 \
#     --zone us-central1-b
resource 'us_ig1', type: "gce.instanceGroup" do
  name join(["us-ig1","-",last(split(@@deployment.name,'-'))])
  zone "us-central1-b"
end

# gcloud compute instance-groups unmanaged create us-ig2 \
#     --zone us-central1-c
resource 'us_ig2', type: "gce.instanceGroup" do
  name join(["us-ig2","-",last(split(@@deployment.name,'-'))])
  zone "us-central1-c"
end

# gcloud compute health-checks create tcp my-tcp-health-check \
#     --port 80
resource 'my_tcp_health_check', type: "gce.healthCheck" do
  name join(["my-tcp-health-check","-",last(split(@@deployment.name,'-'))])
  tcpHealthCheck do {"port": 80 } end
  type "TCP"
end

# gcloud compute backend-services create my-int-lb \
#     --load-balancing-scheme internal \
#     --region us-central1 \
#     --health-checks my-tcp-health-check \
#     --protocol tcp
resource 'my_int_lb', type: "gce.regionBackendService" do
  name join(["my-int-lb","-",last(split(@@deployment.name,'-'))])
  loadBalancingScheme "internal"
  region "us-central1"
  healthChecks [@my_tcp_health_check]
  protocol "tcp"
end

# gcloud compute forwarding-rules create my-int-lb-forwarding-rule \
#     --load-balancing-scheme internal \
#     --ports 80 \
#     --network my-custom-network \
#     --subnet my-custom-subnet \
#     --region us-central1 \
#     --backend-service my-int-lb
resource 'my_int_lb_forwarding_rule', type: "gce.forwardingRule" do
  name join(["my-int-lb-forwarding-rule","-",last(split(@@deployment.name,'-'))])
  region "us-central1"
  loadBalancingScheme "internal"
  network @my_custom_network
  subnetwork @my_custom_subnet
  ports ["80"]
  backendService @my_int_lb
end


# gcloud compute firewall-rules create allow-internal-lb \
#     --network my-custom-network \
#     --source-ranges 10.128.0.0/20 \
#     --target-tags int-lb \
#     --allow tcp:80,tcp:443
resource 'allow_internal_lb', type: "gce.firewall" do
  name join(["allow-internal-lb-",last(split(@@deployment.name,'-'))])
  network @my_custom_network
  allowed do [
    {"IPProtocol": "tcp",
     "ports": ["80","443"]}
  ]end
  sourceRanges do [
    "10.128.0.0/20"
  ]end
  targetTags ["int-lb"]
end 

# gcloud compute firewall-rules create allow-health-check \
#     --network my-custom-network \
#     --source-ranges 130.211.0.0/22,35.191.0.0/16 \
#     --target-tags int-lb \
#     --allow tcp
resource 'allow_health_check', type: "gce.firewall" do
  name join(["allow-health-check-",last(split(@@deployment.name,'-'))])
  network @my_custom_network
  allowed do [
    {"IPProtocol": "tcp"}
  ]end
  sourceRanges ["130.211.0.0/22","35.191.0.0/16"]
  targetTags ["int-lb"]
end

# gcloud compute instances create standalone-instance-1 \
#     --image-family debian-8 \
#     --image-project debian-cloud \
#     --zone us-central1-b \
#     --tags standalone \
#     --subnet my-custom-subnet
resource "standalone_instance_1", type: "gce.instance" do
  name join(["standalone-instance-1","-",last(split(@@deployment.name,'-'))])
  zone "us-central1-b"
  # Using f1-micro due to resource availabillity in this zone
  machineType "zones/us-central1-b/machineTypes/f1-micro"
  tags do {
    "items": ["standalone"]
  }end
  disks do [
    {"boot": true,
      "initializeParams": {
                           "sourceImage": "projects/debian-cloud/global/images/family/debian-8"
                         }
    }
  ]end
  networkInterfaces do [
    {
      "accessConfigs": [
                         {
                           "name": "external-nat"
                         }
                       ],
     "subnetwork": @my_custom_subnet
    }
  ]end
end

# gcloud compute firewall-rules create allow-ssh-to-standalone \
#     --network my-custom-network \
#     --target-tags standalone \
#     --allow tcp:22
resource 'allow_ssh_to_standalone', type: "gce.firewall" do
  name join(["allow-ssh-to-standalone-",last(split(@@deployment.name,'-'))])
  network @my_custom_network
  allowed do [
    {"IPProtocol": "tcp",
    "ports": ["22"]}
  ]end
  targetTags ["standalone"]
end

# This operation overrides the default launch behavior allowing for a custom launch order
# This is required because in this example, some actions must be run prior to creation
# of other resources. (e.g. Adding instances to instance groups)
operation "launch" do
  definition "launch"
end

# This operation overrides the default terminate behavior allowing for custom terminate order
# This is required because not all dependancies are captured in the resource declaration and
# care must be given to the order everything is deleted.
operation "terminate" do
  definition "terminate"
end

define launch(@my_custom_network,@my_custom_subnet,@allow_all_10_128_0_0_20,@allow_tcp22_tcp3389_icmp,@ig_us_central1_1,@ig_us_central1_2,@ig_us_central1_3,@ig_us_central1_4,@us_ig1,@us_ig2,@my_tcp_health_check,@my_int_lb,@my_int_lb_forwarding_rule,@allow_internal_lb,@allow_health_check,@standalone_instance_1,@allow_ssh_to_standalone) return @my_custom_network,@my_custom_subnet,@allow_all_10_128_0_0_20,@allow_tcp22_tcp3389_icmp,@ig_us_central1_1,@ig_us_central1_2,@ig_us_central1_3,@ig_us_central1_4,@us_ig1,@us_ig2,@my_tcp_health_check,@my_int_lb,@my_int_lb_forwarding_rule,@allow_internal_lb,@allow_health_check,@standalone_instance_1,@allow_ssh_to_standalone on_error: stop_debugging() do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Launch")
  call start_debugging()
  provision(@my_custom_network)
  provision(@my_custom_subnet)
  provision(@allow_all_10_128_0_0_20)
  provision(@allow_tcp22_tcp3389_icmp)
  provision(@ig_us_central1_1)
  provision(@ig_us_central1_2)
  provision(@ig_us_central1_3)
  provision(@ig_us_central1_4)
  provision(@us_ig1)

  # gcloud compute instance-groups unmanaged add-instances us-ig1 \
  #   --instances ig-us-central1-1,ig-us-central1-2 \
  #   --zone us-central1-b
  @operation = @us_ig1.addInstances({"instances":[{"instance": @ig_us_central1_1},{"instance": @ig_us_central1_2}],"zone": "us-central1-b"})
  # GCE returns operations for many actions. This definition waits for the operation to complete before continuing
  call wait_for_operation_done(@operation)
  
  provision(@us_ig2)

  # gcloud compute instance-groups unmanaged add-instances us-ig2 \
  #     --instances ig-us-central1-3,ig-us-central1-4 \
  #     --zone us-central1-c
  @operation = @us_ig2.addInstances({"instances":[{"instance": @ig_us_central1_3},{"instance": @ig_us_central1_4}],"zone": "us-central1-c"})
  # GCE returns operations for many actions. This definition waits for the operation to complete before continuing
  call wait_for_operation_done(@operation)

  provision(@my_tcp_health_check)
  provision(@my_int_lb)

  # gcloud compute backend-services add-backend my-int-lb \
  #   --instance-group us-ig1 \
  #   --instance-group-zone us-central1-b \
  #   --region us-central1
  # gcloud compute backend-services add-backend my-int-lb \
  #   --instance-group us-ig2 \
  #   --instance-group-zone us-central1-c \
  #   --region us-central1
  @operation = @my_int_lb.patch({"backends":[{"group": @us_ig1}, {"group": @us_ig2}]})
  # GCE returns operations for many actions. This definition waits for the operation to complete before continuing
  call wait_for_operation_done(@operation)

  provision(@my_int_lb_forwarding_rule)
  provision(@allow_internal_lb)
  provision(@allow_health_check)
  provision(@standalone_instance_1)
  provision(@allow_ssh_to_standalone)

  # gcloud compute instances delete-access-config ig-us-central1-1 \
  #   --access-config-name external-nat --zone us-central1-b
  @operation = @ig_us_central1_1.deleteAccessConfig({"accessConfig": "external-nat", "networkInterface": "nic0"})
  call wait_for_operation_done(@operation)

  # gcloud compute instances delete-access-config ig-us-central1-2 \
  #   --access-config-name external-nat --zone us-central1-b
  @operation = @ig_us_central1_2.deleteAccessConfig({"accessConfig": "external-nat", "networkInterface": "nic0"})
  call wait_for_operation_done(@operation)

  # gcloud compute instances delete-access-config ig-us-central1-3 \
  #   --access-config-name external-nat --zone us-central1-c
  @operation = @ig_us_central1_3.deleteAccessConfig({"accessConfig": "external-nat", "networkInterface": "nic0"})
  call wait_for_operation_done(@operation)

  # gcloud compute instances delete-access-config ig-us-central1-4 \
  #   --access-config-name external-nat --zone us-central1-c
  @operation = @ig_us_central1_4.deleteAccessConfig({"accessConfig": "external-nat", "networkInterface": "nic0"})
  call wait_for_operation_done(@operation)
  
  call stop_debugging()
end

define terminate(@my_custom_network,@my_custom_subnet,@allow_all_10_128_0_0_20,@allow_tcp22_tcp3389_icmp,@ig_us_central1_1,@ig_us_central1_2,@ig_us_central1_3,@ig_us_central1_4,@us_ig1,@us_ig2,@my_tcp_health_check,@my_int_lb,@my_int_lb_forwarding_rule,@allow_internal_lb,@allow_health_check,@standalone_instance_1,@allow_ssh_to_standalone) on_error: stop_debugging() do
  call sys_log.set_task_target(@@deployment)
  call sys_log.summary("Terminate")
  call start_debugging()
  delete(@allow_ssh_to_standalone)
  delete(@standalone_instance_1)
  delete(@allow_health_check)
  delete(@allow_internal_lb)
  delete(@my_int_lb_forwarding_rule)
  delete(@my_int_lb)
  delete(@my_tcp_health_check)
  delete(@us_ig2)
  delete(@us_ig1)
  delete(@ig_us_central1_4)
  delete(@ig_us_central1_3)
  delete(@ig_us_central1_2)
  delete(@ig_us_central1_1)
  delete(@allow_tcp22_tcp3389_icmp)
  delete(@allow_all_10_128_0_0_20)
  delete(@my_custom_subnet)
  delete(@my_custom_network)
  call stop_debugging()
end

define wait_for_operation_done(@operation) do
  sub timeout: 2m, on_timeout: skip do
    sleep_until(@operation.status == "DONE")
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
