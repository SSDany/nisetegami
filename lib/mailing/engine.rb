require 'mailing'

module Mailing
  class Engine < Rails::Engine

    engine_name :mailing

    initializer 'mailing.action_mailer' do |app|
      ActiveSupport.on_load :action_mailer do
        include Mailing::ActionMailerExtensions
      end
    end

    config.before_initialize do
      Mailing.layouts_path = Rails.root.join('app/views/mailing/layouts').to_s
    end

    config.to_prepare do
      Mailing.reset_layouts! unless Rails.env.production?
    end

  end
end