Nisetegami.configure do |config|
  # Cast variables types
  # config.cast do |klass|
  #   begin
  #     "#{klass}Decorator".constantize
  #   rescue
  #     klass
  #   end
  # end

  # config.auth_filter = -> { redirect_to main_app.root_path unless current_user && current_user.admin? }

  # Mailers mapping
  # config.register UserMailer, :user, :notice, post: Blog::Post, additional_attributes: Hash
end
