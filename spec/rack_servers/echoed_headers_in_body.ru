# frozen_string_literal: true

require "json"

run lambda { |env|
  request_headers = env.select { |k, _v| k.start_with? "HTTP_" }

  [200, { "content-type" => "application/json" }, [request_headers.to_json]]
}
