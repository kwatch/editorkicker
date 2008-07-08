
if defined?(RAILS_ENV) && RAILS_ENV == 'development'

  require 'editor_kicker'

  module ::EditorKicker

    class RailsExceptionHandler < ExceptionHandler

      ## detect filepath and linenum
      def detect_location(exception)
        ex = exception.dup
        ex.set_backtrace(exception.application_backtrace)
        return super(ex)
      end

    end

    self.handler = RailsExceptionHandler.new

  end


  module ::ActionController   #:nodoc:
    module Rescue   #:nodoc:
      protected

      alias _rescue_action_locally_orig rescue_action_locally   #:nodoc:

      def rescue_action_locally(exception)  # :nodoc:
        ret = _rescue_action_locally_orig(exception) # call original
        ::EditorKicker.handle_exception(exception)
        ret
      end

    end
  end

  ::ActionController::Base.new.logger.info("** [EditorKicker] loaded.")

end
