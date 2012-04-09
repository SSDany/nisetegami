$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mailing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mailing-templates"
  s.version     = MailingTemplates::VERSION
  s.authors     = ["Denis Lifanov, Dmitry Afanasyev"]
  s.email       = ["inadsence@gmail.com", "dimarzio1986@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "Mailing Templates."
  s.description = "Liquid-based mailing templates, incl. CSS-processing."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency 'rails',   '~> 3.2.2'
  s.add_dependency 'roadie',  '>= 2.3.1'
  s.add_dependency 'liquid'

  s.add_development_dependency "sqlite3"
end
