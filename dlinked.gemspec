
# frozen_string_literal: true
require_relative "lib/d_linked/version"

Gem::Specification.new do |spec|
  spec.name          = "dlinked"
  spec.version       = DLinked::VERSION
  # spec.version       = File.read(File.expand_path("lib/d_linked/version.rb")).scan(/VERSION = "([^"]+)"/).flatten.first
  spec.authors       = ["Daniele Frisanco"]
  spec.email         = ["daniele.frisanco@gmail.com"]
  
  spec.summary       = "A highly performant Doubly Linked List implementation for Ruby."
  spec.description   = "Provides a native Doubly Linked List data structure in Ruby, focusing on O(1) performance for head/tail operations and standard Enumerable compatibility."
  spec.homepage      = "https://github.com/danielefrisanco/dlinked"
  spec.license       = "MIT"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://github.com/danielefrisanco/dlinked'
  spec.metadata["bug_tracker_uri"] = 'https://github.com/danielefrisanco/dlinked/issues'
  spec.metadata["documentation_uri"] = 'https://danielefrisanco.github.io/dlinked/'
  spec.metadata["changelog_uri"] = 'https://github.com/danielefrisanco/dlinked/blob/main/CHANGELOG.md'
  spec.required_ruby_version = ">= 2.7.0"
  
  # --- Files to Include in the Gem ---
  
  # Ensure all necessary files are included in the built gem
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|benchmark)/}) }
  end
  
  # Pin the main file that gets loaded when someone 'require's the gem
  spec.require_paths = ["lib"]
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake",    "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "rubocop-minitest", "~> 0.16.0"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "benchmark-ips", "~> 2.8"
end