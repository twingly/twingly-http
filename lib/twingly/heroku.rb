# frozen_string_literal: true

module Twingly
  module HTTP
    class Heroku
      def self.app_name
        ENV.fetch("HEROKU_APP_NAME") { "unknown_heroku_app_name" }
      end

      def self.dyno_id
        ENV.fetch("HEROKU_DYNO_ID") { "unknown_heroku_dyno_id" }
      end

      def self.slug_commit
        ENV.fetch("HEROKU_SLUG_COMMIT") { "unknown_heroku_slug_commit" }
      end

      def self.release_version
        ENV.fetch("HEROKU_RELEASE_VERSION") { "unknown_heroku_release_version" }
      end

      def self.review_app?
        parent_name = ENV.fetch("HEROKU_PARENT_APP_NAME") {}

        return false unless parent_name

        app_name               = ENV.fetch("HEROKU_APP_NAME") { "" }
        review_app_name_format = /\A#{parent_name}-pr-\d+\z/

        review_app_name_format.match?(app_name)
      end
    end
  end
end
