# frozen_string_literal: true

require "rack/proxy"

class TestProxy < Rack::Proxy
  def rewrite_env(env)
    env["HTTP_X_PROXIED_BY"] = "test-proxy"
    env
  end
end

run TestProxy.new
