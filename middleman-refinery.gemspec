# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman-refinery/version'

Gem::Specification.new do |spec|
  spec.name          = "middleman-refinery"
  spec.version       = MiddlemanRefinery::VERSION
  spec.authors       = ["Brice Sanchez", "Filippos Vasilakis"]

  spec.summary       = %q{Middleman extension for Refinery CMS}
  spec.description   = %q{Middleman extension for Refinery CMS}
  spec.homepage      = "https://github.com/refinerycms-contrib/middleman-refinery"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "middleman", "~> 4.1"
  spec.add_dependency "middleman-core", "~> 4.1"
  spec.add_dependency "refinerycms-api-wrapper", "~> 1.0.0.beta"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 13.0"
end
