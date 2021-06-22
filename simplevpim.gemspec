Gem::Specification.new do |s|
  s.name = 'simplevpim'
  s.version = '0.5.2'
  s.summary = 'A simple wrapper for the vPim gem'
  s.authors = ['James Robertson']
  s.files = Dir['lib/simplevpim.rb']
  s.add_runtime_dependency('hlt', '~> 0.6', '>=0.6.3')   
  s.add_runtime_dependency('vpim', '~> 13.11', '>=13.11.11')
  s.add_runtime_dependency('unichron', '~> 0.3', '>=0.3.7')
  s.add_runtime_dependency('rexle-builder', '~> 1.0', '>=1.0.3') 
  s.signing_key = '../privatekeys/simplevpim.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/simplevpim'
end
