# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'awsssh/version'

Gem::Specification.new do |spec|
  spec.name          = "awsssh"
  spec.version       = Awsssh::VERSION
  spec.authors       = ["Sebastian Thiele"]
  spec.email         = [%w(Sebastian.Thiele infopark.de).join('@')]
  spec.summary       = "Connects you with OpsWorks EC2"
  spec.description   = "This will connects you with an EC2 instace"
  spec.homepage      = "https://github.com/sethiele/awsssh"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8.3"
  spec.add_development_dependency "rake", "~> 10.4.2"
  spec.add_development_dependency "pry", "~> 0.10.1"
  spec.add_development_dependency "rspec", "~> 2.6"

  spec.add_runtime_dependency "net-ssh", "2.7.0"
  spec.add_runtime_dependency "inifile", "2.0.2"
  spec.add_runtime_dependency "aws-sdk", "1.35.0"
  spec.add_runtime_dependency "thor", "0.18.1"
end
