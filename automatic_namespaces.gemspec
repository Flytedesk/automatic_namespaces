# frozen_string_literal: true

require_relative "lib/automatic_namespaces/version"

Gem::Specification.new do |spec|
  spec.name = "automatic_namespaces"
  spec.version = AutomaticNamespaces::VERSION
  spec.authors = ["Gary Passero"]
  spec.email = ["gpassero@gmail.com"]
  spec.summary = "Modify autoloading to assume all files within a directory belong in a namespace"
  spec.homepage = "https://github.com/gap777/automatic_namespaces"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/gap777/automatic_namespaces"
    spec.metadata["changelog_uri"] = "https://github.com/gap777/automatic_namespaces/releases"
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
          "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["README.md", "lib/**/*"]

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_dependency "activesupport"
  spec.add_dependency "packs-rails"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "debug"

  # We need this in test to load our test fixture Rails application, which represents the "client" of stimpack
  spec.add_development_dependency "rails"
end
