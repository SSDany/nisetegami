require 'singleton'

class Mailing::ARTemplateResolver < ActionView::Resolver

  include Singleton

  def find_templates(name, prefix, partial, details)
    Mailing::Template.by_mailer(prefix.classify).by_action(name).map do |record|

      formats = [:text]
      formats.unshift(:html) unless record.only_text?
      formats.map do |format|
        source     = record.send("body_#{format}")
        identifier = "Mailing::Template.#{record.id}.#{format}"
        handler    = ActionView::Template.registered_template_handler(:liquid)
        details = {
          format: Mime[format],
          virtual_path: "#{record.mailer.to_s.underscore}/#{record.action}",
          updated_at: record.updated_at
        }
        ActionView::Template.new(source, identifier, handler, details)
      end
    end.flatten
  end
end