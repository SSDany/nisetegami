module Nisetegami
  module ActionMailerExtensions
    extend ActiveSupport::Concern

    included do
      append_view_path ARTemplateResolver.instance
      append_view_path "#{Rails.root}/app/views/nisetegami"
      alias_method_chain :collect_responses_and_parts_order, :required_parts_order
      alias_method_chain :mail, :template
      alias_method_chain :render, :layout
    end

    module ClassMethods
      def testing(action, recipient, variables)
        new.testing do |instance|
          instance.action_name = action.to_s
          variables.each { |k, v| instance.instance_variable_set("@#{k}", v) } if variables
          instance.mail to: recipient
        end
      end
    end

    def render_with_layout(*args, &block)
      options = args.first
      if !options[:layout] && @_ar_template
        format = options[:template].identifier.include?('html') ? 'html' : 'text'
        layout = @_ar_template.send("layout_#{format}")
        options[:layout] = layout unless layout.blank?
      end
      render_without_layout(*args, &block)
    end

    def mail_with_template(headers = {}, &block)
      if @_ar_template = ARTemplateResolver.instance.find_ar_template(self.class.to_s, action_name)
        self.action_name ||= @_ar_template.action.to_s
        # think about this ugly shit
        vars = instance_variables.inject({}) do |hsh, var|
          unless var =~ /@_/
            template_var = instance_variable_get(var)
            if template_var.class != (casted = Nisetegami.cast[template_var.class])
              template_var = instance_variable_set(var, casted.new(template_var))
            end
            hsh[var[1..-1].to_sym] = template_var
          end
          hsh
        end
        headers.reverse_merge!(@_ar_template.headers(vars))
      end
      mail_without_template(headers, &block).tap do |m|
        m.perform_deliveries = testing? || !@_ar_template || @_ar_template.enabled
        m.body = nil unless m.perform_deliveries # better to remove corresponding specs??
      end
    end

    def testing(&block)
      @_testing_was, @_testing = @_testing, true
      yield self
    ensure
      @_testing = @_testing_was
    end

    protected

    def testing?
      !!@_testing
    end

    def collect_responses_and_parts_order_with_required_parts_order(headers)
      responses, parts_order = collect_responses_and_parts_order_without_required_parts_order(headers)
      parts_order ||= responses.map { |r| r[:content_type] } if @_ar_template
      [responses, parts_order]
    end

  end
end
