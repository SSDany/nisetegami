# encoding: utf-8

module Nisetegami
  module Admin
    class TemplatePresenter
      def initialize(template)
        @template = template
      end

      def mailer
        I18n.t("nisetegami.mailers.#{@template.mailer.to_s.underscore}", default: @template.mailer)
      end

      def action
        I18n.t("nisetegami.actions.#{@template.mailer.to_s.underscore}.#{@template.action}", default: @template.action.humanize)
      end

      def translate_variable(*args)
        I18n.t("nisetegami.variables.#{@temlate.mailer.to_s.underscore}.#{@template.action}." << args.join('.'))
      end

      %w(enabled only_text).each do |attr|
        define_method(attr) { @template.send(attr) ? '√' : '' }
      end

      def method_missing(method, *args, &block)
        @template.send(method, *args, &block)
      end
    end
  end
end
