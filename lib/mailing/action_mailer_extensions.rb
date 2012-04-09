module Mailing
  module ActionMailerExtensions
    extend ActiveSupport::Concern

    module ClassMethods
      def testing(action, recipient, *variables)
        message = new.testing do |instance|
          instance.action_name = action.to_s
          instance.render_template(recipient, *variables)
        end
        message.to = recipient
        message
      end
    end

    def render_template(recipient, *args)
      if template && (testing? || template.enabled?)
        options = args.extract_options!
        options = options.merge(template.mailing_options(recipient, *args))
        options[:css] = associated_stylesheets unless template.only_text?
        mail(options) do |format|
          format.html { render text: template.render_body_html(*args), layout: template.layout_html_path } unless template.only_text?
          format.text { render text: template.render_body_text(*args), layout: template.layout_text_path }
        end
      elsif template
        disable_delivery!
      else
        raise Exceptions::MissingTemplateError.new(self)
      end
    end

    def testing(&block)
      @_testing_was, @_testing = @_testing, true
      yield self
    ensure
      @_testing = @_testing_was
    end

    private

    def disable_delivery!
      message.perform_deliveries = false
    end

    def associated_stylesheets
      stylesheets = Array(Mailing.default_css)
      stylesheets << template.layout_html unless template.layout_html.blank?
      stylesheets.map! { |s| File.join(Mailing.css_path, s) }
      stylesheets.select { |s| Mailing.asset_provider.exists?(s) }
    end

    def testing?
      !!@_testing
    end

    def template
      @_template ||= ::Mailing::Template.lookup(self)
    end

  end
end