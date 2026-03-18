# frozen_string_literal: true

require_relative "supalog/version"
require_relative "supalog/configuration"
require_relative "supalog/buffer"
require_relative "supalog/transport"
require_relative "supalog/log_subscriber"

module Supalog
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

require_relative "supalog/railtie" if defined?(Rails::Railtie)
