# frozen_string_literal: true

module Supalog
  class Railtie < Rails::Railtie
    config.after_initialize do
      if Supalog.configuration.api_key && Supalog.enabled?
        Supalog.start!
        Supalog.attach_logger!(Rails.logger)
      end
    end
  end
end
