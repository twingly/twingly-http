# frozen_string_literal: true

require "forwardable"

module Faraday
  module LogfmtLogger
    class Middleware < Response::Middleware
      extend Forwardable

      DEFAULT_OPTIONS = { headers: true, bodies: false }.freeze

      def initialize(app, logger = nil, options = {})
        super(app)
        @logger = logger || begin
          require "logger"
          ::Logger.new($stdout)
        end

        @filter = []
        @options = DEFAULT_OPTIONS.merge(options)
        yield self if block_given?
      end

      def_delegators :@logger, :debug, :info, :warn, :error, :fatal

      def call(env)
        info("request") do
          log_entry = {
            source: "upstream-request",
            method: env.method.upcase,
            url: apply_filters(env.url.to_s),
            request_id: request_id,
          }.merge(app_metadata)

          Twingly::StringUtilities.logfmt(log_entry)
        end
        debug_log_request(env)
        super
      end

      def on_complete(env)
        info("response") do
          log_entry = {
            source: "upstream-response",
            status: env.status,
            request_id: request_id,
          }.merge(app_metadata)

          Twingly::StringUtilities.logfmt(log_entry)
        end
        debug_log_response(env)
      end

      # Disable Rubocop here to keep the code look the same where it came from:
      # https://github.com/lostisland/faraday/blob/v0.11.0/lib/faraday/response/logger.rb

      # rubocop:disable all
      def filter(filter_word, filter_replacement)
        @filter.push([ filter_word, filter_replacement ])
      end
      # rubocop:enable all

      private

      def request_id
        @options[:request_id]
      end

      def app_metadata
        {
          release: Twingly::HTTP::Heroku.release_version,
        }
      end

      # rubocop:disable all
      def debug_log_request(env)
        debug('request') { apply_filters( dump_headers env.request_headers ) } if log_headers?(:request)
        debug('request') { apply_filters( dump_body(env[:body]) ) } if env[:body] && log_body?(:request)
      end

      def debug_log_response(env)
        debug('response') { apply_filters( dump_headers env.response_headers ) } if log_headers?(:response)
        debug('response') { apply_filters( dump_body env[:body] ) } if env[:body] && log_body?(:response)
      end

      def dump_headers(headers)
        headers.map { |k, v| "#{k}: #{v.inspect}" }.join("\n")
      end

      def dump_body(body)
        if body.respond_to?(:to_str)
          body.to_str
        else
          pretty_inspect(body)
        end
      end

      def pretty_inspect(body)
        require 'pp' unless body.respond_to?(:pretty_inspect)
        body.pretty_inspect
      end

      def log_headers?(type)
        case @options[:headers]
        when Hash then @options[:headers][type]
        else @options[:headers]
        end
      end

      def log_body?(type)
        case @options[:bodies]
        when Hash then @options[:bodies][type]
        else @options[:bodies]
        end
      end

      def apply_filters(output)
        @filter.each do |pattern, replacement|
          output = output.to_s.gsub(pattern, replacement)
        end
        output
      end
      # rubocop:enable all
    end
  end
end

Faraday::Response.register_middleware(
  logfmt_logger: Faraday::LogfmtLogger::Middleware
)
