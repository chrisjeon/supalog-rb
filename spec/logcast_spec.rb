# frozen_string_literal: true

RSpec.describe Logcast do
  it "has a version number" do
    expect(Logcast::VERSION).not_to be_nil
  end

  describe ".configure" do
    it "yields a configuration object" do
      Logcast.configure do |config|
        config.api_key = "my-key"
        config.url = "https://example.com"
        config.batch_size = 25
        config.flush_interval = 10
      end

      expect(Logcast.configuration.api_key).to eq("my-key")
      expect(Logcast.configuration.url).to eq("https://example.com")
      expect(Logcast.configuration.batch_size).to eq(25)
      expect(Logcast.configuration.flush_interval).to eq(10)
    end

    it "creates a buffer after configuration" do
      Logcast.configure do |config|
        config.api_key = "my-key"
      end

      expect(Logcast.buffer).to be_a(Logcast::Buffer)
    end
  end

  describe ".push" do
    it "adds an entry to the buffer" do
      Logcast.configure { |c| c.api_key = "key" }
      Logcast.push({ "level" => "info", "message" => "test" })

      expect(Logcast.buffer.size).to eq(1)
    end

    it "is safe to call before configure" do
      expect { Logcast.push({ "message" => "test" }) }.not_to raise_error
    end
  end
end
