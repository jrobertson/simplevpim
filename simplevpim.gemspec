Gem::Specification.new do |s|
  s.name = 'simplevpim'
  s.version = '0.4.0'
  s.summary = 'A simple wrapper for the vPim gem'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*']
  s.add_runtime_dependency('simple-config', '~> 0.1', '>=0.1.13')
  s.add_runtime_dependency('vpim', '~> 13.11', '>=13.11.11')
  s.add_runtime_dependency('rexle-builder', '~> 0.1', '>=0.1.10') 
  s.add_runtime_dependency('nokogiri', '~> 1.6', '>=1.6.2.1')
  s.add_runtime_dependency('hlt', '~> 0.3', '>=0.3.2') 
  s.signing_key = '../privatekeys/simplevpim.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/simplevpim'
end
