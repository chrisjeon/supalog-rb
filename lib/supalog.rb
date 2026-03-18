# frozen_string_literal: true

require_relative "supalog/version"
require_relative "supalog/configuration"
require_relative "supalog/buffer"
require_relative "supalog/transport"

module Supalog
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      start!
    end

    def start!
      return if @started

      @buffer = Buffer.new(
        batch_size: configuration.batch_size,
        flush_interval: configuration.flush_interval
      ) { |batch| Transport.deliver(batch, configuration) }

      at_exit { shutdown }
      @started = true
    end

    def buffer
      @buffer
    end

    def push(entry)
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
    end
  end
end

require_relative "supalog/railtie" if defined?(Rails::Railtie)
