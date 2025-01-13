# frozen_string_literal: true

module Faraday
  module ResponseBodySizeLimit
    class LimitExceededError < StandardError; end

    class Middleware < Faraday::Middleware
      def initialize(app, max_size_bytes:)
        super(app)

        @max_size_bytes = max_size_bytes
      end

      def call(env) # rubocop:disable Metrics/MethodLength
        response_body_size = 0
        accumulated_body   = + ""

        env.request.on_data = proc do |chunk, _|
          response_body_size += chunk.bytesize
          accumulated_body   << chunk

          if response_body_size > @max_size_bytes
            raise LimitExceededError,
                  "Response body too large, exceeced the configured max size of #{@max_size_bytes} bytes."
          end
        end

        @app.call(env).on_complete do |response_env|
          response_env.body = accumulated_body
        end
      end
    end
  end
end

Faraday::Response.register_middleware(
  response_body_size_limit: Faraday::ResponseBodySizeLimit::Middleware
)
