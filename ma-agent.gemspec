# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "ma-agent"
  spec.version       = "0.1"
  spec.authors       = ["Mingqi Shao"]
  spec.email         = ["shaomq@gmail.com"]
  spec.summary       = %q{mygod tools}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_dependency "ruby-mysql"
  spec.add_dependency "rest-client"
  spec.add_dependency "daemons"
  spec.add_dependency "fluent"
end
