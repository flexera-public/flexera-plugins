name 'Route53 Test CAT'
rs_ca_ver 20161221
short_description 'Amazon Web Services - Route 53 - Test CAT'
import 'plugins/rs_aws_route53'
import 'sys_log'
# output 'zone_name' do
#   label 'Hosted Zone Name'
#   default_value @hostedzone.Name
# end
# output 'zone_id' do
#   label 'Hosted Zone Id'
#   default_value @hostedzone.Id
# end

# resource 'hostedzone', type: 'rs_aws_route53.hosted_zone' do
#   create_hosted_zone_request do {
#     'xmlns' => 'https://route53.amazonaws.com/doc/2013-04-01/',
#     'Name' => [ join([first(split(uuid(),'-')), '.rsps.com']) ],
#     'CallerReference' => [ uuid() ]
#   } end
# end

resource 'record', type: 'rs_aws_route53.resource_recordset' do
  hosted_zone_id 'Z3LZVW3M90M8BQ'
  action 'upsert'
  comment 'some change about my recordset'
  record_sets do {
    'Name'=>[join(['myname','.','a46700e0.rsps.com'])],
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

define terminate(@record) do
  call delete_resource_recordset()
end

define delete_resource_recordset() do
  sub on_error: stop_debugging() do
    $fields = {}
    $record_set = {
      'Name':[join(['myname','.','a46700e0.rsps.com'])],
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
    $hosted_zone_id='Z3LZVW3M90M8BQ'
    call sys_log.detail("change_resource_record_sets_request: "+to_s($change_resource_record_sets_request))
    call start_debugging()
    rs_aws_route53.resource_recordset.remove(ChangeResourceRecordSetsRequest: $change_resource_record_sets_request, hosted_zone_id: $hosted_zone_id)
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
