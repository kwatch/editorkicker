#!/usr/bin/ruby

###
### $Release: $
### $Copyright$
###

require 'rubygems'
require 'rubygems/gem_runner'

spec = Gem::Specification.new do |s|
  ## package information
  s.name        = "merb_editorkicker"
  s.author      = "$Author$"
  s.email       = "$Email$"
  s.version     = "$Release$"
  s.rubyforge_project = "editorkicker"
  s.platform    = Gem::Platform::RUBY
  s.homepage    = "http://editorkicker.rubyforge.org/"
  s.summary     = "a pretty tool to invoke your favorite editor when error raised"
  s.description = <<-'END'
  merb_editorkicker is a Merb plug-in to enable you to invoke your favorite
  editor when you click line number link on Merb error page.
  END

  ## files
  files = []
  files += Dir.glob('lib/*')
  files += %W[README.txt MIT-LICENSE setup.rb #{s.name}.gemspec]
  s.files       = files
end

# Quick fix for Ruby 1.8.3 / YAML bug   (thanks to Ross Bamford)
if (RUBY_VERSION == '1.8.3')
  def spec.to_yaml
    out = super
    out = '--- ' + out unless out =~ /^---/
    out
  end
end

if $0 == __FILE__
  #Gem::manage_gems
  Gem::Builder.new(spec).build
end
