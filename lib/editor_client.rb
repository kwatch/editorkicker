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
module EditorClient

  def self.handle(exception)
    self.handler.handle(exception)
  end

  def self.handler
    @@handler
  end

  def self.handler=(handler)
    @@handler = handler
  end

  class BaseHandler

    def initialize
      bin = '/Applications/Emacs.app/Contents/MacOS/bin/emacsclient'
      @emacsclient = ENV['EMACSCLIENT'] || (File.exist?(bin) ? bin : "emacsclient")
      @command = self   # you can set Proc object to @command
      @verbose = true
    end

    attr_accessor :emacsclient, :command, :verbose

    ## detect error location from exception and open related file
    def handle(exception)
      filepath, linenum = detect_location(exception)
      @command.call(filepath, linenum) if filepath && linenum
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
    def call(filepath, linenum)
      unless File.exists?(filepath)
        log("#{filepath}: not found.") if @verbose
        return
      end
      #format = ENV['EDITOR_CLIENT_COMMAND'] || "#{@emacsclient} -n +%2$ss '%1$s'"
      #command = format % [filepath, linenum]
      format = ENV['EDITOR_CLIENT_COMMAND'] || "#{@emacsclient} -n +%s '%s'"
      command = format % [linenum, filepath]
      log(command) if @verbose
      `#{command}`
    end

    def log(message)
      $stderr.puts "** [EditorClient] #{message}"
    end

  end

  self.handler = BaseHandler.new

end
