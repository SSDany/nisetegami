require 'rails/railtie'

module Nisetegami
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/nisetegami_tasks.rake'
    end
  end
end
