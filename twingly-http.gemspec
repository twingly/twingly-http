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
  s.required_ruby_version = ">= 2.5"

  s.add_dependency "faraday", "~> 1", ">= 1.0.1"
  s.add_dependency "faraday_middleware", "~> 1.0.0"

  s.files        = Dir.glob("{lib}/**/*") + %w(README.md LICENSE)
  s.require_path = "lib"
  s.metadata["rubygems_mfa_required"] = "true"
end
