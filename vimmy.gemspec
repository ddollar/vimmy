# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vimmy/version"

Gem::Specification.new do |s|
  s.name        = "vimmy"
  s.version     = Vimmy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "David Dollar"
  s.email       = "ddollar@gmail.com"
  s.homepage    = "http://github.com/ddollar/vimmy"
  s.summary     = "Manage vim plugins using pathogen"
  s.description = s.summary

  s.rubyforge_project = "vimmy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "mechanize", "~> 1.0.0"
  s.add_dependency "thor",      "~> 0.14.6"
end
