###
### $Rev$
### $Release: $
### $Copyright$
### $License$
###

dir = File.dirname(File.dirname(File.expand_path(__FILE__)))
$:.unshift File.join(dir, "spec")
$:.unshift File.join(dir, "lib")

require 'rubygems'
require 'spec'
require 'editor_kicker'

def `(str)    #`
  $stdout << str
end

ENV['EDITOR_KICKER'] = '<kicked: %s:%s>'


class String
  def write(arg)
    self << arg
  end
  def puts(arg)
    self << arg
    self << arg unless arg[-1] == ?\n
  end
end

def dummy_stdio
  begin
    $stdout = ''
    $stderr = ''
    yield $stdout, $stderr
  ensure
    $stdout = STDOUT
    $stderr = STDERR
  end
end


## TODO: change to portable data
err = ArgumentError.new('***dummy***')
backtrace = [
  "/usr/local/lib/ruby/gems/1.8/gems/rspec-1.1.4/lib/spec/example/example_group_methods.rb:46:in `module_eval'",
  "/usr/local/lib/ruby/gems/1.8/gems/rspec-1.1.4/lib/spec/example/example_group_methods.rb:46:in `describe'",
  "./spec/editor_kicker_spec.rb:9:in `raise_error'",
  "./spec/editor_kicker_spec.rb:51",
  "/usr/local/lib/ruby/gems/1.8/gems/rspec-1.1.4/lib/spec/extensions/class.rb:14:in `instance_eval'",
]
err.set_backtrace(backtrace)


describe "EditorKicker" do

  it "kicks command with filename and linenum" do
    dummy_stdio do |stdout, stderr|
      EditorKicker.handle_exception(err)
      stdout.should == "<kicked: 46:/usr/local/lib/ruby/gems/1.8/gems/rspec-1.1.4/lib/spec/example/example_group_methods.rb>"
      stderr.should == "** [EditorKicker] <kicked: 46:/usr/local/lib/ruby/gems/1.8/gems/rspec-1.1.4/lib/spec/example/example_group_methods.rb>\n"
    end
  end

  it "does nothing when file is not found." do
    err.set_backtrace([])
    dummy_stdio do |stdout, stderr|
      EditorKicker.handle_exception(err)
      stdout.should == ''
      stderr.should == ''
    end
    err.set_backtrace(backtrace)
  end

  it "ignores unwritable file when check_writable is true" do
    val = EditorKicker.handler.writable_check
    EditorKicker.handler.writable_check = true
    begin
      dummy_stdio do |stdout, stderr|
        EditorKicker.handle_exception(err)
        stdout.should == "<kicked: 9:./spec/editor_kicker_spec.rb>"
        stderr.should == "** [EditorKicker] <kicked: 9:./spec/editor_kicker_spec.rb>\n"
      end
    ensure
      EditorKicker.handler.writable_check = val
    end
  end

  it "selects file not in ENV['EDITOR_KICKER_EXCLUDE']" do
    dummy_stdio do |stdout, stderr|
      ENV['EDITOR_KICKER_EXCLUDE'] = '/usr/lib:/usr/local/lib:/opt/local'
      EditorKicker.handle_exception(err)
      stdout.should == "<kicked: 9:./spec/editor_kicker_spec.rb>"
      stderr.should == "** [EditorKicker] <kicked: 9:./spec/editor_kicker_spec.rb>\n"
    end
  end

  it "selects file in ENV['EDITOR_KICKER_INCLUDE']" do
    dummy_stdio do |stdout, stderr|
      ENV['EDITOR_KICKER_INCLUDE'] = '/usr/local/lib/ruby/gems/1.8/'
      ENV['EDITOR_KICKER_EXCLUDE'] = '/usr/lib:/usr/local/lib:/opt/local'
      EditorKicker.handle_exception(err)
      stdout.should == "<kicked: 46:/usr/local/lib/ruby/gems/1.8/gems/rspec-1.1.4/lib/spec/example/example_group_methods.rb>"
      stderr.should == "** [EditorKicker] <kicked: 46:/usr/local/lib/ruby/gems/1.8/gems/rspec-1.1.4/lib/spec/example/example_group_methods.rb>\n"
    end
  end

  it "does nothing when all file are excluded" do
    dummy_stdio do |stdout, stderr|
      ENV['EDITOR_KICKER_INCLUDE'] = nil
      ENV['EDITOR_KICKER_EXCLUDE'] = '/usr:./'
      EditorKicker.handle_exception(err)
      stdout.should == ''
      stderr.should == ''
    end
  end

  ENV['EDITOR_KICKER_INCLUDE'] = nil
  ENV['EDITOR_KICKER_EXCLUDE'] = nil


end
