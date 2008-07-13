###
### $Rev$
### $Release: $
### $Copyright$
###

##
## Open errored file by emacsclient.
##
## Don't forget to do `M-x server-start' if you use Emacs.
##
module EditorKicker

  def self.handle_error(error)
    self.handler.handle(error)
  end

  def self.handler
    @@handler
  end

  def self.handler=(handler)
    @@handler = handler
  end

  class ErrorHandler

    def initialize
      @kicker = self   # you can set Proc object to @kicker
      @check_writable = false
    end

    attr_accessor :command, :kicker, :check_writable

    ## detect error location from error and open related file
    def handle(error)
      filepath, linenum = detect_location(error)
      kick(filepath, linenum) if filepath && linenum
    end

    ## get filename and linenum from error
    def detect_location(error, backtrace=nil)
      filepath = linenum = nil
      backtrace ||= error.backtrace
      $stderr.puts "*** debug: backtrace=#{backtrace.inspect}"
      
      if backtrace && !backtrace.empty?
        tuple = nil
        if backtrace.find {|str| tuple = get_location(str) }
          filepath, linenum = tuple
        end
      elsif error.is_a?(SyntaxError)
        if error.to_s =~ /^(.+):(\d+): syntax error,/
          filepath, linenum = $1, $2.to_i
        end
      end
      return filepath, linenum
    end

    ## get filepath and linenum from string
    def get_location(str)
      return nil if str !~ /^(.+):(\d+)(:in `.+'|$)/
      return nil if @check_writable && !File.writable?($1)
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

  self.handler = ErrorHandler.new

end
