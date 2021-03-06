# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'awsssh/version'

Gem::Specification.new do |spec|
  spec.name          = "awsssh"
  spec.version       = Awsssh::VERSION
  spec.author        = "Sebastian Thiele"
  spec.email         = %w(Sebastian.Thiele infopark.de).join('@')
  spec.summary       = "Connects you with OpsWorks EC2"
  spec.description   = "This will connects you with an EC2 instace"
  spec.homepage      = "https://github.com/sethiele/awsssh"
  spec.metadata      = { "issue_tracker" => "https://github.com/sethiele/awsssh/issues" }
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "inifile", "~> 3.0.0", ">= 3.0.0"
  spec.add_runtime_dependency "aws-sdk", "~> 2.2.0", ">= 2.2.0"
  spec.add_runtime_dependency "thor", "~> 0.19.1", ">= 0.19.1"
  spec.add_runtime_dependency "colorize", "~> 0.7.7"
end
