module Mailing
  module ActionMailerExtensions
    extend ActiveSupport::Concern

    included do
      append_view_path ARTemplateResolver.instance
      alias_method_chain :collect_responses_and_parts_order, :required_parts_order
      alias_method_chain :mail, :template
      alias_method_chain :render, :layout
    end

    module ClassMethods
      def testing(action, recipient, variables)
        new.testing do |instance|
          instance.action_name = action.to_s
          variables.each { |k, v| instance.instance_variable_set("@#{k}", v) }
          instance.mail to: recipient
        end
      end
    end

    def render_with_layout(*args, &block)
      options = args.first
      if !options[:layout] && @_template
        format = options[:template].identifier.split('.').last
        options[:layout] = @_template.send("layout_#{format}")
      end
      render_without_layout(*args, &block)
    end

    def mail_with_template(headers = {}, &block)
      # maybe there is better way? - do not want to retrieve template from db second time
      @_template = Template.by_mailer(self.class).by_action(action_name).first
      if @_template
        self.action_name ||= @_template.action.to_s
        # think about this ugly shit
        vars = instance_variables.inject({}) { |hsh, var| hsh[var[1..-1].to_sym] = instance_variable_get(var) if var !~ /@_/; hsh }
        headers.reverse_merge!(@_template.headers(vars))
      end
      mail_without_template(headers, &block).tap do |m|
        m.perform_deliveries = testing? || !@_template || @_template.enabled
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
      [responses, parts_order || responses.map { |r| r[:content_type] }]
    end

  end
end