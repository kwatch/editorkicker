##
## $Rev$
## $Release: 0.1.0 $
## Copyright 2008 kuwata-lab.com all rights reserved.
##

##
## Invoke your favorite editor and Open errored file by it.
##
## Don't forget to do `M-x server-start' if you use Emacs.
##
module EditorKicker

  def self.handle_exception(ex)
    self.handler.handle(ex)
  end

  class <<self
    alias handle handle_exception
  end

  def self.handler
    @@handler
  end

  def self.handler=(handler)
    @@handler = handler
  end

  class ExceptionHandler

    def initialize
      @kicker = self   # you can set Proc object to @kicker
      @writable_check = false
    end

    attr_accessor :command, :kicker, :writable_check

    ## detect error location from error and open related file
    def handle(ex)
      filepath, linenum = detect_location(ex)
      kick(filepath, linenum) if filepath && linenum
    end

    ## get filename and linenum from error
    def detect_location(ex, backtrace=nil)
      filepath = linenum = nil
      backtrace ||= ex.backtrace
      if backtrace && !backtrace.empty?
        tuple = nil
        if backtrace.find {|str| tuple = get_location(str) }
          filepath, linenum = tuple
        end
      #elsif ex.is_a?(SyntaxEx)
      #  if ex.to_s =~ /^(.+):(\d+): syntax error,/
      #    filepath, linenum = $1, $2.to_i
      #  end
      elsif ex.to_s =~ /\A(.+):(\d+): /  # for SyntaxError
        filepath, linenum = $1, $2.to_i
      end
      return filepath, linenum
    end

    ## get filepath and linenum from string
    def get_location(str)
      return nil if str !~ /^(.+):(\d+)(:in `.+'|$)/
      return nil if @writable_check && !File.writable?($1)
      return [$1, $2.to_i]
    end

    ## detect command to invoke editor
    def detect_command
      command = ENV['EDITOR_KICKER']
      return command if command
      bin = '/Applications/TextMate.app/Contents/Resources/mate'
      return "#{bin} -l %s '%s'" if test(?f, bin)
      return "emacsclient -n +%s '%s'"
    end

    ## open file with editor
    def kick(filepath, linenum)
      if File.exists?(filepath)
        @kicker.call(filepath, linenum)
      else
        log("#{filepath}: not found.")
      end
    end

    ## default activity of kick()
    def call(filepath, linenum)     # should separate to a class?
      command = (@command || detect_command()) % [linenum, filepath]  # or [filepath, linenum]
      log(command)
      `#{command.untaint}`
    end

    def log(message)
      $stderr.puts "** [EditorKicker] #{message}"
    end

  end

  self.handler = ExceptionHandler.new

end
