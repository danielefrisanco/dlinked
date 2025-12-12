Gem::Specification.new do |spec|
  spec.name          = "dlinked"
  spec.version       = "0.1.0"
  spec.authors       = ["Daniele Frisanco"]
  spec.email         = ["daniele.frisanco@gmail.com"]

  spec.summary       = "A fast, lightweight doubly linked list implementation"
  spec.description   = "High-performance doubly linked list with O(1) operations for insertion and deletion"
  spec.homepage      = "https://github.com/danielefrisanco/dlinked"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.files         = Dir["lib/**/*.rb", "README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]
end