# frozen_string_literal: true

require "logger"

class TestLogger
  def self.logger_with_log_level_from_env(log_device = STDOUT)
    logger = Logger.new(log_device)
    logger.level = log_level_from_env
    logger.formatter = lambda do |severity, _time, _progname, msg|
      "at=#{severity.downcase} #{msg}\n"
    end

    logger
  end

  def self.log_level_from_env
    ENV.fetch("LOG_LEVEL") { "INFO" }
  end
end
