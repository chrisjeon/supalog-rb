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

    def self.subscribe!
      ActiveSupport::Notifications.subscribe(/\./) do |name, _start, _finish, _id, payload|
        next if name.start_with?("!") # skip internal events

        level = payload[:exception] ? "error" : "info"
        message = payload[:message] || name
        metadata = extract_metadata(name, payload)

        Supalog.push({
          "level" => level,
          "message" => message.to_s,
          "metadata" => metadata,
          "timestamp" => Time.now.utc.iso8601(3)
        })
      end
    end

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

    private_class_method def self.extract_metadata(name, payload)
      meta = {}
      meta["event"] = name
      meta["request_id"] = payload[:request_id] if payload[:request_id]
      meta["controller"] = payload[:controller] if payload[:controller]
      meta["action"] = payload[:action] if payload[:action]
      meta["method"] = payload[:method] if payload[:method]
      meta["path"] = payload[:path] if payload[:path]
      meta["status"] = payload[:status] if payload[:status]
      meta["exception"] = payload[:exception].inspect if payload[:exception]
      meta
    end
  end
end
