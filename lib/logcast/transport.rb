# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Logcast
  class Transport
    CONNECT_TIMEOUT = 5
    READ_TIMEOUT = 10

    def self.deliver(batch, configuration)
      uri = URI.join(configuration.url, "/api/logs")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = CONNECT_TIMEOUT
      http.read_timeout = READ_TIMEOUT

      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request["X-Api-Key"] = configuration.api_key
      request.body = JSON.generate({ "logs" => batch })

      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        $stderr.puts "[Logcast] Ingest API responded with #{response.code}: #{response.body}"
      end
    rescue => e
      $stderr.puts "[Logcast] Transport error: #{e.message}"
    end
  end
end
