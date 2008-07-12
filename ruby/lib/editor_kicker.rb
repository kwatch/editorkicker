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
      bin = '/Applications/TextMate.app/Contents/Resources/mate'
      @command = ENV['EDITOR_KICKER'] || \
                 (test(?f, bin) ? "#{bin} -l %s '%s'" : "emacsclient -n +%s '%s'")
                 #(test(?f, bin) ? "#{bin} -l " : "emacsclient -n +") + "%2$s '%1$s'"
      @kicker = self   # you can set Proc object to @kicker
    end

    attr_accessor :command, :kicker

    ## detect error location from error and open related file
    def handle(error)
      filepath, linenum = detect_location(error)
      kick(filepath, linenum) if filepath && linenum
    end

    ## get filename and linenum from error
    def detect_location(error)
      filepath = linenum = nil
      backtrace = error.backtrace
      if backtrace && !backtrace.empty?
        if backtrace.find {|s| s =~ /^(.+):(\d+):in `.+'/ && File.writable?($1) }
          filepath, linenum = $1, $2.to_i
        end
      elsif error.is_a?(SyntaxError)
        if error.to_s =~ /^(.+):(\d+): syntax error,/
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
    def call(filepath, linenum)     # should separate to a class?
      command = @command % [linenum, filepath]  # or [filepath, linenum]
      log(command)
      `#{command}`
    end

    def log(message)
      $stderr.puts "** [EditorKicker] #{message}"
    end

  end

  self.handler = ErrorHandler.new

end
