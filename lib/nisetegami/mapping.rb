module Nisetegami
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
      Nisetegami::Template.find_each { |template| template.destroy unless action_exists?(template[:mailer], template.action) }

      @mapping.each do |route, locals|
        mailer, action = route.split(SEPARATOR, 2)
        next unless can_populate?(mailer, action)
        variables = expand_locals(*locals).map{ |v| "{{ #{v} }}" }.join(", ")

        Nisetegami::Template.create!(
          mailer:  mailer,
          action:  action,
          enabled: false
        )
      end
    end

    def actions(mailer)
      klass = mailer.constantize
      klass.ancestors.include?(ActionMailer::Base) && klass.action_methods
    end

    private

    def expand_locals(*locals)
      locals.each_with_object([]) do |(v, thing), array|
        meths = Nisetegami::Utils.liquid_methods_for(Nisetegami.cast[thing])
        array << (meths.blank? ? v : meths.map { |m| "#{v}.#{m}" })
      end.flatten
    end

    def prepare_locals(*locals)
      options = locals.extract_options!
      # need to call tableize because of the bug in classify method ('master_class'.classify => 'MasterClas')
      locals.each_with_object({}) { |v, hsh| hsh[v.to_s] = v.to_s.tableize.classify }.merge(options.stringify_keys)
    end

    def can_populate?(mailer, action)
      action_exists?(mailer, action) && !Nisetegami::Template.where(mailer: mailer, action: action).exists?
    end

    def action_exists?(mailer, action)
      actions(mailer).include?(action.to_s)
    end

  end
end
