
Gem::Specification.new do |s|
  s.name          = 'kerbi'
  s.version       = '0.0.12'

  s.summary       = "Multi-strategy Kubernetes manifest templating engine."
  s.description   = "Kerbi is a multi-strategy Kubernetes manifest templating engine."
  s.authors       = ["Xavier Millot"]
  s.email         = 'xavier@nmachine.io'
  s.homepage      = 'https://nmachine-io.github.io/kerbi'
  s.license       = 'MIT'

  s.files         = Dir["{bin,lib}/**/*"]
  s.test_files    = Dir["spec/**/*"]
  s.bindir        = 'bin'
  s.executables   = ['kerbi']

  s.required_ruby_version = '>= 2.6.3'

  s.add_dependency 'http', "~>4.4", ">=4.4.1"
  s.add_dependency 'activesupport', "~>6.0", ">=6.0.3.2"
  s.add_dependency 'thor', "~>1.1", ">=1.1.0"
  s.add_dependency 'colorize', "~>0.8", ">=0.8.1"
  s.add_dependency "kubeclient", "~>4.9", ">=4.9.1"
end