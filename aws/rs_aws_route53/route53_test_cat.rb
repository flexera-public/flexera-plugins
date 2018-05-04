name 'Route53 Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - Route 53 - Test CAT"
import "plugins/rs_aws_route53"

output "zone_name" do
  label "Hosted Zone Name"
  default_value @hostedzone.Name
end
output "zone_id" do
  label "Hosted Zone Id"
  default_value @hostedzone.Id
end

resource "hostedzone", type: "rs_aws_route53.hosted_zone" do
  create_hosted_zone_request do {
    "xmlns" => "https://route53.amazonaws.com/doc/2013-04-01/",
    "Name" => [ join([first(split(uuid(),'-')), ".rsps.com"]) ],
    "CallerReference" => [ uuid() ]
  } end
end

resource "record", type: "rs_aws_route53.resource_recordset" do
  hosted_zone_id @hostedzone.Id
  action "UPSERT"
  change_resource_record_sets_request do {
    "xmlns" => "https://route53.amazonaws.com/doc/2013-04-01/",
    "ChangeBatch"=>[
      "Changes"=>[
        "Change"=>[
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
