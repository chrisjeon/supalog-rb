# frozen_string_literal: true

module LogcastSh
  class LogSubscriber
    SEVERITY_MAP = {
      0 => "debug",
      1 => "info",
      2 => "warn",
      3 => "error",
      4 => "fatal",
      5 => "unknown"
    }.freeze

    class ForwardingLogger
      attr_accessor :formatter, :progname
      attr_writer :level

      def initialize
        @level = 0
        @formatter = nil
        @progname = nil
      end

      def add(severity, message = nil, progname = nil, &block)
        severity ||= 5

        if message.nil?
          if block
            message = block.call
          else
            message = progname
          end
        end

        if message
          LogcastSh.push({
            "level" => SEVERITY_MAP[severity] || "unknown",
            "message" => message.to_s.gsub(/\e\[[0-9;]*m/, ""),
            "metadata" => {},
            "timestamp" => Time.now.utc.iso8601(3)
          })
        end

        true
      end
      alias_method :log, :add

      def debug(message = nil, &block)   = add(0, nil, message, &block)
      def info(message = nil, &block)    = add(1, nil, message, &block)
      def warn(message = nil, &block)    = add(2, nil, message, &block)
      def error(message = nil, &block)   = add(3, nil, message, &block)
      def fatal(message = nil, &block)   = add(4, nil, message, &block)
      def unknown(message = nil, &block) = add(5, nil, message, &block)

      def level
        @level
      end

      def debug?   = level <= 0
      def info?    = level <= 1
      def warn?    = level <= 2
      def error?   = level <= 3
      def fatal?   = level <= 4

      alias_method :sev_threshold, :level
      alias_method :sev_threshold=, :level=

      def close; end
      def reopen(_log = nil); end
      def flush; end
      def <<(msg)
        add(5, msg)
      end
    end

    def self.attach_logger!(logger)
      return unless logger

      if logger.respond_to?(:broadcast_to)
        logger.broadcast_to(ForwardingLogger.new)
      else
        original_add = logger.method(:add)
        severity_map = SEVERITY_MAP

        logger.define_singleton_method(:add) do |severity, message = nil, progname = nil, &block|
          msg = message || (block ? block.call : progname)

          if msg
            LogcastSh.push({
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
end
