class Nisetegami::Template < ActiveRecord::Base

  attr_accessible :name, :mailer, :action, :subject, :from,
                  :reply_to, :cc, :bcc, :enabled, :only_text,
                  :layout_text, :body_text, :layout_html, :body_html

  ## constants

  CONTENT = [:subject, :body_text, :body_html]
  HEADERS = [:cc, :bcc, :reply_to, :from]

  ## scopes

  scope :recent,    order('id DESC')
  scope :by_mailer, ->(mailer){ where(mailer: mailer.respond_to?(:name) ? mailer.name : mailer) }
  scope :by_action, ->(action){ where(action: action) }
  scope :by_layout, ->(layout){ where(layout: layout) }
  scope :enabled,   where(enabled: true)
  scope :disabled,  where(enabled: false)
  scope :html,      where(only_text: false)
  scope :text,      where(only_text: true)

  ## validations

  address_re   = "(?:[^<@]+\\s+<#{Nisetegami.email_re}>|#{Nisetegami.email_re})"
  addresses_re = /^#{address_re}(?:\s*,\s*#{address_re})*$/i
  validates :from, :reply_to, :cc, :bcc, format: {with: addresses_re}, allow_blank: true
  validates :name, presence: true
  validates :subject, :body_text, presence: true, if: :enabled
  validates :action, uniqueness: {scope: :mailer}
  validate  :check_template_syntax
  validate  :check_mailer

  ## callbacks

  before_validation :set_name_if_necessary
  after_save :clear_ar_template_resolver_cache

  ## class-methods

  # Accepts an instance of the ActionMailer::Base subclass
  # or Hash with mailer and action names
  # and attempts to find associated template using
  # name and action_name of the mailer.
  def self.lookup(arg)
    if arg.respond_to?(:action_name)
      relation.where(mailer: mailer_instance.class.name, action: mailer_instance.action_name).first
    else
      relation.where(mailer: arg[:mailer].to_s.classify, action: arg[:action].to_s.underscore).first
    end
  end

  def layout_html_path
    layout_html && File.join(Nisetegami.layouts_path, layout_html)
  end

  def layout_text_path
    layout_text && File.join(Nisetegami.layouts_path, layout_text)
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
        meths = Nisetegami::Utils.liquid_methods_for(Nisetegami.cast[thing])
        array << (meths.blank? ? variable.to_sym : { variable.to_sym => meths })
      end
    end
  end

  def mailer
    @_mailer ||= self[:mailer].constantize
  rescue NameError
  end

  CONTENT.each do |attribute|
    define_method "#{attribute}=" do |raw|
      self[attribute] = raw.blank? ? nil : raw
    end

    define_method "render_#{attribute}" do |variables|
      return nil unless self.send("prepared_#{attribute}")
      view = ActionView::Base.new(nil, variables.stringify_keys.select { |k, v| k.in?(variable_names) }, nil, nil)
      template_handler_for(attribute).new(view).render(send("prepared_#{attribute}"))
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

  def prepared_subject
    subject
  end

  def prepared_body_text
    body_text
  end

  def prepared_body_html
    !only_text? && body_html.blank? ? body_text : body_html
  end

  def template_handler_for(attribute)
    key = attribute == :body_html && !only_text? && body_html.blank? ? :liquid_with_markdown : :liquid
    ActionView::Template.registered_template_handler(key)
  end

  private

  def associated_stylesheets
    @@asset_provider ||= Nisetegami::AssetProvider.new(Roadie.current_provider.prefix)
    stylesheets = [:default]
    stylesheets << layout_html unless layout_html.blank?
    stylesheets.map! { |s| File.join('nisetegami', s.to_s) }
    stylesheets.select { |s| @@asset_provider.exists?(s) }
  end

  def check_mailer
    errors.add(:mailer, :undefined) if !mailer || !mailer.ancestors.include?(ActionMailer::Base)
    errors.add(:action, :undefined) if mailer && !mailer.action_methods.include?(action.to_s)
  end

  def check_template_syntax
    CONTENT.each { |attribute| try_parse_template(attribute) }
  end

  def try_parse_template(attribute)
    Liquid::Template.parse send("prepared_#{attribute}")
  rescue Liquid::SyntaxError => error
    errors.add(attribute, :liquid_syntax_error, message: error.message)
    false
  end

  def set_name_if_necessary
    self.name = "#{mailer}##{action}" if name.blank?
  end

  def clear_ar_template_resolver_cache
    Nisetegami::ARTemplateResolver.instance.clear_cache_for(mailer.to_s, action)
    true
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

