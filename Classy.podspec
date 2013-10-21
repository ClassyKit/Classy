Pod::Spec.new do |s|
  s.name     = 'Classy'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'Classy style sheets for UIView and friends'
  s.homepage = 'https://github.com/cloudkite/Classy'
  s.author   = { 'Jonas Budelmann' => 'jonas.budelmann@gmail.com' }

  s.source   = { :git => 'https://github.com/cloudkite/Classy.git', :tag => 'v0.0.1' }

  s.description = %{
    Elegant style sheets your iOS app.
  }

  s.source_files = 'Classy/**/*.{h,m}'

  s.ios.frameworks = 'Foundation', 'UIKit', 'QuartzCore'

  s.ios.deployment_target = '6.0'
  s.requires_arc = true
end
