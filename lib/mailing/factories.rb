if defined?(::Factory)

  Factory.define :simple_mailing_template, class: 'Mailing::Template' do |f|

    f.mailer    "TestMailer"
    f.action    "test"
    f.body_html "The quick brown {{ fox }} jumps over the lazy {{ dog }}."
    f.body_text "The quick brown {{ fox }} jumps over the lazy {{ dog }}."
    f.subject   "The quick brown {{ fox }} jumps over the lazy {{ dog }}."

    f.after_build do |template|
      Mailing.configure { |c| c.register template[:mailer], template.action, fox: 'String', dog: 'String' }
    end

  end
end


#class TestMailer < ActionMailer::Base
#  def test(fox, dog)
#    render_template 'user@example.org', fox, dog
#  end
#end
