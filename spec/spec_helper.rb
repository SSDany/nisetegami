require 'coveralls'
Coveralls.wear!

ENV['RAILS_ENV'] = 'test'
Bundler.require(:development)
require_relative 'dummy/config/environment'

require 'rspec/rails'

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')

Dir[File.join(ENGINE_RAILS_ROOT, 'spec/support/**/*.rb')].each { |f| require f }
require 'nisetegami/test'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
