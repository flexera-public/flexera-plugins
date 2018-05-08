name 'Route53 Test CAT'
rs_ca_ver 20161221
short_description 'Amazon Web Services - Route 53 - Test CAT'
import 'plugins/rs_aws_route53'
import 'sys_log'

output 'zone_name' do
  label 'Hosted Zone Name'
  default_value @hostedzone.Name
end
output 'zone_id' do
  label 'Hosted Zone Id'
  default_value @hostedzone.Id
end

resource 'hostedzone', type: 'rs_aws_route53.hosted_zone' do
  create_hosted_zone_request do {
    'xmlns' => 'https://route53.amazonaws.com/doc/2013-04-01/',
    'Name' => [ join([first(split(uuid(),'-')), '.rsps.com']) ],
    'CallerReference' => [ uuid() ]
  } end
end

resource 'record', type: 'rs_aws_route53.resource_recordset' do
  hosted_zone_id @hostedzone.Id
  action 'upsert'
  comment 'some change about my recordset'
  record_sets do {
    'Name'=>[join(['myname','.',@hostedzone.Name])],
    'Type'=>['A'],
    'TTL'=>['300'],
    'ResourceRecords'=>[
      'ResourceRecord'=>[
        'Value'=>['1.2.3.4']
      ]
    ]
  }
  end
end

operation 'terminate' do
  description 'remove the resources'
  definition 'terminate'
end

define terminate(@hostedzone) return @hostedzone do
  call delete_resource_recordset(@hostedzone)
end

#
# There is a limitation to the Route 53 API that does not allow
# deleting the resourse using the auto-terminate operation.
# instead of using auto-terminate us the definition below and call it in a
# terminate operation.  See above operation and definition
#
define delete_resource_recordset(@hostedzone) return @hostedzone do
  sub on_error: stop_debugging() do
    $fields = {}
    $record_set = {
      'Name':[join(['myname','.',@hostedzone.Name])],
      'Type':['A'],
      'TTL':['300'],
      'ResourceRecords':[{
        'ResourceRecord':[{
          'Value':['1.2.3.4']
        }]
      }]
    }
    $change_resource_record_sets_request =  {
        'xmlns': 'https://route53.amazonaws.com/doc/2013-04-01/',
        'ChangeBatch': [{
          'Changes': [{
            'Change': [{
              'Action': ['DELETE'],
              'ResourceRecordSet': [ $record_set ]
            }]
          }]
        }]
    }
    call start_debugging()
    rs_aws_route53.resource_recordset.remove(ChangeResourceRecordSetsRequest: $change_resource_record_sets_request,
      hosted_zone_id: @hostedzone.Id)
    call stop_debugging()
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
