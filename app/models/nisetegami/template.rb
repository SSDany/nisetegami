class Nisetegami::Template < ActiveRecord::Base

  self.table_name = :nisetegami_templates

  ## constants

  CONTENT = [:subject, :body_html, :body_text]
  HEADERS = [:cc, :bcc, :reply_to, :from]

  ## scopes

  scope :by_mailer, ->(mailer){ where(mailer: mailer.respond_to?(:name) ? mailer.name : mailer) }
  scope :by_action, ->(action){ where(action: action) }
  scope :by_layout, ->(layout){ where(layout: layout) }
  scope :enabled,   where(enabled: true)
  scope :disabled,  where(enabled: false)
  scope :html,      where(only_text: false)
  scope :text,      where(only_text: true)

  ## validations

  validates_format_of :from, :reply_to, :cc, :bcc, with: Nisetegami.addresses_regexp, allow_blank: true
  validate :subject, :body_text, :layout_text, :name, presence: true
  validate :body_html, :layout_html, presence: true, unless: :only_text?
  validate :check_template_syntax
  validate :check_mailer

  ## class-methods

  # Accepts an instance of the ActionMailer::Base subclass
  # and attempts to find associated template using
  # name and action_name of the mailer.
  def self.lookup(mailer_instance)
    relation.where(mailer: mailer_instance.class.name, action: mailer_instance.action_name).first
  end

  public

  # Returns a full HTML layout path for +self+.
  # If layout does not specified, fallbacks to the
  # default layout using Nisetegami settings.
  def layout_html_path
    layout = self.layout_html || Nisetegami.default_html_layout
    layout && File.join(Nisetegami.layouts_path, layout)
  end

  # Returns a full text layout path for +self+.
  # If layout does not specified, fallbacks to the
  # default layout using Nisetegami settings.
  def layout_text_path
    layout = self.layout_text || Nisetegami.default_text_layout
    layout && File.join(Nisetegami.layouts_path, layout)
  end

  # Returns a mapping for +self+, as a Hash.
  def mapping
    @_mapping ||= ::Nisetegami.mapping.lookup(mailer, action)
  end

  # Returns a list of variables for +self+,
  # using a Nisetegami::Mapping definitions.
  def variable_names
    @_variable_names ||= mapping.keys
  end

  def variable_mapping
    @_variable_mapping ||= begin
      mapping.each_with_object([]) do |(variable, thing), array|
        # @todo: store variable_mapping in mapping instead of classes [?]
        meths = Nisetegami::Utils.liquid_methods_for(Nisetegami.cast[thing])
        array << (meths.blank? ? variable.to_sym : { variable.to_sym => meths })
      end
    end
  end

  def mailer
    @_mailer ||= self[:mailer].constantize
  end

  CONTENT.each do |attribute|
    define_method "#{attribute}=" do |raw|
      self[attribute] = raw.blank? ? nil : raw
      instance_variable_set("@#{attribute}_template", nil)
    end

    define_method "render_#{attribute}" do |variables|
      return nil unless self[attribute]
      # do not parse invalid templates
      if instance_variable_get("@#{attribute}_template").nil?
        instance_variable_set("@#{attribute}_template", try_parse_template(attribute))
      end
      instance_variable_get("@#{attribute}_template") \
        .try(:render, variables.stringify_keys.select { |k, v| k.in?(variable_names) })
    end
  end

  def headers(variables = {})
    options = { subject: render_subject(variables) }
    options[:css] = associated_stylesheets unless only_text?
    HEADERS.each { |header| options[header] = self[header] unless self[header].blank? }
    options
  end

  def message(recipient, variables)
    return nil unless valid?
    mailer.testing(action, recipient, variables)
  end

  private

  def associated_stylesheets
    stylesheets = Array(Nisetegami.default_css)
    stylesheets << layout_html unless layout_html.blank?
    stylesheets.map! { |s| File.join(Nisetegami.css_path, s) }
    stylesheets.select { |s| Nisetegami.asset_provider.exists?(s) }
  end

  def check_mailer
    errors.add(:mailer, :undefined) unless mailer.ancestors.include?(ActionMailer::Base)
    errors.add(:action, :undefined) unless mailer.action_methods.include?(action.to_s)
  rescue NameError
    errors.add(:mailer, :undefined)
  end

  def check_template_syntax
    CONTENT.each { |attribute| try_parse_template(attribute) }
  end

  def try_parse_template(attribute)
    Liquid::Template.parse(self[attribute])
  rescue Liquid::SyntaxError => error
    errors.add(attribute, :liquid_syntax_error, message: error.message)
    false
  end

end

# == Schema Information
#
# Table name: nisetegami_templates
#
#  id          :integer         not null, primary key
#  mailer      :string(255)
#  action      :string(255)
#  name        :string(255)
#  from        :string(255)
#  cc          :string(255)
#  bcc         :string(255)
#  reply_to    :string(255)
#  subject     :text
#  body_text   :text
#  body_html   :text
#  layout_text :string(255)
#  layout_html :string(255)
#  enabled     :boolean         default(FALSE), not null
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#
# Indexes
#
#  index_nisetegami_templates_on_mailer_and_action  (mailer,action) UNIQUE
#

