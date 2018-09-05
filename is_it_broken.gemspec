# coding: utf-8
# frozen_string_literal: true

# TODO update me

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "is_it_broken"
  spec.version       = File.read(File.expand_path("../VERSION", __FILE__)).chomp
  spec.authors       = ["Brian Durand", "Winston Durand"]
  spec.email         = ["bbdurand@gmail.com"]
  spec.summary       = "Framework for registering monitoring checks that can be activated from a web request or the command line"
  spec.description   = "Framework for registering monitoring/health checks for an application that can be activated from a web request or the command line."
  spec.homepage      = "https://github.com/bdurand/is_it_broken"
  spec.license       = "MIT"
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>=2.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
end
