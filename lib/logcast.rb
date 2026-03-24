# frozen_string_literal: true

require_relative "logcast/version"
require_relative "logcast/configuration"
require_relative "logcast/buffer"
require_relative "logcast/transport"
require_relative "logcast/log_subscriber"

module Logcast
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      start!

      if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
        attach_logger!(Rails.logger)
      end
    end

    def enabled?
      configuration.enabled
    end

    def start!
      return if @started
      return unless enabled?

      @buffer = Buffer.new(
        batch_size: configuration.batch_size,
        flush_interval: configuration.flush_interval
      ) { |batch| Transport.deliver(batch, configuration) }

      at_exit { shutdown }
      @started = true
    end

    def attach_logger!(logger)
      return if @logger_attached

      LogSubscriber.attach_logger!(logger)
      @logger_attached = true
    end

    def buffer
      @buffer
    end

    def push(entry)
      return unless enabled?

      @buffer&.push(entry)
    end

    def shutdown
      @buffer&.flush!
      @buffer&.stop
      @started = false
    end

    def reset!
      shutdown
      @configuration = Configuration.new
      @buffer = nil
      @started = false
      @logger_attached = false
    end
  end
end

require_relative "logcast/railtie" if defined?(Rails::Railtie)
