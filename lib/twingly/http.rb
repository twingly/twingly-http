# frozen_string_literal: true

require "logger"
require "net/http"
require "faraday"
require "faraday_middleware"

require_relative "../faraday/logfmt_logger"
require_relative "../faraday/url_size_limit"
require_relative "../faraday/response_body_size_limit"
require_relative "heroku"
require_relative "string_utilities"

module Twingly
  module HTTP
    class ConnectionError < StandardError; end
    class UrlSizeLimitExceededError < StandardError; end
    class RedirectLimitReachedError < StandardError; end
    class ResponseBodySizeLimitExceededError < StandardError; end
    class Client # rubocop:disable Metrics/ClassLength
      DEFAULT_RETRYABLE_EXCEPTIONS = [
        Faraday::ConnectionFailed,
        Faraday::SSLError,
        Zlib::BufError,
        Zlib::DataError,
      ].freeze
      TIMEOUT_EXCEPTIONS = [
        Faraday::TimeoutError,
        Net::OpenTimeout,
      ].freeze
      DEFAULT_HTTP_TIMEOUT = 20
      DEFAULT_HTTP_OPEN_TIMEOUT = 10
      DEFAULT_NUMBER_OF_RETRIES = 0
      DEFAULT_RETRY_INTERVAL = 1
      DEFAULT_MAX_URL_SIZE_BYTES = Float::INFINITY
      DEFAULT_MAX_RESPONSE_BODY_SIZE_BYTES = Float::INFINITY
      DEFAULT_FOLLOW_REDIRECTS_LIMIT = 3

      attr_writer :http_timeout
      attr_writer :http_open_timeout
      attr_writer :number_of_retries
      attr_writer :retry_interval
      attr_writer :on_retry_callback
      attr_writer :max_url_size_bytes
      attr_writer :max_response_body_size_bytes
      attr_writer :request_id
      attr_writer :follow_redirects

      attr_accessor :follow_redirects_limit
      attr_accessor :logger
      attr_accessor :retryable_exceptions

      def initialize(base_user_agent:, logger: default_logger, user_agent: nil)
        @base_user_agent = base_user_agent
        @logger          = logger
        @user_agent      = user_agent

        initialize_defaults
      end

      def get(url, params: {}, headers: {})
        http_response_for(:get, url: url, params: params, headers: headers)
      end

      def post(url, body:, headers: {})
        http_response_for(:post, url: url, body: body, headers: headers)
      end

      def put(url, body:, headers: {})
        http_response_for(:put, url: url, body: body, headers: headers)
      end

      def patch(url, body:, headers: {})
        http_response_for(:patch, url: url, body: body, headers: headers)
      end

      def delete(url, params: {}, headers: {})
        http_response_for(:delete, url: url, params: params, headers: headers)
      end

      private

      def default_logger
        Logger.new(File::NULL)
      end

      def initialize_defaults
        @request_id                   = nil
        @http_timeout                 = DEFAULT_HTTP_TIMEOUT
        @http_open_timeout            = DEFAULT_HTTP_OPEN_TIMEOUT
        @retryable_exceptions         = DEFAULT_RETRYABLE_EXCEPTIONS
        @number_of_retries            = DEFAULT_NUMBER_OF_RETRIES
        @retry_interval               = DEFAULT_RETRY_INTERVAL
        @on_retry_callback            = nil
        @follow_redirects             = false
        @follow_redirects_limit       = DEFAULT_FOLLOW_REDIRECTS_LIMIT
        @max_url_size_bytes           = DEFAULT_MAX_URL_SIZE_BYTES
        @max_response_body_size_bytes = DEFAULT_MAX_RESPONSE_BODY_SIZE_BYTES
      end

      def http_response_for(method, **args) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        response = send("http_#{method}_response", **args)

        Response.new(headers: response.headers.to_h,
                     status: response.status,
                     body: response.body,
                     final_url: response.env.url.to_s)
      rescue *(@retryable_exceptions + TIMEOUT_EXCEPTIONS)
        raise ConnectionError
      rescue Faraday::UrlSizeLimit::LimitExceededError => error
        raise UrlSizeLimitExceededError, error.message
      rescue FaradayMiddleware::RedirectLimitReached => error
        raise RedirectLimitReachedError, error.message
      rescue Faraday::ResponseBodySizeLimit::LimitExceededError => error
        raise ResponseBodySizeLimitExceededError, error.message
      end

      def http_get_response(url:, params:, headers:)
        binary_url = url.dup.force_encoding(Encoding::BINARY)
        http_client = create_http_client

        headers = default_headers.merge(headers)

        http_client.get do |request|
          request.url(binary_url)
          request.params.merge!(params)
          request.headers.merge!(headers)
          request.options.timeout = @http_timeout
          request.options.open_timeout = @http_open_timeout
        end
      end

      def http_post_response(url:, body:, headers:)
        binary_url = url.dup.force_encoding(Encoding::BINARY)
        http_client = create_http_client

        headers = default_headers.merge(headers)

        http_client.post do |request|
          request.url(binary_url)
          request.headers.merge!(headers)
          request.body = body
          request.options.timeout = @http_timeout
          request.options.open_timeout = @http_open_timeout
        end
      end

      def http_put_response(url:, body:, headers:)
        binary_url = url.dup.force_encoding(Encoding::BINARY)
        http_client = create_http_client

        headers = default_headers.merge(headers)

        http_client.put do |request|
          request.url(binary_url)
          request.headers.merge!(headers)
          request.body = body
          request.options.timeout = @http_timeout
          request.options.open_timeout = @http_open_timeout
        end
      end

      def http_patch_response(url:, body:, headers:)
        binary_url = url.dup.force_encoding(Encoding::BINARY)
        http_client = create_http_client

        headers = default_headers.merge(headers)

        http_client.patch do |request|
          request.url(binary_url)
          request.headers.merge!(headers)
          request.body = body
          request.options.timeout = @http_timeout
          request.options.open_timeout = @http_open_timeout
        end
      end

      def http_delete_response(url:, params:, headers:)
        binary_url = url.dup.force_encoding(Encoding::BINARY)
        http_client = create_http_client

        headers = default_headers.merge(headers)

        http_client.delete do |request|
          request.url(binary_url)
          request.params.merge!(params)
          request.headers.merge!(headers)
          request.options.timeout = @http_timeout
          request.options.open_timeout = @http_open_timeout
        end
      end

      def create_http_client # rubocop:disable Metrics/MethodLength
        Faraday.new do |faraday|
          faraday.request :url_size_limit,
                          max_size_bytes: @max_url_size_bytes
          faraday.request :retry,
                          max: @number_of_retries,
                          interval: @retry_interval,
                          exceptions: @retryable_exceptions,
                          methods: [], # empty [] forces Faraday to run retry_if
                          retry_if: retry_if
          faraday.response :logfmt_logger, @logger.dup,
                           headers: true,
                           bodies: true,
                           request_id: @request_id
          if @follow_redirects
            faraday.use FaradayMiddleware::FollowRedirects,
                        limit: @follow_redirects_limit
          end
          faraday.response :response_body_size_limit,
                           max_size_bytes: @max_response_body_size_bytes
          faraday.adapter Faraday.default_adapter
          faraday.headers[:user_agent] = user_agent
        end
      end

      def retry_if
        lambda do |env, exception|
          unwrapped_exception = unwrap_exception(exception)

          # we do not retry on timeouts due to our request time budget
          if timeout_error?(unwrapped_exception)
            false
          else
            @on_retry_callback&.call(env, unwrapped_exception)
            true
          end
        end
      end

      def unwrap_exception(exception)
        if exception.respond_to?(:wrapped_exception)
          exception.wrapped_exception
        else
          exception
        end
      end

      def timeout_error?(error)
        TIMEOUT_EXCEPTIONS.include?(error.class)
      end

      def user_agent
        @user_agent || format(
          "%<base>s (Release/%<release>s; Commit/%<commit>s)",
          base: @base_user_agent,
          release: Heroku.release_version,
          commit: Heroku.slug_commit
        )
      end

      def app_metadata
        {
          dyno_id: Heroku.dyno_id,
          release: Heroku.release_version,
          git_head: Heroku.slug_commit,
        }
      end

      def default_headers
        {
          "X-Request-Id": @request_id,
        }.delete_if { |_name, value| value.to_s.strip.empty? }
      end
    end

    class Response
      attr_reader :headers
      attr_reader :status
      attr_reader :body
      attr_reader :final_url

      def initialize(headers: nil,
                     status: nil,
                     body: nil,
                     final_url: nil)
        @headers       = headers
        @status        = status
        @body          = body
        @final_url     = final_url
      end
    end
  end
end
