# RightScale Plugins
This repo contains a library of open source RightScale plugins.

## Released Plugins
### Amazon Web Services
- [AWS Elastic Load Balancer (Classic LB)](./aws/rs_aws_elb/)
- [AWS Elastic Load Balancer (Application LB)](./aws/rs_aws_alb/)
- [AWS Elastic File System](./aws/rs_aws_efs/)
- [AWS Relational Database Service](./aws/rs_aws_rds/)
- [AWS CloudFormation](./aws/rs_aws_cft/)
- [AWS Virtual Private Cloud](./aws/rs_aws_vpc/)

### Azure
- [Azure SQL Database](./azure/rs_azure_sql/)
- [Azure ARM Templates](./azure/rs_azure_template)
- [Azure Compute](./azure/rs_azure_compute)
- [Azure Database for MySQL](./azure/rs_azure_mysql)
- [Azure Storage](./azure/rs_azure_storage/)
- [Azure Container Services](./azure/rs_azure_containerservices/)
- [Azure Load Balancer](./azure/rs_azure_networking/)
- [Azure Networking Interface](./azure/rs_azure_networking/)
- [Azure PostgreSQL](./azure/rs_azure_pgsql/)
- [Azure Redis Cache](./azure/rs_azure_cache/)

### Google Cloud Platform
- [GCP Google Compute Engine](./google/gce/)
- [GCP Cloud DNS](./google/google_cloud_dns/)
- [GCP Cloud SQL](./google/google_cloud_sql/)

## RightScale Plugin Documentation
- [Guide](http://docs.rightscale.com/ss/guides/ss_plugins.html)
- [Reference Documentation](http://docs.rightscale.com/ss/reference/cat/v20161221/ss_plugins.html)

## Getting Help
Support for these plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

### Opening an Issue
Github issues contain a template for three types of requests(Bugs, New Features to an existing Plugin, New Plugin Request)
Use one of the three templates and remove the other template sections. 

- Bugs: Any issue you are having with an existing plugin not functioning correctly, this does not include missing features, or actions.
- New Feature Request: Any feature(Field, Action, Link, Output, etc) that are to be added to an existing plugin. 
- New Plugin Request: Request for a new plugin based off of a new Resource(i.e Cloud Resource Type(`rds`,`elb`), Third Party Service(`riverbed`,`f5`,`cisco`), etc. 
