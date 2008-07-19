#!/usr/bin/ruby

###
### $Release: $
### $Copyright$
###

require 'rubygems'

spec = Gem::Specification.new do |s|
  ## package information
  s.name        = "editorkicker"
  s.author      = "$Author$"
  s.email       = "$Email$"
  s.rubyforge_project = 'editorkicker'
  s.version     = "$Release$"
  s.platform    = Gem::Platform::RUBY
  s.homepage    = "http://editorkicker.rubyforge.org/"
  s.summary     = "a pretty tool to invoke your favorite editor when error raised"
  s.description = <<-'END'
  EditorKicker is a pretty tool to invoke your favorite editor and open
  errored file automatically when error raised in your script.
  END

  ## files
  files = []
  files += Dir.glob('lib/*')
  files += %W[README.txt CHANGES.txt MIT-LICENSE setup.rb #{s.name}.gemspec]
  files += Dir.glob('plugin/**/*')
  #files += Dir.glob('doc-api/**/*')
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
  Gem::manage_gems
  Gem::Builder.new(spec).build
end
