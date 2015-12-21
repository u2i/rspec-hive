# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hive_tests/version'

Gem::Specification.new do |spec|
  spec.name          = "hive_tests"
  spec.version       = HiveTests::VERSION
  spec.authors       = ["Wojtek Mielczarek"]
  spec.email         = ["wojtek.mielczarek@u2i.com"]
  spec.summary       = 'Tool to test hive queries'
  spec.description   = 'This tool helps you run hive queries'
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rbhive', '~> 0.6.0'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
end
