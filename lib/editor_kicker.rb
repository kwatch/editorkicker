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
      bin = '/Applications/TextMate.app/Contents/Resources/mate'
      @command = ENV['EDITOR_KICKER'] || \
                 (test(?f, bin) ? "#{bin} -l %s '%s'" : "emacsclient -n +%s '%s'")
                 #(test(?f, bin) ? "#{bin} -l " : "emacsclient -n +") + "%2$s '%1$s'"
      @kicker = self   # you can set Proc object to @kicker
    end

    attr_accessor :command, :kicker

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

    ## open file with editor
    def kick(filepath, linenum)
      if File.exists?(filepath)
        @kicker.call(filepath, linenum)
      else
        log("#{filepath}: not found.")
      end
    end

    ## default activity of kick()
    def call(filepath, linenum)
      command = @command % [linenum, filepath]  # or [filepath, linenum]
      log(command)
      `#{command}`
    end

    def log(message)
      $stderr.puts "** [EditorKicker] #{message}"
    end

  end

  self.handler = ExceptionHandler.new

end
