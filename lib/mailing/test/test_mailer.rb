class Mailing::TestMailer < ActionMailer::Base

  def simple(fox, dog)
    render_template 'user@example.org', fox, dog
  end

end