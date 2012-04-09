require 'roadie'
require 'liquid'

require 'mailing/action_mailer_extensions'
require 'mailing/asset_provider'
require 'mailing/exceptions'
require 'mailing/mapping'
require 'mailing/utils'
require 'mailing/engine'

module Mailing

  mattr_accessor :layouts_path
  @@layouts_path = nil

  mattr_accessor :default_text_layout
  @@default_html_layout = 'default'

  mattr_accessor :default_html_layout
  @@default_text_layout = 'default'

  mattr_accessor :default_css
  mattr_accessor :css_path
  @@css_path = 'mailing' # relative from app/assets/stylesheets

  pattern = '[-a-z0-9_+\.]+@([-a-z0-9]+\.)+[a-z0-9]{2,}'
  address = "(?:[^<@]+\\s+<#{pattern}>|#{pattern})"

  mattr_accessor :email_regexp
  @@email_regexp = /^#{pattern}$/

  mattr_accessor :addresses_regexp
  @@addresses_regexp = /^#{address}(?:\s*,\s*#{address})*$/i

  mattr_reader :mapping
  @@mapping = Mailing::Mapping.new

  def self.configure
    yield self
  end

  def self.register(*args)
    @@mapping.register *args
  end

  def self.populate!
    @@mapping.populate!
  end

  def self.text_layouts
    @@text_layouts ||= Mailing::Utils.filenames(Mailing.layouts_path, :text)
  end

  def self.html_layouts
    @@html_layouts ||= Mailing::Utils.filenames(Mailing.layouts_path, :html)
  end

  def self.reset_layouts!
    @@text_layouts = nil
    @@html_layouts = nil
  end

  def self.asset_provider
    @@asset_provider ||= Mailing::AssetProvider.new(Roadie.current_provider.prefix)
  end

end