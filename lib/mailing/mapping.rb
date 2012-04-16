module Mailing
  class Mapping
    attr_reader :mailers

    SEPARATOR = "#"

    def initialize
      @mailers = Set.new
      @mapping = {}
    end

    def register(mailer, action, *locals)
      mailer = mailer.to_s.classify
      unless action_exists?(mailer, action)
        raise Exceptions::UnknownActionError.new(mailer, action)
      end
      @mapping["#{mailer}#{SEPARATOR}#{action}"] = prepare_locals(*locals)
      @mailers << mailer
    end

    def lookup(mailer, action)
      @mapping["#{mailer}#{SEPARATOR}#{action}"] || {}
    end

    def populate!
      @mapping.each do |route, locals|
        mailer, action = route.split(SEPARATOR, 2)
        next unless can_populate?(mailer, action)
        variables = expand_locals(*locals).map{ |v| "{{ #{v} }}" }.join(" ")

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

    def expand_locals(*locals)
      locals.each_with_object([]) do |(v, thing), array|
        meths = Mailing::Utils.liquid_methods_for(Mailing.cast[thing])
        array << (meths.blank? ? v : meths.map { |m| "#{v}.#{m}" })
      end.flatten
    end

    def prepare_locals(*locals)
      options = locals.extract_options!
      locals.each_with_object({}) { |v, hsh| hsh[v.to_s] = v.to_s.classify }.merge(options.stringify_keys)
    end

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