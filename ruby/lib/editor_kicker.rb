##
## $Rev$
## $Release: $
## $Copyright$
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


  def self.writable_check
    return ExceptionHandler.writable_check
  end
  def self.writable_check=(flag)
    ExceptionHandler.writable_check = flag
  end

  def self.user_id
    return ExceptionHandler.user_id
  end
  def self.user_id=(user_id)
    ExceptionHandler.user_id = user_id
  end


  class ExceptionHandler

    @@writable_check = false  # don't check writable permission
    def self.writable_check
      @@writable_check
    end
    def self.writable_check=(flag)
      @@writable_check = flag
    end

    @@user_id = 501    # default unix user id
    def self.user_id
      @@user_id
    end
    def self.user_id=(user_id)
      @@user_id = user_id
    end

    def initialize
      @kicker = self   # you can set Proc object to @kicker
      @writable_check = @@writable_check
      @user_id = @@user_id
    end

    attr_accessor :command, :kicker, :writable_check, :user_id

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
      #elsif ex.is_a?(SyntaxError)
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
      return nil unless str =~ /^(.+):(\d+)(:in `.+'|$)/
      return nil unless File.exist?($1)
      return nil unless @writable_check && File.writable?($1) ||
                        @user_id && File.stat($1).uid == @user_id
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
