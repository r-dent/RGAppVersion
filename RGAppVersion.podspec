Pod::Spec.new do |s|
  s.name         = 'RGAppVersion'
  s.version      = '1.0.1'
  s.description  = 'Simple class for accessing the iOS app version and track app updates.'
  s.summary      = 'Simple helper class for app versions.'
  s.homepage     = 'https://github.com/r-dent/RGAppVersion'
  s.author       = { 'Roman Gille' => 'developer@romangille.com' }
  s.source       = { :git => 'https://github.com/r-dent/RGAppVersion.git', :tag => "v#{s.version}" }
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.platform     = :ios, '7.0'

  s.source_files = 'Sources/*.swift'
  s.requires_arc = true

  s.frameworks = 'Foundation'

  s.ios.deployment_target = '8'
end