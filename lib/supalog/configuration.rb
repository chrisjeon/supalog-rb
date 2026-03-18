# frozen_string_literal: true

module Supalog
  class Configuration
    attr_accessor :api_key, :url, :batch_size, :flush_interval, :enabled

    def initialize
      @api_key = nil
      @url = "https://www.supalog.dev"
      @batch_size = 100
      @flush_interval = 5
      @enabled = true
    end
  end
end
