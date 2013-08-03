class Nisetegami::TestMailer < ActionMailer::Base
  default from: 'admin@domain.com'

  def simple(fox, dog)
    @fox = fox
    @dog = dog
    mail to: 'user@example.com'
  end
end
