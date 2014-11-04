Gem::Specification.new do |s|
  s.name = 'simplevpim'
  s.version = '0.1.1'
  s.summary = 'A simple wrapper for the vPim gem'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_runtime_dependency('line-tree', '~> 0.1', '>=0.1.7')
  s.add_runtime_dependency('vpim', '~> 13.11', '>=13.11.11')
  s.signing_key = '../privatekeys/simplevpim.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/simplevpim'
end
