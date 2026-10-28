# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'booker/version'

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.3.10'

  s.name          = 'booker_ruby'
  s.version       = Booker::VERSION
  s.authors     = ['Frederick']
  s.email       = ['tech@hirefrederick.com']
  s.homepage    = 'https://github.com/hirefrederick/booker_ruby'
  s.summary       = %q{
    Ruby client for the Booker API - https://developers.booker.com
  }
  s.license       = 'MIT'
  s.files       = Dir['{lib}/**/*', 'MIT-LICENSE']

  s.add_dependency 'httparty', '>= 0.14'
  s.add_dependency 'activesupport', '>= 6.1.7.10', '< 7.0'
  s.add_dependency 'oj'
  s.add_dependency 'jwt', '>= 1.5', '<= 2.5'

  s.add_development_dependency 'bundler', '>= 2.4', '< 3.0'
  s.add_development_dependency 'rspec', '~> 3.13'
  s.add_development_dependency 'shoulda-matchers', '~> 4.0'
  s.add_development_dependency 'timecop', '>= 0.7.0'
  s.add_development_dependency 'carmen', '~> 1.0.2'
end
