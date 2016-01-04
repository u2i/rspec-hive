# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hive_tests/version'

Gem::Specification.new do |spec|
  spec.name          = 'hive_tests'
  spec.version       = HiveTests::VERSION
  spec.authors       = ['Wojtek Mielczarek', 'Mikołaj Nowak']
  spec.email         = %w(wojtek.mielczarek@u2i.com mikolaj.nowak@u2i.com)
  spec.summary       = 'RSpec addition to test hive queries'
  spec.description   = 'HiveTests let you test your hive queries
                        connecting to hive instance installed on docker'
  spec.homepage      = 'https://github.com/u2i/ns-rspec-hive'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rake', '~> 10.0'
  spec.add_dependency 'colorize', '~> 0.7'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'rbhive', '~> 0.6.0'
  spec.add_development_dependency 'rubocop', '~> 0.34'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.3'
  spec.add_development_dependency 'guard', '~> 2.6'
  spec.add_development_dependency 'guard-rspec', '~> 4.3'
  spec.add_development_dependency 'guard-rubocop', '~> 1.2'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.4'
end
