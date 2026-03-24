# frozen_string_literal: true

module LogcastSh
  class Configuration
    attr_accessor :api_key, :url, :batch_size, :flush_interval, :enabled

    def initialize
      @api_key = nil
      @url = "https://www.logcast.sh"
      @batch_size = 100
      @flush_interval = 5
      @enabled = true
    end
  end
end
