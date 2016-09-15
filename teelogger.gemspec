# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'teelogger/version'

Gem::Specification.new do |spec|
  spec.name          = "teelogger"
  spec.version       = TeeLogger::VERSION
  spec.authors       = ["Jens Finkhaeuser"]
  spec.email         = ["foss@spritecloud.com"]
  spec.summary       = "Mini wrapper around Ruby Logger for logging to "\
                       "multiple destinations."
  spec.description   = "Mini wrapper around Ruby Logger for logging to "\
                       "multiple destinations. Adds filtering and other "\
                       "extensions."
  spec.homepage      = "https://github.com/spriteCloud/teelogger"
  spec.license       = "MITNFA"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rubocop", "~> 0.42"
  spec.add_development_dependency "rake", "~> 11.1"
  spec.add_development_dependency "cucumber", "~> 2"
  spec.add_development_dependency "simplecov", "~> 0.12"

  spec.add_dependency "tai64", "~> 0.0"
  spec.add_dependency "require_all", "~> 1.3"
end
