Pod::Spec.new do |spec|
  spec.name         = 'CSV.swift'
  spec.version      = '2.5.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/yaslab/CSV.swift'
  spec.authors      = { 'Yasuhiro Hatta' => 'hatta.yasuhiro@gmail.com' }
  spec.summary      = 'CSV reading and writing library written in Swift.'
  spec.source       = { :git => 'https://github.com/yaslab/CSV.swift.git', :tag => spec.version }
  spec.source_files = 'Sources/CSV/*.swift'

  spec.ios.deployment_target     = '12.0'
  spec.tvos.deployment_target    = '12.0'
  spec.watchos.deployment_target = '4.0'
  spec.osx.deployment_target     = '10.13'

  spec.module_name   = 'CSV'
  spec.swift_version = '5.4'
end
