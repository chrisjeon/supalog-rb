# frozen_string_literal: true

require "webrick"

RSpec.describe LogcastSh::Transport do
  let(:config) do
    LogcastSh::Configuration.new.tap do |c|
      c.api_key = "test-api-key"
      c.url = "http://127.0.0.1:#{port}"
    end
  end

  let(:port) { 19_876 }
  let(:received_requests) { [] }
  let(:server) { nil }

  def start_server(response_code: 201)
    requests = received_requests
    @server = WEBrick::HTTPServer.new(Port: port, Logger: WEBrick::Log.new("/dev/null"), AccessLog: [])
    @server.mount_proc "/api/logs" do |req, res|
      requests << { body: req.body, headers: req.header }
      res.status = response_code
      res.body = ""
    end
    Thread.new { @server.start }
    sleep 0.1 # wait for server to bind
  end

  after do
    @server&.shutdown
  end

  let(:batch) do
    [
      { "level" => "info", "message" => "test log", "metadata" => {}, "timestamp" => "2026-03-17T00:00:00.000Z" }
    ]
  end

  it "sends batch to the ingest endpoint" do
    start_server
    described_class.deliver(batch, config)

    expect(received_requests.size).to eq(1)
    body = JSON.parse(received_requests.first[:body])
    expect(body["logs"]).to eq(batch)
  end

  it "sends correct headers" do
    start_server
    described_class.deliver(batch, config)

    headers = received_requests.first[:headers]
    expect(headers["x-api-key"]).to eq(["test-api-key"])
    expect(headers["content-type"]).to eq(["application/json"])
  end

  it "does not raise on non-success response" do
    start_server(response_code: 500)
    expect { described_class.deliver(batch, config) }.not_to raise_error
  end

  it "does not raise on connection failure" do
    config.url = "http://127.0.0.1:1" # nothing listening
    expect { described_class.deliver(batch, config) }.not_to raise_error
  end

  it "writes to stderr on failure" do
    config.url = "http://127.0.0.1:1"
    expect { described_class.deliver(batch, config) }.to output(/Transport error/).to_stderr
  end
end
