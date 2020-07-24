# frozen_string_literal: true

require_relative "lib/is_it_broken/version"

Gem::Specification.new do |spec|
  spec.name = "is_it_broken"
  spec.version = IsItBroken::VERSION
  spec.authors = ["Brian Durand", "Winston Durand"]
  spec.email = ["bbdurand@gmail.com", "me@winstondurand.com"]

  spec.summary = "Framework for registering monitoring checks that can be activated from a web request or the command line to check the health of an application."
  spec.homepage = "https://github.com/bdurand/is_it_broken"
  spec.license = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  ignore_files = %w[
    .gitignore
    .travis.yml
    Appraisals
    Gemfile
    Gemfile.lock
    Rakefile
    gemfiles/
    spec/
  ]
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| ignore_files.any? { |path| f.start_with?(path) } }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">=2.2"

  spec.add_development_dependency "bundler"
end
