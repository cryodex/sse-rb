$:.push File.expand_path('../lib', __FILE__)
require 'sse/version'

Gem::Specification.new do |s|
  
  s.name        = 'sse'
  s.version     = SSE::VERSION
  s.authors     = ['Louis Mullie']
  s.email       = ['louis.mullie@gmail.com']
  s.homepage    = 'https://github.com/louismullie/sse'
  s.summary     = %q{ Ruby implementation of symmetric searchable encryption }
  s.description = %q{ Ruby implementation of a symmetric searchable encryption scheme by Song et al. }

  s.files = Dir.glob('lib/**/*.rb') +
  Dir.glob('ext/**/*.{c,h,rb}')

  s.extensions << 'ext/sse/extconf.rb'
  
  s.add_runtime_dependency 'siv'
  
  s.add_development_dependency 'rspec', '~> 2.12.0'
  s.add_development_dependency 'rake'
  
end
