#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Nisetegami'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

namespace :tddium do
  desc "tddium environment db setup task"
  task :db_hook do
    system("cd spec/dummy/config && cp database.tddium.yml database.yml")
    Rake::Task["db:create:all"].invoke
    if File.exists?(File.join(Rails.root, "db", "schema.rb"))
      Rake::Task['db:schema:load'].invoke
    else
      Rake::Task['db:migrate'].invoke
    end
  end
end

desc 'Default: Run all specs.'
task default: :spec
