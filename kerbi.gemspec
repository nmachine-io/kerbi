
Gem::Specification.new do |s|
  s.name          = 'kerbi'
  s.version       = '1.1.47'
  s.date          = '2020-04-19'
  s.summary       = "Multi-strategy Kubernetes manifest templating engine."
  s.description   = "Kerbi is a multi-strategy Kubernetes manifest templating engine."
  s.authors       = ["Xavier Millot"]
  s.email         = 'xavier@nmachine.io'
  s.homepage      = 'https://nmachine-io.github.io/kerbi'
  s.license       = 'MIT'
  s.files         = Dir["{bin,lib,boilerplate}/**/*"]
  s.test_files    = Dir["spec/**/*"]
  s.bindir        = 'bin'
  s.executables   = ['kerbi']
end