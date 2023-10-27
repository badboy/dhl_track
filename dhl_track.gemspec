require_relative 'lib/dhl_track/version'

Gem::Specification.new do |spec|
  spec.name          = "dhl_track"
  spec.version       = DhlTrack::VERSION
  spec.authors       = ["Jan-Erik Rediger"]
  spec.email         = ["janerik@fnordig.de"]

  spec.summary       = %q{API client for the new (early access) DHL API.}
  spec.description   = %q{API client for the new (early access) DHL API.}
  spec.homepage      = "https://github.com/badboy/dhl_track"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 1.0.1"
  spec.add_dependency "faraday_middleware", "~> 1.0.0"
  spec.add_dependency "rash_alt", "~> 0.4.8"
  spec.add_dependency "nokogiri", ">= 1.10", "< 2.0"
end
