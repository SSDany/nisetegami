module Nisetegami
  class Engine < Rails::Engine
    isolate_namespace Nisetegami

    initializer 'nisetegami.action_mailer' do |app|
      ActiveSupport.on_load :action_mailer do
        include Nisetegami::ActionMailerExtensions
      end
    end

    config.before_initialize do
      Nisetegami.class_variable_set(:@@layouts_path, Rails.root.join('app/views/nisetegami/layouts').to_s)
    end

    config.to_prepare do
      Dir.glob("#{Rails.root}/app/decorators/nisetegami/**/*_decorator*.rb").each do |decorator|
        require_dependency(decorator)
      end
    end

  end
end
