# frozen_string_literal: true

module Supalog
  class LogSubscriber
    SEVERITY_MAP = {
      0 => "debug",
      1 => "info",
      2 => "warn",
      3 => "error",
      4 => "fatal",
      5 => "unknown"
    }.freeze

    def self.attach_logger!(logger)
      return unless logger

      original_add = logger.method(:add)
      severity_map = SEVERITY_MAP

      logger.define_singleton_method(:add) do |severity, message = nil, progname = nil, &block|
        msg = message || (block ? block.call : progname)

        if msg
          Supalog.push({
            "level" => severity_map[severity] || "unknown",
            "message" => msg.to_s,
            "metadata" => {},
            "timestamp" => Time.now.utc.iso8601(3)
          })
        end

        original_add.call(severity, message, progname, &block)
      end
    end
  end
end
