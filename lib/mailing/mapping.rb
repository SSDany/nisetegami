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
      @mapping["#{mailer}#{SEPARATOR}#{action}"] = variables_with_types(*locals)
      @mailers << mailer
    end

    def lookup(mailer, action)
      @mapping["#{mailer}#{SEPARATOR}#{action}"] || {}
    end

    def populate!
      @mapping.each do |route, locals|
        mailer, action = route.split(SEPARATOR, 2)
        next unless can_populate?(mailer, action)
        variables = expand_variables(locals) { |expand_chain| "{{ #{expand_chain.join('.')} }}" }.flatten.join(', ')

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

    def expand_variables(variables_hash, expand_chain = [], &block)
      variables_hash.each_with_object([]) do |(v, thing), array|
        meths = Utils.liquid_methods_for(thing.constantize)
        new_expand_chain = expand_chain.dup << v
        array << (meths.blank? ?
          yield(new_expand_chain) :
          expand_variables(variables_with_types(*meths), new_expand_chain, &block))
      end
    end

    private

    def variables_with_types(*variables)
      # allow to specify class constants instead of string class names
      stringified_options = variables.extract_options!.stringify_keys.inject({}) { |hsh, (v, thing)| hsh[v] = thing.to_s; hsh }
      variables.inject(stringified_options) do |hsh, var|
        klass = var.to_s.classify
        # treat variables as strings by default
        # use exceptions because AR models are not loaded yet
        hsh[var.to_s] = begin
          klass.constantize
          klass
        rescue NameError
          'String'
        end

        hsh
      end
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