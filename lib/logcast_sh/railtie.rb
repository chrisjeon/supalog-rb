# frozen_string_literal: true

module LogcastSh
  class Railtie < Rails::Railtie
    config.after_initialize do
      if LogcastSh.configuration.api_key && LogcastSh.enabled?
        LogcastSh.start!
        LogcastSh.attach_logger!(Rails.logger)
      end
    end
  end
end
