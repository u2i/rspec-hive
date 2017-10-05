# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/hive/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-hive'
  spec.version       = RSpec::Hive::VERSION
  spec.authors       = ['Wojtek Mielczarek', 'Mikołaj Nowak']
  spec.email         = %w[wojtek.mielczarek@u2i.com mikolaj.nowak@u2i.com]
  spec.summary       = 'RSpec addition to test hive queries'
  spec.description   = 'RSpecHive let you test your hive queries
                        connecting to hive instance installed on docker'
  spec.homepage      = 'https://github.com/u2i/ns-rspec-hive'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rake', ['>= 10.0', '< 12.0']
  spec.add_dependency 'colorize', '~> 0.7'
  spec.add_dependency 'faker', '~> 1.6'
  spec.add_dependency 'retryable', '~> 2.0.3'
  spec.add_dependency 'rspec', '~> 3.4'
  spec.add_dependency 'rbhive-u2i', '~> 1.0.0'
end
