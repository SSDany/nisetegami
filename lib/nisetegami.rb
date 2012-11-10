require 'roadie'
require 'liquid'

require 'nisetegami/action_mailer_extensions'
require 'nisetegami/liquid_template_handler'
require 'nisetegami/ar_template_resolver'
require 'nisetegami/asset_provider'
require 'nisetegami/exceptions'
require 'nisetegami/mapping'
require 'nisetegami/utils'
require 'nisetegami/template_presenter'
require 'nisetegami/engine'
require 'nisetegami/railtie'

module Nisetegami

  mattr_reader :layouts_path

  mattr_reader :mapping
  @@mapping = Nisetegami::Mapping.new

  mattr_reader :email_re
  @@email_re = /[-a-z0-9_+\.]+@([-a-z0-9]+\.)+[a-z0-9]{2,}/

  def self.configure
    yield self
  end

  # optional block to cast a thing (String, Symbol)
  # into a class with liquid_methods
  def self.cast(&block)
    @@cast ||= ->(thing) do
      if defined?(thing) == 'constant'
        thing
      elsif const_defined?(thing.to_s)
        thing.to_s.constantize
      else
        String
      end
    end
    block_given? ? @@cast = block : @@cast
  end

  def self.register(*args)
    @@mapping.register(*args)
  end

  def self.populate!
    @@mapping.populate!
  end

  class << self
    %w(text html).each do |format|
      define_method("#{format}_layouts") do
        # cache result in class variable unless in development
        instance_variable_get(:"@#{format}_layouts") || Nisetegami::Utils.filenames(Nisetegami.layouts_path, format).tap do |layouts|
          instance_variable_set(:"@#{format}_layouts", layouts) unless Rails.env.development?
        end
      end
    end
  end

end
