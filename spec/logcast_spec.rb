# frozen_string_literal: true

RSpec.describe LogcastSh do
  it "has a version number" do
    expect(LogcastSh::VERSION).not_to be_nil
  end

  describe ".configure" do
    it "yields a configuration object" do
      LogcastSh.configure do |config|
        config.api_key = "my-key"
        config.url = "https://example.com"
        config.batch_size = 25
        config.flush_interval = 10
      end

      expect(LogcastSh.configuration.api_key).to eq("my-key")
      expect(LogcastSh.configuration.url).to eq("https://example.com")
      expect(LogcastSh.configuration.batch_size).to eq(25)
      expect(LogcastSh.configuration.flush_interval).to eq(10)
    end

    it "creates a buffer after configuration" do
      LogcastSh.configure do |config|
        config.api_key = "my-key"
      end

      expect(LogcastSh.buffer).to be_a(LogcastSh::Buffer)
    end
  end

  describe ".push" do
    it "adds an entry to the buffer" do
      LogcastSh.configure { |c| c.api_key = "key" }
      LogcastSh.push({ "level" => "info", "message" => "test" })

      expect(LogcastSh.buffer.size).to eq(1)
    end

    it "is safe to call before configure" do
      expect { LogcastSh.push({ "message" => "test" }) }.not_to raise_error
    end
  end
end
