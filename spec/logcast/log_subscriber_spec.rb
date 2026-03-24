# frozen_string_literal: true

require_relative "../../lib/logcast_sh/log_subscriber"

RSpec.describe LogcastSh::LogSubscriber do
  before do
    LogcastSh.configure do |config|
      config.api_key = "test-key"
    end
  end

  # A minimal logger that behaves like stdlib Logger (pre-BroadcastLogger Rails)
  def build_standard_logger
    logger = Object.new
    logger.define_singleton_method(:add) do |severity, message = nil, progname = nil, &block|
      true
    end
    %w[debug info warn error fatal unknown].each_with_index do |name, i|
      sev = i
      logger.define_singleton_method(name) do |message = nil, &block|
        add(sev, nil, message, &block)
      end
    end
    logger
  end

  # A minimal BroadcastLogger that delegates to sub-loggers (Rails 7.1+)
  def build_broadcast_logger(*sub_loggers)
    bl = Object.new
    loggers = sub_loggers.dup

    bl.define_singleton_method(:broadcast_to) do |*new_loggers|
      loggers.concat(new_loggers)
    end

    %w[debug info warn error fatal unknown].each do |name|
      bl.define_singleton_method(name) do |message = nil, &block|
        loggers.each { |l| l.send(name, message, &block) }
      end
    end

    bl.define_singleton_method(:add) do |severity, message = nil, progname = nil, &block|
      loggers.each { |l| l.add(severity, message, progname, &block) }
    end

    bl
  end

  describe "with standard Logger (older Rails)" do
    let(:logger) { build_standard_logger }

    before { LogcastSh::LogSubscriber.attach_logger!(logger) }

    it "captures info messages" do
      logger.info("hello info")
      expect(LogcastSh.buffer.size).to eq(1)
    end

    it "captures debug messages" do
      logger.debug("hello debug")
      expect(LogcastSh.buffer.size).to eq(1)
    end

    it "captures warn messages" do
      logger.warn("hello warn")
      expect(LogcastSh.buffer.size).to eq(1)
    end

    it "captures error messages" do
      logger.error("hello error")
      expect(LogcastSh.buffer.size).to eq(1)
    end

    it "captures block messages" do
      logger.info { "block message" }
      expect(LogcastSh.buffer.size).to eq(1)
    end

    it "sets the correct severity level" do
      allow(LogcastSh).to receive(:push).and_call_original
      logger.warn("a warning")
      expect(LogcastSh).to have_received(:push).with(hash_including("level" => "warn"))
    end
  end

  describe "with BroadcastLogger (Rails 7.1+)" do
    let(:sub_logger) { build_standard_logger }
    let(:broadcast_logger) { build_broadcast_logger(sub_logger) }

    before { LogcastSh::LogSubscriber.attach_logger!(broadcast_logger) }

    it "captures info messages" do
      broadcast_logger.info("broadcast info")
      expect(LogcastSh.buffer.size).to eq(1)
    end

    it "captures debug messages" do
      broadcast_logger.debug("broadcast debug")
      expect(LogcastSh.buffer.size).to eq(1)
    end

    it "captures warn messages" do
      broadcast_logger.warn("broadcast warn")
      expect(LogcastSh.buffer.size).to eq(1)
    end

    it "captures error messages" do
      broadcast_logger.error("broadcast error")
      expect(LogcastSh.buffer.size).to eq(1)
    end

    it "captures block messages" do
      broadcast_logger.info { "broadcast block" }
      expect(LogcastSh.buffer.size).to eq(1)
    end

    it "sets the correct severity level" do
      allow(LogcastSh).to receive(:push).and_call_original
      broadcast_logger.error("an error")
      expect(LogcastSh).to have_received(:push).with(hash_including("level" => "error"))
    end
  end
end
