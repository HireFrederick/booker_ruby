# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'booker/version'

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.1.0'

  s.name          = 'booker_ruby'
  s.version       = Booker::VERSION
  s.authors     = ['Frederick']
  s.email       = ['friends@hirefrederick.com']
  s.homepage    = 'https://github.com/hirefrederick/booker_ruby'
  s.summary       = %q{
    Ruby client for the Booker v4 API - http://apidoc.booker.com
  }
  s.license       = 'MIT'
  s.files       = Dir['{lib}/**/*', 'MIT-LICENSE', 'README.rdoc']

  s.add_dependency 'httparty', '~> 0.13.1'
  s.add_dependency 'activesupport', '>= 3.0.0'
  s.add_dependency 'oj', '~> 2.10'

  s.add_development_dependency 'bundler', '~> 1.10'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'shoulda-matchers', '~> 2.8.0'
  s.add_development_dependency 'timecop', '>= 0.7.0'
end
