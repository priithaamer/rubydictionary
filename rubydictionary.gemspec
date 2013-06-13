# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rubydictionary/version'

Gem::Specification.new do |s|
  s.name        = 'rubydictionary'
  s.version     = Rubydictionary::VERSION
  s.authors     = ['Priit Haamer']
  s.email       = ['priit@fraktal.ee']
  s.homepage    = 'https://github.com/priithaamer/rubydictionary'
  s.summary     = %q{Adds "rubydictionary" formatter to RDoc}
  s.description = %q{Builds dictionary files for Mac OS Dictionary.app of Ruby documentation using RDoc}

  s.rubyforge_project = 'rubydictionary'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  
  %w(rake).each do |gem|
    s.add_development_dependency *gem.split(' ')
  end
end
