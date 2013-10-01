require 'singleton'

class Nisetegami::ARTemplateResolver < ActionView::Resolver

  include Singleton

  def clear_cache_for(mailer, action)
    key = "#{mailer.to_s.classify}##{action}"
    [@_templates, @_ar_templates].each { |hsh| hsh.try(:delete, key) }
  end

  def find_ar_template(mailer, action)
    @_ar_templates ||= {}
    key = "#{mailer.to_s.classify}##{action}"
    if @_ar_templates.has_key?(key)
      @_ar_templates[key]
    else
      @_ar_templates[key] = Nisetegami::Template.by_mailer(mailer).by_action(action).first
    end
  end

  def find_templates(name, prefix, partial, details)
    unless ar_template = find_ar_template(prefix, name)
      []
    else
      formats = []
      formats << :text unless ar_template.body_text.nil?
      formats << :html unless ar_template.only_text?

      formats.map do |format|
        source     = ar_template.send("prepared_body_#{format}")
        identifier = ar_template.identifier(format)
        handler    = ar_template.handler_for(format)
        details = {
          format: Mime[format],
          virtual_path: "#{ar_template.mailer.to_s.underscore}/#{ar_template.action}",
          updated_at: ar_template.updated_at
        }
        ActionView::Template.new(source, identifier, handler, details)
      end
    end
  end

end
