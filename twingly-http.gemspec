# frozen_string_literal: true

require_relative "lib/twingly/version"

Gem::Specification.new do |s|
  s.name        = "twingly-http"
  s.version     = Twingly::HTTP::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Twingly AB"]
  s.email       = ["support@twingly.com"]
  s.homepage    = "http://github.com/twingly/twingly-http"
  s.summary     = "Robust HTTP client"
  s.description = "Robust HTTP client tailored by Twingly"
  s.license     = "MIT"
  s.required_ruby_version = "~> 2.5"

  s.add_dependency "faraday", "~> 1.0.1"
  s.add_dependency "faraday_middleware", "~> 1.0.0"

  s.add_development_dependency "climate_control", "~> 0.1"
  s.add_development_dependency "rake", "~> 12"
  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "rubocop", "~> 0.77.0"
  s.add_development_dependency "rubocop-rspec", "~> 1.36"
  s.add_development_dependency "toxiproxy", "~> 1.0"
  s.add_development_dependency "vcr", "~> 5.0"
  s.add_development_dependency "webmock", "~> 3.7"

  s.files        = Dir.glob("{lib}/**/*") + %w(README.md LICENSE)
  s.require_path = "lib"
end
