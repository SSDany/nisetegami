if defined?(::FactoryGirl)

  FactoryGirl.define do
    factory :simple_nisetegami_template, class: 'Nisetegami::Template' do

      mailer    "Nisetegami::TestMailer"
      sequence(:action) { |n| "simple_#{n}" }

      layout_text "default"
      layout_html "default"
      subject     "subject"
      body_text   "body (text)"
      body_html   "body (html)"

      after(:build) do |template|
        Nisetegami::TestMailer.action_methods << template.action.to_sym
        Nisetegami::TestMailer.send :alias_method, template.action.to_sym, :simple
        Nisetegami.configure { |c| c.register template[:mailer], template.action, fox: 'String', dog: 'String' }
      end

    end

    factory :simple_nisetegami_liquid_template, parent: :simple_nisetegami_template do
      handler   "liquid"
      subject   "The quick brown {{ fox }} jumps over the lazy {{ dog }}."
      body_text "The quick brown {{ fox }} jumps over the lazy {{ dog }}."
      body_html "The quick brown {{ fox }} jumps over the lazy {{ dog }}."
    end

    factory :simple_nisetegami_erb_template, parent: :simple_nisetegami_template do
      handler   "erb"
      subject   "The quick brown <%= @fox %> jumps over the lazy <%= @dog %>."
      body_text "The quick brown <%= @fox %> jumps over the lazy <%= @dog %>."
      body_html "The quick brown <%= @fox %> jumps over the lazy <%= @dog %>."
    end
  end
end
