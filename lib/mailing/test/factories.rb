if defined?(::Factory)

  Factory.define :simple_mailing_template, class: 'Mailing::Template' do |f|

    f.mailer    "Mailing::TestMailer"
    f.sequence(:action) { |n| "simple_#{n}" }

    f.subject   "The quick brown {{ fox }} jumps over the lazy {{ dog }}."
    f.body_text "The quick brown {{ fox }} jumps over the lazy {{ dog }}."
    f.body_html "The quick brown {{ fox }} jumps over the lazy {{ dog }}."

    f.after_build do |template|
      Mailing::TestMailer.action_methods << template.action.to_sym
      Mailing::TestMailer.send :alias_method, template.action.to_sym, :simple
      Mailing.configure { |c| c.register template[:mailer], template.action, fox: 'String', dog: 'String' }
    end

  end
end