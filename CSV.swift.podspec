Pod::Spec.new do |s|
  s.name = 'CSV.swift'
  s.version = '2.2.1'
  s.license = 'MIT'
  s.summary = 'CSV reading and writing library written in Swift.'
  s.homepage = 'https://github.com/yaslab/CSV.swift'
  s.authors = { 'Yasuhiro Hatta' => 'hatta.yasuhiro@gmail.com' }
  s.source = { :git => 'https://github.com/yaslab/CSV.swift.git', :tag => s.version }

  s.osx.deployment_target = '10.9'
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.module_name = 'CSV'
  s.source_files = 'Sources/CSV/*.swift'
end
