# frozen_string_literal: true

require_relative "log_subscriber"

module Supalog
  class Railtie < Rails::Railtie
    initializer "supalog.configure_logging" do
      if Supalog.configuration.api_key
        Supalog.start!
        Supalog::LogSubscriber.attach_logger!(Rails.logger)
      end
    end
  end
end
