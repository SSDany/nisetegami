if defined?(::FactoryGirl)

  FactoryGirl.define do
    factory :simple_mailing_template, class: 'Mailing::Template' do

      mailer    "Mailing::TestMailer"
      sequence(:action) { |n| "simple_#{n}" }

      subject   "The quick brown {{ fox }} jumps over the lazy {{ dog }}."
      body_text "The quick brown {{ fox }} jumps over the lazy {{ dog }}."
      body_html "The quick brown {{ fox }} jumps over the lazy {{ dog }}."
      layout_text "default"
      layout_html "default"

      after(:build) do |template|
        Mailing::TestMailer.action_methods << template.action.to_sym
        Mailing::TestMailer.send :alias_method, template.action.to_sym, :simple
        Mailing.configure { |c| c.register template[:mailer], template.action, fox: 'String', dog: 'String' }
      end

    end
  end
end