# frozen_string_literal: true

RSpec.describe Supalog do
  it "has a version number" do
    expect(Supalog::VERSION).not_to be_nil
  end

  describe ".configure" do
    it "yields a configuration object" do
      Supalog.configure do |config|
        config.api_key = "my-key"
        config.url = "https://example.com"
        config.batch_size = 25
        config.flush_interval = 10
      end

      expect(Supalog.configuration.api_key).to eq("my-key")
      expect(Supalog.configuration.url).to eq("https://example.com")
      expect(Supalog.configuration.batch_size).to eq(25)
      expect(Supalog.configuration.flush_interval).to eq(10)
    end

    it "creates a buffer after configuration" do
      Supalog.configure do |config|
        config.api_key = "my-key"
      end

      expect(Supalog.buffer).to be_a(Supalog::Buffer)
    end
  end

  describe ".push" do
    it "adds an entry to the buffer" do
      Supalog.configure { |c| c.api_key = "key" }
      Supalog.push({ "level" => "info", "message" => "test" })

      expect(Supalog.buffer.size).to eq(1)
    end

    it "is safe to call before configure" do
      expect { Supalog.push({ "message" => "test" }) }.not_to raise_error
    end
  end
end
