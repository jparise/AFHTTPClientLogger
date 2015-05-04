Pod::Spec.new do |s|
  s.name     = 'AFHTTPClientLogger'
  s.version  = '0.6.0'
  s.license  = 'MIT'
  s.authors  = { 'Jon Parise' => 'jon@indelible.org' }
  s.summary  = 'AFNetworking Extension for request logging.'
  s.homepage = 'https://github.com/jparise/AFHTTPClientLogger'
  s.source   = { :git => 'https://github.com/jparise/AFHTTPClientLogger.git', :tag => s.version }
  s.requires_arc = true

  s.source_files = 'AFHTTPClientLogger.{h,m}'

  s.ios.deployment_target = '6.0'
end
