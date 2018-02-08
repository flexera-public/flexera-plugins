# Change Log

## [Week-of-02-05-2018](https://github.com/rightscale/rightscale-plugins/tree/Week-of-02-05-2018) (2018-02-08)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-01-29-2018...Week-of-02-05-2018)

**Fixed bugs:**

- Incorrect regex condition to match the nic name  [\#129](https://github.com/rightscale/rightscale-plugins/issues/129)

**Closed issues:**

- rs\_azure\_storage: Add "update" action [\#135](https://github.com/rightscale/rightscale-plugins/issues/135)
- rs\_azure\_networking test cat does not successfully terminate. [\#132](https://github.com/rightscale/rightscale-plugins/issues/132)
- READMEs have wrong link to sys\_log as part of the Installation instructions [\#116](https://github.com/rightscale/rightscale-plugins/issues/116)

**Merged pull requests:**

- Azure Storage Plugin: Adds the update\(patch\) action to the plugin. [\#136](https://github.com/rightscale/rightscale-plugins/pull/136) ([srpomeroy](https://github.com/srpomeroy))
- Azure Networking Plugin: custom terminate on lb test cat [\#133](https://github.com/rightscale/rightscale-plugins/pull/133) ([srpomeroy](https://github.com/srpomeroy))
- Azure Networking Plugin: Test Cat Fix [\#131](https://github.com/rightscale/rightscale-plugins/pull/131) ([srpomeroy](https://github.com/srpomeroy))

## [Week-of-01-29-2018](https://github.com/rightscale/rightscale-plugins/tree/Week-of-01-29-2018) (2018-01-29)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-01-22-2018...Week-of-01-29-2018)

**Fixed bugs:**

- Azure MySQL: firewall\_rules provisioning loop [\#127](https://github.com/rightscale/rightscale-plugins/issues/127)
- AWS ELB: Provision function gets DNSName instead of Name  [\#125](https://github.com/rightscale/rightscale-plugins/issues/125)

**Merged pull requests:**

- Azure MySQL: Firewall\_Rules Provision\(\) Bug Fix [\#128](https://github.com/rightscale/rightscale-plugins/pull/128) ([dfrankel33](https://github.com/dfrankel33))
- AWS ELB: Bug Fixes  [\#126](https://github.com/rightscale/rightscale-plugins/pull/126) ([dfrankel33](https://github.com/dfrankel33))

## [Week-of-01-22-2018](https://github.com/rightscale/rightscale-plugins/tree/Week-of-01-22-2018) (2018-01-22)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-01-15-2018...Week-of-01-22-2018)

**Fixed bugs:**

- AWS ELB & ALB - Serialization Exception [\#106](https://github.com/rightscale/rightscale-plugins/issues/106)

**Merged pull requests:**

- AWS ELB Plugin - Setting Content-Type header and removing description.  [\#123](https://github.com/rightscale/rightscale-plugins/pull/123) ([rshade](https://github.com/rshade))
- AWS ALB Plugin: Updating header to fix serialization exception.  [\#122](https://github.com/rightscale/rightscale-plugins/pull/122) ([rshade](https://github.com/rshade))

## [Week-of-01-15-2018](https://github.com/rightscale/rightscale-plugins/tree/Week-of-01-15-2018) (2018-01-18)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-12-11-2017...Week-of-01-15-2018)

**Merged pull requests:**

- Google GKE Plugin: minor corrections to the CAT \(version used\) and README. [\#119](https://github.com/rightscale/rightscale-plugins/pull/119) ([MitchellGerdisch](https://github.com/MitchellGerdisch))
- Azure Service Diagnostic Settings plugin - Initial Release [\#117](https://github.com/rightscale/rightscale-plugins/pull/117) ([srpomeroy](https://github.com/srpomeroy))
- AWS CloudFormation Plugin: Increased number of allowed CFT parameters from 10 to 30. [\#115](https://github.com/rightscale/rightscale-plugins/pull/115) ([MitchellGerdisch](https://github.com/MitchellGerdisch))

## [Week-of-12-11-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-12-11-2017) (2017-12-14)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-11-27-2017...Week-of-12-11-2017)

**Fixed bugs:**

- RDS Plugin: fix stop\_debugging  [\#112](https://github.com/rightscale/rightscale-plugins/issues/112)

**Merged pull requests:**

- AWS RDS Plugin - updating to use generics, fix stop\_debugging.  [\#113](https://github.com/rightscale/rightscale-plugins/pull/113) ([rshade](https://github.com/rshade))
- Add Azure virtual network and subnet types [\#110](https://github.com/rightscale/rightscale-plugins/pull/110) ([srpomeroy](https://github.com/srpomeroy))

## [Week-of-11-27-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-11-27-2017) (2017-11-30)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-11-05-2017...Week-of-11-27-2017)

**Merged pull requests:**

- AWS MQ & AWS PrivateLink - Initial Releases  [\#108](https://github.com/rightscale/rightscale-plugins/pull/108) ([dfrankel33](https://github.com/dfrankel33))

## [Week-of-11-05-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-11-05-2017) (2017-11-06)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-10-30-2017...Week-of-11-05-2017)

**Merged pull requests:**

- Add VNET peering resource \(\#96\) [\#101](https://github.com/rightscale/rightscale-plugins/pull/101) ([rshade](https://github.com/rshade))
- Add VMWare NSX to readme [\#100](https://github.com/rightscale/rightscale-plugins/pull/100) ([nathan-rightscale](https://github.com/nathan-rightscale))
- VMWare NSX Plugin [\#99](https://github.com/rightscale/rightscale-plugins/pull/99) ([nathan-rightscale](https://github.com/nathan-rightscale))
- Add VNET peering resource [\#96](https://github.com/rightscale/rightscale-plugins/pull/96) ([AnominousSign](https://github.com/AnominousSign))

## [Week-of-10-30-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-10-30-2017) (2017-10-31)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-10-23-2017...Week-of-10-30-2017)

**Merged pull requests:**

- GKE - Initial Release [\#95](https://github.com/rightscale/rightscale-plugins/pull/95) ([dfrankel33](https://github.com/dfrankel33))

## [Week-of-10-23-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-10-23-2017) (2017-10-24)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-10-02-2017...Week-of-10-23-2017)

**Merged pull requests:**

- Fastly Public IP Address List Plugins [\#91](https://github.com/rightscale/rightscale-plugins/pull/91) ([rshade](https://github.com/rshade))

## [Week-of-10-02-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-10-02-2017) (2017-10-04)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-09-18-2017...Week-of-10-02-2017)

**Merged pull requests:**

- Azure Key Vault - Initial Release [\#88](https://github.com/rightscale/rightscale-plugins/pull/88) ([dfrankel33](https://github.com/dfrankel33))

## [Week-of-09-18-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-09-18-2017) (2017-09-19)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-09-04-2017...Week-of-09-18-2017)

**Merged pull requests:**

- GCP Bigtable - Initial Release [\#85](https://github.com/rightscale/rightscale-plugins/pull/85) ([dfrankel33](https://github.com/dfrankel33))

## [Week-of-09-04-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-09-04-2017) (2017-09-07)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-08-28-2017...Week-of-09-04-2017)

**Merged pull requests:**

- Infoblox IPAM - Initial Release [\#83](https://github.com/rightscale/rightscale-plugins/pull/83) ([MitchellGerdisch](https://github.com/MitchellGerdisch))
- AWS Lambda - Initial Release [\#82](https://github.com/rightscale/rightscale-plugins/pull/82) ([dfrankel33](https://github.com/dfrankel33))
- AWS ELB - Fix README [\#81](https://github.com/rightscale/rightscale-plugins/pull/81) ([gonzalez](https://github.com/gonzalez))

## [Week-of-08-28-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-08-28-2017) (2017-08-30)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-08-21-2017...Week-of-08-28-2017)

**Fixed bugs:**

- ElastiCache - Fix debug report on auto-terminate [\#78](https://github.com/rightscale/rightscale-plugins/issues/78)

**Merged pull requests:**

- ElastiCache - bug fix issue \#78 [\#79](https://github.com/rightscale/rightscale-plugins/pull/79) ([dfrankel33](https://github.com/dfrankel33))
- AWS ElastiCache - Initial Release [\#76](https://github.com/rightscale/rightscale-plugins/pull/76) ([dfrankel33](https://github.com/dfrankel33))
- AWS VPC Plugin - Adding in Actions: EnableVpcClassicLink,EnableVpcClassicLinkDnsSupport,Create\_Tag [\#75](https://github.com/rightscale/rightscale-plugins/pull/75) ([rshade](https://github.com/rshade))
- AWS VPC Plugin - Adding Nat Gateway Support, Addresses Read-Only Support [\#74](https://github.com/rightscale/rightscale-plugins/pull/74) ([rshade](https://github.com/rshade))

## [Week-of-08-21-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-08-21-2017) (2017-08-24)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-08-14-2017...Week-of-08-21-2017)

**Closed issues:**

- CFT Plugin: Needs to handle nested CFTs [\#57](https://github.com/rightscale/rightscale-plugins/issues/57)
- handle\_retries is not defined  [\#55](https://github.com/rightscale/rightscale-plugins/issues/55)

**Merged pull requests:**

- AWS VPC - add readme link.  change folder name [\#71](https://github.com/rightscale/rightscale-plugins/pull/71) ([dfrankel33](https://github.com/dfrankel33))
- Codeowners [\#69](https://github.com/rightscale/rightscale-plugins/pull/69) ([rshade](https://github.com/rshade))
- AWS VPC Plugin - Initial Release [\#67](https://github.com/rightscale/rightscale-plugins/pull/67) ([rshade](https://github.com/rshade))
- Adding CODEOWNERS to git root [\#66](https://github.com/rightscale/rightscale-plugins/pull/66) ([rshade](https://github.com/rshade))
- Libraries - move cat\_spec package [\#65](https://github.com/rightscale/rightscale-plugins/pull/65) ([dfrankel33](https://github.com/dfrankel33))
- AWS CFT - fix "filter" field [\#64](https://github.com/rightscale/rightscale-plugins/pull/64) ([dfrankel33](https://github.com/dfrankel33))

## [Week-of-08-14-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-08-14-2017) (2017-08-17)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-08-07-2017...Week-of-08-14-2017)

**Closed issues:**

- Azure Container Service - Add in Agent Update for scaling [\#53](https://github.com/rightscale/rightscale-plugins/issues/53)

**Merged pull requests:**

- Azure Compute Plugin - Adding vmSizes\(\) action to VirtualMachine resource [\#62](https://github.com/rightscale/rightscale-plugins/pull/62) ([rshade](https://github.com/rshade))
- AWS CloudFormation Template Plugin - Adding Support for Nested Templates, Fixes for Issue \#57 [\#61](https://github.com/rightscale/rightscale-plugins/pull/61) ([MitchellGerdisch](https://github.com/MitchellGerdisch))
- Azure Compute Plugin - Adding update to the VirtualMachine resource [\#60](https://github.com/rightscale/rightscale-plugins/pull/60) ([rshade](https://github.com/rshade))
- Amazon RDS Plugin - Adding in handle\_retries definition, Fixes \#55 [\#59](https://github.com/rightscale/rightscale-plugins/pull/59) ([rshade](https://github.com/rshade))
- Azure Redis Cache Plugin [\#58](https://github.com/rightscale/rightscale-plugins/pull/58) ([rshade](https://github.com/rshade))
- Azure Container Service adding in update, and delete retry [\#56](https://github.com/rightscale/rightscale-plugins/pull/56) ([rshade](https://github.com/rshade))

## [Week-of-08-07-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-08-07-2017) (2017-08-10)
[Full Changelog](https://github.com/rightscale/rightscale-plugins/compare/Week-of-07-31-2017...Week-of-08-07-2017)

**Implemented enhancements:**

- ARM Template - Improve Error Handling [\#47](https://github.com/rightscale/rightscale-plugins/issues/47)

**Closed issues:**

- Azure Container Service with rightlink, and container output in RS [\#45](https://github.com/rightscale/rightscale-plugins/issues/45)

**Merged pull requests:**

- Azure MySQL Server Plugin [\#52](https://github.com/rightscale/rightscale-plugins/pull/52) ([srpomeroy](https://github.com/srpomeroy))
- Azure Networking Plugin [\#51](https://github.com/rightscale/rightscale-plugins/pull/51) ([rshade](https://github.com/rshade))
- Adding putty key to azure container services test cat.  [\#50](https://github.com/rightscale/rightscale-plugins/pull/50) ([rshade](https://github.com/rshade))
- Google CloudSQL Plugin [\#49](https://github.com/rightscale/rightscale-plugins/pull/49) ([dfrankel33](https://github.com/dfrankel33))
- Azure ARM Template Plugin - Improved Error Handling, Fixes \#47 [\#48](https://github.com/rightscale/rightscale-plugins/pull/48) ([dfrankel33](https://github.com/dfrankel33))
- Azure PostgreSQL Server Plugin [\#38](https://github.com/rightscale/rightscale-plugins/pull/38) ([rshade](https://github.com/rshade))
- Azure Load Balancer Plugin [\#24](https://github.com/rightscale/rightscale-plugins/pull/24) ([rshade](https://github.com/rshade))

## [Week-of-07-31-2017](https://github.com/rightscale/rightscale-plugins/tree/Week-of-07-31-2017) (2017-08-02)
**Implemented enhancements:**

- add VM Extension support to Azure Compute plugin [\#31](https://github.com/rightscale/rightscale-plugins/issues/31)
- SQL Plugin: Storage Account key use [\#25](https://github.com/rightscale/rightscale-plugins/issues/25)

**Fixed bugs:**

- RDS Plugin: See an error related to the logging stuff when terminating [\#33](https://github.com/rightscale/rightscale-plugins/issues/33)
- RDS Plugin: Non-VPC RDS throws error about sec group [\#27](https://github.com/rightscale/rightscale-plugins/issues/27)
- RDS Plugin: allocated\_storage using parameter doesn't work [\#26](https://github.com/rightscale/rightscale-plugins/issues/26)

**Merged pull requests:**

- Azure Compute Plugin - Fixing Virtual Machine Extensions to raise on failure properly [\#43](https://github.com/rightscale/rightscale-plugins/pull/43) ([rshade](https://github.com/rshade))
- Azure Compute Plugin - adding in extensions support, Fixes \#31 [\#42](https://github.com/rightscale/rightscale-plugins/pull/42) ([rshade](https://github.com/rshade))
- Azure Container Services Plugin [\#41](https://github.com/rightscale/rightscale-plugins/pull/41) ([rshade](https://github.com/rshade))
- Azure Storage Account Plugin [\#35](https://github.com/rightscale/rightscale-plugins/pull/35) ([rshade](https://github.com/rshade))
- Amazon RDS Plugin - Fixes \#33 [\#34](https://github.com/rightscale/rightscale-plugins/pull/34) ([dfrankel33](https://github.com/dfrankel33))
- Azure Compute Plugin - Availability Set Resource [\#30](https://github.com/rightscale/rightscale-plugins/pull/30) ([rshade](https://github.com/rshade))
- Amazon RDS Plugin - tweak resource hrefs. fixes \#27 [\#29](https://github.com/rightscale/rightscale-plugins/pull/29) ([dfrankel33](https://github.com/dfrankel33))
- Amazon RDS Plugin - Updated all fields to strings for issue \#26 [\#28](https://github.com/rightscale/rightscale-plugins/pull/28) ([dfrankel33](https://github.com/dfrankel33))
- Azure Microsoft SQL Server Plugin - Adding databases, firewall\_rules, elastic\_pools,and failover\_groups links [\#23](https://github.com/rightscale/rightscale-plugins/pull/23) ([rshade](https://github.com/rshade))
- Updating Root Readme, Adding Cloud Categories [\#22](https://github.com/rightscale/rightscale-plugins/pull/22) ([dfrankel33](https://github.com/dfrankel33))
- Updating Google Plugins moving them into a Google Cloud Folder [\#21](https://github.com/rightscale/rightscale-plugins/pull/21) ([dfrankel33](https://github.com/dfrankel33))
- Azure ARM Template Plugin [\#19](https://github.com/rightscale/rightscale-plugins/pull/19) ([dfrankel33](https://github.com/dfrankel33))
- Azure Microsoft SQL Server Plugin [\#18](https://github.com/rightscale/rightscale-plugins/pull/18) ([rshade](https://github.com/rshade))
- Azure SQL Server Plugin - Adding Additional Resources  [\#17](https://github.com/rightscale/rightscale-plugins/pull/17) ([rshade](https://github.com/rshade))
- Updating Google GCE Plugin - Add clarity around non-native resources [\#16](https://github.com/rightscale/rightscale-plugins/pull/16) ([nathan-rightscale](https://github.com/nathan-rightscale))
- Google Cloud DNS [\#15](https://github.com/rightscale/rightscale-plugins/pull/15) ([dfrankel33](https://github.com/dfrankel33))
- Updating Root Readme [\#14](https://github.com/rightscale/rightscale-plugins/pull/14) ([dfrankel33](https://github.com/dfrankel33))
- Google GCE Plugin [\#13](https://github.com/rightscale/rightscale-plugins/pull/13) ([rshade](https://github.com/rshade))
- AWS CloudFormation Template Plugin [\#12](https://github.com/rightscale/rightscale-plugins/pull/12) ([dfrankel33](https://github.com/dfrankel33))
- AWS Application Load Balancer Plugin [\#11](https://github.com/rightscale/rightscale-plugins/pull/11) ([rshade](https://github.com/rshade))
- Adding sys\_log to libraries as it is necessary for all plugins [\#10](https://github.com/rightscale/rightscale-plugins/pull/10) ([dfrankel33](https://github.com/dfrankel33))
- AWS ELB Plugin Updated [\#8](https://github.com/rightscale/rightscale-plugins/pull/8) ([dfrankel33](https://github.com/dfrankel33))
- AWS RDS Plugin Updated [\#7](https://github.com/rightscale/rightscale-plugins/pull/7) ([dfrankel33](https://github.com/dfrankel33))
- AWS EFS Plugin Updated [\#6](https://github.com/rightscale/rightscale-plugins/pull/6) ([dfrankel33](https://github.com/dfrankel33))
- Adding db\_subnet\_group resource to AWS RDS Plugin [\#4](https://github.com/rightscale/rightscale-plugins/pull/4) ([rshade](https://github.com/rshade))
- Allow - in project name [\#2](https://github.com/rightscale/rightscale-plugins/pull/2) ([bryankaraffa](https://github.com/bryankaraffa))
- Amazon RDS Plugin - v0.0.1 [\#1](https://github.com/rightscale/rightscale-plugins/pull/1) ([dfrankel33](https://github.com/dfrankel33))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*