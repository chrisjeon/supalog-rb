# frozen_string_literal: true

module Logcast
  class Railtie < Rails::Railtie
    config.after_initialize do
      if Logcast.configuration.api_key && Logcast.enabled?
        Logcast.start!
        Logcast.attach_logger!(Rails.logger)
      end
    end
  end
end
