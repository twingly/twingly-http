# frozen_string_literal: true

module Faraday
  module UrlSizeLimit
    class LimitExceededError < StandardError; end

    class Middleware < Faraday::Middleware
      def initialize(app, max_size_bytes:)
        super(app)

        @max_size_bytes = max_size_bytes
      end

      def call(env)
        url_bytesize = env.url.to_s.bytesize

        if url_bytesize >= @max_size_bytes
          raise LimitExceededError,
                "Expected URL below #{@max_size_bytes} bytes, "\
                "was #{url_bytesize} bytes"
        end

        @app.call(env)
      end
    end
  end
end

Faraday::Request.register_middleware(
  url_size_limit: Faraday::UrlSizeLimit::Middleware
)
