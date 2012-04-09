ENV["RAILS_ENV"] = "test"
Bundler.require(:development)
Dir.chdir(File.expand_path("../dummy", __FILE__)) { require File.expand_path("config/environment") }

require 'rspec/rails'

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')

Dir[File.join(ENGINE_RAILS_ROOT, 'spec/support/**/*.rb')].each { |f| require f }
require 'mailing/test'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end