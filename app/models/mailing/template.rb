class Mailing::Template < ActiveRecord::Base

  self.table_name = :mailing_templates

  ## constants

  CONTENT = [:subject, :body_html, :body_text]
  HEADERS = [:cc, :bcc, :reply_to, :from]

  ## scopes

  scope :by_mailer, ->(mailer) { where(mailer: mailer.name) }
  scope :by_layout, ->(layout) { where(layout: layout) }
  scope :enabled,   where(enabled: true)
  scope :disabled,  where(enabled: false)
  scope :html,      where(only_text: false)
  scope :text,      where(only_text: true)

  ## validations

  validates_format_of :from, :reply_to, :cc, :bcc, with: Mailing.addresses_regexp, allow_blank: true
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
  # default layout using Mailing settings.
  def layout_html_path
    layout = self.layout_html || Mailing.default_html_layout
    layout && File.join(Mailing.layouts_path, layout)
  end

  # Returns a full text layout path for +self+.
  # If layout does not specified, fallbacks to the
  # default layout using Mailing settings.
  def layout_text_path
    layout = self.layout_text || Mailing.default_text_layout
    layout && File.join(Mailing.layouts_path, layout)
  end

  # Returns a mapping for +self+, as a Hash.
  def mapping
    @_mapping ||= ::Mailing.mapping.lookup(mailer, action)
  end

  # Returns a list of variables for +self+,
  # using a Mailing::Mapping definitions.
  def variable_names
    @_variable_names ||= mapping.keys
  end

  def variable_mapping
    @_variable_mapping ||= ::Mailing.mapping.expand_variables(mapping) do |expand_chain|
      if expand_chain.size == 1
        expand_chain[0].to_sym
      else
        expand_chain.reverse.inject(nil) { |a, n| a.nil? ? n : { n => a } }
      end
    end.flatten
  end

  def mailer
    @_mailer ||= self[:mailer].constantize
  end

  CONTENT.each do |attribute|
    class_eval <<-TEMPLATES
      def #{attribute}=(raw)
        self[:#{attribute}] = raw.blank? ? nil : raw
        @#{attribute}_template = nil
      end

      def render_#{attribute}(*variables)
        return nil unless self[:#{attribute}]
        @#{attribute}_template = try_parse_template(:#{attribute}) if @#{attribute}_template.nil? # do not parse invalid templates
        @#{attribute}_template.render prepare_locals(*variables) if @#{attribute}_template
      end
    TEMPLATES
  end

  def mailing_options(recipient, *variables)
    options = {to: recipient, subject: self.render_subject(*variables)}
    HEADERS.each do |header|
      options[header] = self[header] unless self[header].blank?
    end
    options
  end

  def message(recipient, *variables)
    return nil unless valid?
    self.mailer.testing(self.action, recipient, *variables)
  end

  def test_message(recipient, variables_hash)
    message(recipient, *hash_to_mashes(variables_hash)).deliver
  end

  private

  def hash_to_mashes(hash)
    hash.each_with_object([]) do |(_, value), variables|
      variables << (value.respond_to?(:keys) ? Hashie::Mash.new(value) : value)
    end
  end

  def prepare_locals(*variables)
    Hash[variable_names.zip(variables)]
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
# Table name: mailing_templates
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
#  index_mailing_templates_on_mailer_and_action  (mailer,action) UNIQUE
#

