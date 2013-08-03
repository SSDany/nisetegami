$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "nisetegami/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "nisetegami"
  s.version     = Nisetegami::VERSION
  s.authors     = ["Denis Lifanov", "Dmitry Afanasyev"]
  s.email       = ["inadsence@gmail.com", "dimarzio1986@gmail.com"]
  s.homepage    = "https://github.com/icrowley/nisetegami"
  s.summary     = "ActiveRecord/Liquid-based mail templates, incl. CSS-processing."
  s.description = s.summary

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'rails',  '~> 3.2'
  s.add_dependency 'roadie', '>= 2.3.1'
  s.add_dependency 'liquid'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rails', '~> 3.2'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
end
