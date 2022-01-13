name 'AWS S3 Test CAT'
rs_ca_ver 20161221
short_description "AWS EC2 Test - Test CAT"
import "sys_log"
import "plugin/aws_compute"
import "plugins/azure_compute"

parameter "tenant_id" do
  like $azure_compute.tenant_id
end

parameter "subscription_id" do
  like $azure_compute.subscription_id
end

credentials "auth_aws" do
  schemes "aws","aws_sts"
  label "AWS"
  description "Select the AWS Credential from the list"
  tags "provider=aws"
end

credentials "azure_auth" do
  schemes "oauth2"
  label "Azure"
  description "Select the Azure Resource Manager Credential from the list."
  tags "provider=azure_rm"
end

resource "instances", type: "aws_compute.instances" do
  image_id "ami-0b898040803850657"
  instance_type "t2.large"
  subnet_id "subnet-e7eb98ac"
  key_name "Kube"
  min_count "1"
  max_count "1"
  placement_availability_zone "us-east-1b"
  placement_tenancy "default"
  tag_specification_1_resource_type "instance"
  tag_specification_1_tag_1_key "Name"
  tag_specification_1_tag_1_value @@deployment.name
end

resource "scaleset", type: "azure_compute.scale_set" do
  name join(["easy-", last(split(@@deployment.href, "/"))])
  resource_group @@deployment.name
  location "Central US"
  sku do {
    "tier" => "Standard",
    "capacity" => 3,
    "name" => "Standard_D1_v2"
  } end
  properties do {
    "overprovision" =>  true,
    "virtualMachineProfile" =>  {
      "storageProfile" =>  {
        "imageReference" =>  {
          "sku" =>  "2016-Datacenter",
          "publisher" =>  "MicrosoftWindowsServer",
          "version" =>  "latest",
          "offer" =>  "WindowsServer"
        },
        "osDisk" =>  {
          "caching" =>  "ReadWrite",
          "managedDisk" =>  {
            "storageAccountType" =>  "Standard_LRS"
          },
          "createOption" =>  "FromImage"
        }
      },
      "osProfile" =>  {
        "computerNamePrefix" =>  "vmss-easy",
        "adminUsername" =>  "rightscale",
        "adminPassword" =>  "Password1234@"
      },
      "networkProfile" =>  {
        "networkInterfaceConfigurations" =>  [
          {
            "name" =>  "vmss-easy",
            "properties" =>  {
              "primary" =>  true,
              "enableIPForwarding" =>  true,
              "ipConfigurations" =>  [
                {
                  "name" =>  "vmss-easy",
                  "properties" =>  {
                    "subnet" =>  {
                      "id" =>  join(["/subscriptions/",$subscription_id,"/resourceGroups/rs-default-centralus/providers/Microsoft.Network/virtualNetworks/ARM-CentralUS/subnets/default"])
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    },
    "upgradePolicy" =>  {
      "mode" =>  "Manual"
    }
  } end
end
