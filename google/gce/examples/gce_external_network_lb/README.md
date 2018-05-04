
# GCE External Network Loadbalancer

**Disclaimer: This example application CAT is intended to demonstrate how one could use the gce_plugin to create resources in GCE. It is *not* intended for use in production and should not be used as a reference design.**

## Overview
This example uses the `gce_plugin` to configure an [External Network LoadBalancer](https://cloud.google.com/compute/docs/load-balancing/network/example), creates a RightScale Server Array and attaches each instance in that array to the targetPool of the External LoadBalancer.

## Requirements
- Installation of the `gce_plugin` plugin. For details see the gce_plugin [README.md](../../README.md)
- The `RightLink_10_6_0_GCE_Ubuntu_16` Server Template
- Fully configured GCE network/security_goups to launch the ServerTemplate with.
- The following RightScale Credentials must exist with the appropriate values
  - `GCE_PLUGIN_ACCOUNT`
  - `GCE_PLUGIN_PKJSON`
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../../../libraries/sys_log.rb)

## Getting Started
### Uploading the RightLink_10_6_0_GCE_Ubuntu_16 Template
A `right_st` download of this ServerTemplate has been provided in the RightLink_10_6_0_GCE_Ubuntu_16 directory of this example. Please consult the [right_st Documentation](https://github.com/rightscale/right_st) for details on uploading this template.

### Creating the Rightscale Credentials
1. `GCE_PLUGIN_ACCOUNT`
   - This is the email address of the service account that was created for registering an instance to the targetPool.
   - For the purpose of this example you can re-use the credential created as part of the installation of the `gce_plugin`.
1. `GCE_PLUGIN_PKJSON`
   - This contains the full JSON downloaded when creating the Service Account.
   - In the installation instructions of the `gce_plugin` you were instructed to extract the private_key node to put in a Credential. This Credential takes the entire JSON file.

### Configuring the GCE Network
1. Create/configure your network/subnet to allow all outbound internet access. We recommend using the default network/subnets for this example.
   - Advanced use cases such as restricted networking are supported but outside of the scope of this example.
1. Create a Security Group in the above network/subnet to allow port 80 from 0.0.0.0/0
   - Advanced use cases such as restricting access are outside the scope of this example.

## Installation
1. Be sure your RightScale account is SelfService enabled
1. Follow the Getting Started section to upload the ServerTemplate, create the Rightscale Credentials and configure the GCE Network.
   - The Security Group must expose access to port 80 in order for the healthchecks and exteranl traffic to browse the site
1. Navigate to the appropriate SelfService portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `gce_external_network_lb.rb` file located in this repository
 
## How to Use
### Launch
This will create all the GCE resources and launch an array of webservers.
1. Launch the `GCE External Network LB` application CAT
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. Set the paramaters
   - Use the name of the network/subnet/security groups created in the `Getting Started` section.

### Terminate
This will remove all the GCE resources and terminate the array of webservers.

## Implementation Notes
- RightScale no longer maintains images for every cloud. The provided ServerTemplate uses the latest available Ubuntu 16.04 image, however this may be depricated at any time which would deem this template non-funcational. If you run into issues launching this template due to the image no longer being available please create a github ticket or notify #plugins channel.
- This example currently doesn't handle networking. This must already be in place to use this CAT.
	
## Getting Help
Support for this example will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The GCE Plugin source code is subject to the MIT license, see the [LICENSE](../../../LICENSE) file.
