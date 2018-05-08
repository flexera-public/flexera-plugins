# AWS Route 53 Plugin

## Overview
The AWS Route53 Plugin integrates RightScale Self-Service with the basic functionality of the AWS Route53 API.

## Requirements
- A general understanding CAT development and definitions
  - Refer to the guide documentation for details [SS Guides](http://docs.rightscale.com/ss/guides/)
- The `admin`, `ss_designer` & `ss_end_user` roles, in a RightScale account with SelfService enabled.  `admin` is needed to retrived the RightScale Credential values identified below.
- AWS Account credentials with the appropriate permissions to manage elastic load balancers
- The following RightScale Credentials
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- The following packages are also required (See the Installation section for details):
  - [sys_log](sys_log.rb)

## Getting Started
**Coming Soon**

## Installation
1. Be sure your RightScale account has Self-Service enabled
1. Connect AWS Cloud credentials to your RightScale account (if not already completed)
1. Navigate to the appropriate Self-Service portal
   - For more details on using the portal review the [SS User Interface Guide](http://docs.rightscale.com/ss/guides/ss_user_interface_guide.html)
1. In the Design section, use the `Upload CAT` interface to complete the following:
   1. Upload each of packages listed in the Requirements Section
   1. Upload the `aws_route53_plugin.rb` file located in this repository

## How to Use
The Route53 Plugin has been packaged as `plugin/rs_aws_route53`. In order to use this plugin you must import this plugin into a CAT.
```
import "plugin/rs_aws_route53"
```
For more information on using packages, please refer to the RightScale online documenataion. [Importing a Package](http://docs.rightscale.com/ss/guides/ss_packaging_cats.html#importing-a-package)

## Supported Resources
###  hosted_zone - create a new public or private hosted zone
#### Supported Fields
**Note:** There are many possible configurations when defining a `hosted_zone` resource.  While some fields below are not listed as "Required", they may actually be required for your resource,  depending on the value(s) of other field(s). More detailed API documentation is available [here](https://docs.aws.amazon.com/Route53/latest/APIReference/API_Operations_Amazon_Route_53.html).

| Field Name | Required? | Description |
|------------|-----------|-------------|
| create_hosted_zone_request | yes | An object describing the zone to be created.  See example |


#### Supported Outputs
- Id

#### Usage
AWS Route53 resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

```
#Creates a new Route 53 Hosted Zone
resource "hostedzone", type: "rs_aws_route53.hosted_zone" do
  create_hosted_zone_request do {
    "xmlns" => "https://route53.amazonaws.com/doc/2013-04-01/",
    "Name" => [ join([first(split(uuid(),'-')), ".rsps.com"]) ],
    "CallerReference" => [ uuid() ]
  } end
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| create | [CreateHostedZone](https://docs.aws.amazon.com/Route53/latest/APIReference/API_CreateHostedZone.html) | Supported |
| destroy | [DeleteHostedZone](https://docs.aws.amazon.com/Route53/latest/APIReference/API_DeleteHostedZone.html) | Supported |
| get | [GetHostedZone](https://docs.aws.amazon.com/Route53/latest/APIReference/API_GetHostedZone.html) | Supported |
| list | [ListHostedZones](https://docs.aws.amazon.com/Route53/latest/APIReference/API_ListHostedZones.html) | Supported |

### recordset

#### Supported Fields
**Note:** There are many possible configurations when defining a `recordset` resource.  While some fields below are not listed as "Required", they may actually be required for your resource,  depending on the value(s) of other field(s). More detailed API documentation is available [here](https://docs.aws.amazon.com/Route53/latest/APIReference/API_Operations_Amazon_Route_53.html).

| Field Name | Required? | Description |
|------------|-----------|-------------|
| hosted_zone_id | yes | id from the hosted_zone resource |  
| change_resource_record_sets_request | yes | an object describing the records to change.  see example  |  
| action | no | the action for the record set. 'CREATE', 'UPSERT','DELETE'.  Defaults to 'UPSERT' |

#### Supported Outputs
- Id
- Status
- Comment
- SubmittedAt


#### Usage
AWS Route53 resources can now be created by specifying a resource declaration with the desired fields. See the Supported Actions section for a full list of supported actions.
The resulting resource can be manipulated just like the native RightScale resources in RCL and CAT. See the Examples Section for more examples and complete CAT's.

```
#ResourceRecordSets
resource "record", type: "rs_aws_route53.resource_recordset" do
  hosted_zone_id @hostedzone.Id
  action 'UPSERT'
  comment 'some comment about the record'
  resource_record_sets do {
    "xmlns" => "https://route53.amazonaws.com/doc/2013-04-01/",
    "ChangeBatch"=>[
      "Changes"=>[
        "Change"=>[
          "Action"=>["UPSERT"],
          "ResourceRecordSet"=>[
          "Name"=>[join(["myname",".",@hostedzone.Name])],
          "Type"=>["A"],
          "TTL"=>["300"],
          "ResourceRecords"=>[
            "ResourceRecord"=>[
              "Value"=>["1.2.3.4"]
            ]
          ]
        ]
        ],
      ],
      "Comment"=>["Some Comments"],
    ]
  }
  end
end
```

#### Supported Actions

| Action | API Implementation | Support Level |
|--------------|:----:|:-------------:|
| Create | [ChangeResourceRecordSets](https://docs.aws.amazon.com/Route53/latest/APIReference/API_ChangeResourceRecordSets.html) | Supported |
| destroy | must use terminate operation.  See Limitations below. | Not Supported |
| get |  | Not Supported |


## Examples
Please review [route53_test_cat.rb](./route53_test_cat.rb) for a basic example implementation.

## Known Issues / Limitations
- This plugin is missing many actions to fully managed Route53.
- The auto-terminate operation of the CAT can not delete the resource_recordset.  There for you need to
use a terminate operation to remove the resource_record_set.  See example CAT [route53_test_cat.rb](./route53_test_cat.rb)

## Resource Pool
```
resource_pool "route53" do
  plugin $rs_aws_route53
  host "route53.amazonaws.com"
  auth "key", type: "aws" do
    version     4
    service    'route53'
    region     'us-east-1'
    access_key cred('AWS_ACCESS_KEY_ID')
    secret_key cred('AWS_SECRET_ACCESS_KEY')
  end
end
```

## Getting Help
Support for this plugin will be provided though GitHub Issues and the RightScale public slack channel #plugins.
Visit http://chat.rightscale.com/ to join!

## License
The AWS Route53 Plugin source code is subject to the MIT license, see the [LICENSE](../../LICENSE) file.
