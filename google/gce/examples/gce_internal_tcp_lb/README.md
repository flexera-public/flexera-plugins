
# GCE Internal TCP Loadbalancer

**Disclaimer: This example application CAT is intended to demonstrate how one could use the gce_plugin to create resources in GCE. It is *not* intended for use in production and should not be used as a reference design.**

## Overview
This example uses the `gce_plugin` to configure an [Internal TCP LoadBalancer](https://cloud.google.com/compute/docs/load-balancing/internal/). This example intentionally omits the use of RightScale resources to demonstrate a one to one example with the GCE documented examples.
It's highly recommended you read the GCE documentation linked above while going through the source of this CAT. Naming and resource creation order were kept as close as possible to the original example. 

## Requirements
- Installation of the `gce_plugin` plugin. For details see the gce_plugin [README.md](../../README.md)
- The following packages are also required (See the Installation section for details):
  - [sys_log](../../../../libraries/sys_log.rb)

## Getting Started
This CAT creates everything needed to launch this example.

## Installation
1. Be sure your RightScale account is SelfService enabled
1. Navigate to the appropriate SelfService portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `gce_external_network_lb.rb` file located in this repository
 
## How to Use
### Launch
This will create all the GCE resources and setup an Internal TCP Load Balancer
1. Launch the `GCE Internal TCP LB` application CAT
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. Set the paramaters
   - Enter the GCE project you are launching into.

### Terminate
This will remove all the GCE resources.

## Implementation Notes
- This CAT is a one to one example of the GCE [Internal TCP LoadBalancer](https://cloud.google.com/compute/docs/load-balancing/internal/) example using RightScale SelfService Plugins to call the API instead of gcloud.
- This CAT was inteded to give numberous examples of converting gcloud commands into SelfServices resource declarations.
- Instance types were reduced to f1.micro to reduce cost and increase resource availability in the cloud.

## Known Issues
- There is a known issue in the gce_plugin during provision where 404 errors might be observed.
  - This is caused by a cloud error during the insert call which doesn't currently get passed back from the provision call

## Getting Help
Support for this example will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The GCE Plugin source code is subject to the MIT license, see the [LICENSE](../../../LICENSE) file.