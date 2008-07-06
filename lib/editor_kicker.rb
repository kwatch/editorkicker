###
### $Rev$
### $Release: $
### $Copyright$
###

##
## Open errored file by emacsclient.
##
## Don't forget to do `M-x server-start' in your Emacs.
##
module EditorKicker

  def self.handle_exception(exception)
    self.handler.handle(exception)
  end

  def self.handler
    @@handler
  end

  def self.handler=(handler)
    @@handler = handler
  end

  class ExceptionHandler

    def initialize
      bin = '/Applications/Emacs.app/Contents/MacOS/bin/emacsclient'
      @emacsclient = ENV['EMACSCLIENT'] || (File.exist?(bin) ? bin : "emacsclient")
      @kicker = self   # you can set Proc object to @kicker
      @verbose = true
    end

    attr_accessor :emacsclient, :kicker, :verbose

    ## detect error location from exception and open related file
    def handle(exception)
      filepath, linenum = detect_location(exception)
      kick(filepath, linenum) if filepath && linenum
    end

    ## get filename and linenum from exception
    def detect_location(exception)
      filepath = linenum = nil
      backtrace = exception.backtrace
      if backtrace && backtrace.first
        if backtrace.first =~ /^(.+):(\d+):in `.+'/
          filepath, linenum = $1, $2.to_i
        end
      elsif exception.is_a?(SyntaxError)
        if exception.to_s =~ /^(.+):(\d+): syntax error,/
          filepath, linenum = $1, $2.to_i
        end
      end
      return filepath, linenum
    end

    ## open file by emacsclient (or other)
    def kick(filepath, linenum)
      if File.exists?(filepath)
        @kicker.call(filepath, linenum)
      else
        log("#{filepath}: not found.") if @verbose
      end
    end

    ## default activity of kick()
    def call(filepath, linenum)
      #format = ENV['EDITOR_KICKER_COMMAND'] || "#{@emacsclient} -n +%2$s '%1$s'"
      #command = format % [filepath, linenum]
      format = ENV['EDITOR_KICKER_COMMAND'] || "#{@emacsclient} -n +%s '%s'"
      command = format % [linenum, filepath]
      log(command) if @verbose
      `#{command}`
    end

    def log(message)
      $stderr.puts "** [EditorKicker] #{message}"
    end

  end

  self.handler = ExceptionHandler.new

end
