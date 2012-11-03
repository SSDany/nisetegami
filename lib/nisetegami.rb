require 'roadie'
require 'liquid'

require 'nisetegami/action_mailer_extensions'
require 'nisetegami/liquid_template_handler'
require 'nisetegami/ar_template_resolver'
require 'nisetegami/asset_provider'
require 'nisetegami/exceptions'
require 'nisetegami/mapping'
require 'nisetegami/utils'
require 'nisetegami/engine'

module Nisetegami

  mattr_accessor :layouts_path
  @@layouts_path = nil

  mattr_accessor :default_text_layout
  @@default_html_layout = 'default'

  mattr_accessor :default_html_layout
  @@default_text_layout = 'default'

  mattr_accessor :default_css
  mattr_accessor :css_path
  @@css_path = 'nisetegami' # relative from app/assets/stylesheets

  pattern = '[-a-z0-9_+\.]+@([-a-z0-9]+\.)+[a-z0-9]{2,}'
  address = "(?:[^<@]+\\s+<#{pattern}>|#{pattern})"

  mattr_accessor :email_regexp
  @@email_regexp = /^#{pattern}$/

  mattr_accessor :addresses_regexp
  @@addresses_regexp = /^#{address}(?:\s*,\s*#{address})*$/i

  mattr_reader :mapping
  @@mapping = Nisetegami::Mapping.new

  def self.configure
    yield self
  end

  # optional block to cast a thing (String, Symbol)
  # into a class with liquid_methods
  def self.cast(&block)
    @@cast ||= ->(thing){ defined?(thing) == 'constant' ? thing : thing.to_s.constantize }
    block_given? ? @@cast = block : @@cast
  end

  def self.register(*args)
    @@mapping.register *args
  end

  def self.populate!
    @@mapping.populate!
  end

  def self.text_layouts
    @@text_layouts ||= Nisetegami::Utils.filenames(Nisetegami.layouts_path, :text)
  end

  def self.html_layouts
    @@html_layouts ||= Nisetegami::Utils.filenames(Nisetegami.layouts_path, :html)
  end

  def self.reset_layouts!
    @@text_layouts = nil
    @@html_layouts = nil
  end

  def self.asset_provider
    @@asset_provider ||= Nisetegami::AssetProvider.new(Roadie.current_provider.prefix)
  end

end
