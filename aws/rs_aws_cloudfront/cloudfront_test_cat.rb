name 'CloudFront Test CAT'
rs_ca_ver 20161221
short_description "Amazon Web Services - CloudFront - Test CAT"
import "plugins/rs_aws_cloudfront"
import "sys_log"

resource "my_distribution", type: "rs_aws_cloudfront.distribution" do
  distribution_config do {
    'xmlns' => 'http://cloudfront.amazonaws.com/doc/2017-10-30/',
    'CustomErrorResponses' => [{
      'Quantity' => ['0']
    }],
    'Enabled' => ['true'],
    'CacheBehaviors' => [{
      'Quantity' => ['0']
    }],
    'DefaultCacheBehavior' => [{
      'LambdaFunctionAssociations' => [{
        'Quantity' => ['0']
      }],
      'MaxTTL' => ['31536000'],
      'MinTTL' => ['0'],
      'TargetOriginId' => ['ELB-spom-test-769851069'],
      'TrustedSigners' => [{
        'Enabled' => ['false'],
        'Quantity' => ['0']
      }],
      'DefaultTTL' => ['86400'],
      'FieldLevelEncryptionId' => [""],
      'ForwardedValues' => [{
        'Cookies' => [{
          'Forward' => ['none'],
        }],
        'Headers' => [{
          'Items' => [{
            'Name' => ["Host"]
          }],
          'Quantity' => ['1']
        }],
        'QueryString' => ['false'],
        'QueryStringCacheKeys' => [{
          'Quantity' => ['0']
        }]
      }],
      'ViewerProtocolPolicy' => ['allow-all'],
      'AllowedMethods' => [{
        'Items' => [{
          'Method' => ['HEAD','GET']
        }],
        'Quantity' => ['2'],
        'CachedMethods' => [{
          'Items' => [{
            'Method' => ['HEAD','GET']
          }],
          'Quantity' => ['2']
        }]
      }],
      'Compress' => ['false'],
      'SmoothStreaming' => ['false']
    }],
    'PriceClass' => ['PriceClass_All'],
    'Comment' => [ 'foobar' ],
    'HttpVersion' => ['http2'],
    'Logging' => [{
      'IncludeCookies' => ['false'],
      'Prefix' => [""],
      'Bucket' => [""],
      'Enabled' => ['false']
    }],
    'IsIPV6Enabled' => ['true'],
    'Origins' => [{
      'Items' => [{
        'Origin' => [{
          'Id' => ['ELB-spom-test-769851069'],
          'OriginPath' => [""],
          'CustomHeaders' => [{
            'Quantity' => ['0']
          }],
          'CustomOriginConfig' => [{
            'OriginProtocolPolicy' => ['http-only'],
            'OriginReadTimeout' => ['30'],
            'OriginSslProtocols' => [{
              'Items' => [{
                'SslProtocol' => ['TLSv1','TLSv1.1','TLSv1.2']
              }],
              'Quantity' => ['3']
            }],
            'HTTPPort' => ['80'],
            'HTTPSPort' => ['443'],
            'OriginKeepaliveTimeout' => ['5']
          }],
          'DomainName' => ['spom-test-769851069.us-east-1.elb.amazonaws.com']
        }]
      }],
      'Quantity' => ['1']
    }],
    'Restrictions' => [{
      'GeoRestriction' => [{
        'RestrictionType' => ['none'],
        'Quantity' => ['0']
      }]
    }],
    'ViewerCertificate' => [{
      'CloudFrontDefaultCertificate' => ['true'],
      'MinimumProtocolVersion' => ['TLSv1'],
      'CertificateSource' => ['cloudfront']
    }],
    'WebACLId' => [""],
    'Aliases' => [{
      'Quantity' => ['0']
    }],
    'CallerReference' => [ uuid() ],
    'DefaultRootObject' => [""]
  } end
end

#operation "terminate" do
#  definition "terminate"
#end

define get_config($distribution_id) return $config,$etag do
  call rs_aws_cloudfront.start_debugging()
  sub on_error: rs_aws_cloudfront.stop_debugging() do
    $response = http_get(
      url: 'https://cloudfront.amazonaws.com/2017-10-30/distribution/'+$distribution_id+"/config",
      signature: { type: "aws" }
    )
    $etag = $response["headers"]["Etag"]
    call sys_log.detail("ETAG: "+ to_s($etag))
    $config = $response["body"]["Distribution"]
  end
  call rs_aws_cloudfront.stop_debugging()
end

define disable_distribution(@my_distribution,$config,$etag) return @my_distribution do
  # EDIT -- need to update entire hash to support required XML format for plugins
  call rs_aws_cloudfront.start_debugging()
  sub on_error: rs_aws_cloudfront.stop_debugging() do
    $config["Enabled"] = "false"
    call sys_log.detail("Modified Config: "+to_s($config))
    @my_distribution.update(if_match: $etag, distribution_config: $config)
  end
  call rs_aws_cloudfront.stop_debugging()
end

define delete_distribution(@my_distribution,$etag) do
  @my_distribution.destroy(if_match: $etag)
end

define terminate(@my_distribution) do
  $id = @my_distribution.Id
  call get_config($id) retrieve $config,$etag
  call sys_log.detail("Retrieved Config: "+to_s($config))
  call disable_distribution(@my_distribution,$config,$etag) retrieve @my_distribution
  $status = @my_distribution.Status
  while $status != "Deployed" do
    $status = @my_distribution.Status
    sleep(10)
  end
  call get_config($id) retrieve $config2,$etag2
  call delete_distribution(@my_distribution,$etag2)
end