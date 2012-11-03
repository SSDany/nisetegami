class Mailing::TestMailer < ActionMailer::Base

  def simple(fox, dog)
    @fox = fox
    @dog = dog
    mail to: 'user@example.com'
  end

end