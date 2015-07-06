# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'teelogger/version'

Gem::Specification.new do |spec|
  spec.name          = "teelogger"
  spec.version       = TeeLogger::VERSION
  spec.authors       = ["Jens Finkhaeuser"]
  spec.email         = ["foss@spritecloud.com"]
  spec.summary       = %q{Mini wrapper around Ruby Logger for logging to multiple destinations.}
  spec.description   = %q{Mini wrapper around Ruby Logger for logging to multiple destinations.}
  spec.homepage      = "https://github.com/spriteCloud/teelogger"
  spec.license       = "MITNFA"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "cucumber"

  spec.add_dependency "tai64", "~> 0.0"
  spec.add_dependency "require_all", "~> 1.3"
end
