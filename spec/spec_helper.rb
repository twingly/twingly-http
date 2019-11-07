# frozen_string_literal: true

# rspec adds lib to $LOAD_PATH, remove it to catch bad requires
# from https://github.com/rspec/rspec-core/issues/1983#issuecomment-108748690
$LOAD_PATH.delete_if { |p| File.expand_path(p) == File.expand_path("./lib") }

require "rspec"
require "toxiproxy"
require "vcr"
require "webmock/rspec"

require_relative "../lib/twingly/http"

require_relative "spec_help/env_helper"
require_relative "spec_help/fixture"
require_relative "spec_help/null_logger"
require_relative "spec_help/test_logger"
require_relative "spec_help/toxiproxy_config"

# Start with a clean slate, destroy all proxies if any
Toxiproxy.all.destroy
Toxiproxy.populate(ToxiproxyConfig.proxies)

VCR.configure do |conf|
  conf.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  conf.hook_into :webmock
  conf.configure_rspec_metadata!

  conf.ignore_request do |request|
    request.uri.start_with?("http://127.0.0.1:8474/") # toxiproxy-server
  end
end

RSpec.configure do |conf|
  include EnvHelper

  conf.after(:suite) do
    Toxiproxy.all.destroy # Be nice, end with a clean slate
  end

  conf.expect_with(:rspec) do |expectations|
    expectations.max_formatted_output_length = nil
  end

  conf.mock_with(:rspec) do |mocks|
    mocks.verify_doubled_constant_names = true
  end

  conf.disable_monkey_patching!

  conf.filter_run_when_matching :focus

  conf.warnings = true
  conf.order = :random

  Kernel.srand conf.seed
end
