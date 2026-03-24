# frozen_string_literal: true

RSpec.describe LogcastSh::Configuration do
  subject(:config) { described_class.new }

  it "has default url" do
    expect(config.url).to eq("https://www.logcast.sh")
  end

  it "has default batch_size" do
    expect(config.batch_size).to eq(100)
  end

  it "has default flush_interval" do
    expect(config.flush_interval).to eq(5)
  end

  it "has nil api_key by default" do
    expect(config.api_key).to be_nil
  end

  it "allows setting api_key" do
    config.api_key = "test-key"
    expect(config.api_key).to eq("test-key")
  end

  it "allows setting url" do
    config.url = "https://custom.example.com"
    expect(config.url).to eq("https://custom.example.com")
  end

  it "allows setting batch_size" do
    config.batch_size = 200
    expect(config.batch_size).to eq(200)
  end

  it "allows setting flush_interval" do
    config.flush_interval = 10
    expect(config.flush_interval).to eq(10)
  end
end
