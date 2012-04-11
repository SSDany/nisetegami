module Mailing
  class Mapping
    attr_reader :mailers

    SEPARATOR = "#"

    def initialize
      @mailers = Set.new
      @mapping = {}
    end

    def register(mailer, action, *locals)
      mailer = mailer.camelize
      unless action_exists?(mailer, action)
        raise Exceptions::UnknownActionError.new(mailer, action)
      end
      locals_with_types = locals.each_with_object(locals.extract_options!.stringify_keys) do |var, hsh|
        klass = var.to_s.classify
        # treat variables as strings by default
        hsh[var.to_s] = Module.const_defined?(klass) ? klass : 'String'
      end
      @mapping["#{mailer}#{SEPARATOR}#{action}"] = locals_with_types
      @mailers << mailer
    end

    def lookup(mailer, action)
      @mapping["#{mailer}#{SEPARATOR}#{action}"] || {}
    end

    def populate!
      @mapping.each do |route, locals|
        mailer, action = route.split(SEPARATOR, 2)
        next unless can_populate?(mailer, action)

        variables = locals.each_with_object([]) do |(v, thing), array|
          meths = liquid_methods_for(thing.constantize)
          array << (meths.blank? ? "{{ #{v} }}" : meths.map { |m| "{{ #{v}.#{m} }}" })
        end

        variables.flatten!
        variables = variables.join(", ")

        Mailing::Template.create!(
          subject:   "Subject",
          body_text: "You can use following variables: #{variables}. Format: text.",
          body_html: "You can use following variables: #{variables}. Format: html.",
          name:    route,
          mailer:  mailer,
          action:  action,
          enabled: false
        )
      end
    end

    private

    def can_populate?(mailer, action)
      action_exists?(mailer, action) && !Mailing::Template.where(mailer: mailer, action: action).exists?
    end

    def action_exists?(mailer, action)
      klass = mailer.constantize
      klass.ancestors.include?(ActionMailer::Base) &&
      klass.action_methods.include?(action.to_s)
    rescue NameError
      false
    end

  end
end