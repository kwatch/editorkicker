###
### $Rev$
### $Release: $
### $Copyright$
###

##
## Open errored file by emacsclient.
##
## - Don't forget to do `M-x server-start' in your Emacs.
##
## - If you want to specify emacsclient command name, set
##   <tt>RoR::OpenErrfile.handler.emacsclient = '...emacsclient command path...'</tt>.
##
## - If you want to customize command to open file by your favorite editor, set
##   <tt>RoR::OpenErrfile.handler.command = proc {|filepath, linenum| ... }</tt>
##   or set environment variable $OPEN_ERRFILE_COMMAND
##   (ex. <tt>export OPEN_ERRFILE_COMMAND="emacsclient -n +%s '%s'"</tt>).
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

  class DefaultHandler

    def initialize
      bin = '/Applications/Emacs.app/Contents/MacOS/bin/emacsclient'
      @emacsclient = ENV['EMACSCLIENT'] || (File.exist?(bin) ? bin : "emacsclient")
      @command = self   # you can set Proc object to @command
    end

    attr_accessor :emacsclient, :command

    ## detect error location from exception and open related file
    def handle(exception)
      filepath, linenum = detect_location(exception)
      @command.call(filepath, linenum) if filepath && linenum
    end

    ## detect filepath and linenum
    def detect_location(exception)
      filepath = linenum = nil
      backtrace = exception.application_backtrace
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
        $stderr.puts "** OpenErrfile: #{filepath}: not found."
        return
      end
      #format = ENV['OPEN_ERRFILE_COMMAND'] || "#{@emacsclient} -n +%2$ss '%1$s'"
      #command = format % [filepath, linenum]
      format = ENV['OPEN_ERRFILE_COMMAND'] || "#{@emacsclient} -n +%s '%s'"
      command = format % [linenum, filepath]
      $stderr.puts "** OpenErrfile: #{command}"
      `#{command}`
    end

  end

  self.handler = DefaultExceptionHandler.new

end
