name 'Route53 Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - Route 53 - Test CAT"
import "plugins/rs_aws_route53"

resource "hostedzone", type: "rs_aws_route53.hosted_zone" do
  create_hosted_zone_request do {
    "xmlns" => "https://route53.amazonaws.com/doc/2013-04-01/",
    "Name" => [ join([first(split(uuid(),'-')), ".rsps.com"]) ],
    "CallerReference" => [ uuid() ]
  } end
end

