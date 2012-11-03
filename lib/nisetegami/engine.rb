require 'nisetegami'

module Nisetegami
  class Engine < Rails::Engine

    engine_name :nisetegami

    initializer 'nisetegami.action_mailer' do |app|
      ActiveSupport.on_load :action_mailer do
        include Nisetegami::ActionMailerExtensions
      end
    end

    config.before_initialize do
      Nisetegami.layouts_path = Rails.root.join('app/views/nisetegami/layouts').to_s
    end

    config.to_prepare do
      Nisetegami.reset_layouts! unless Rails.env.production?
    end

  end
end
