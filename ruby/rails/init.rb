
if defined?(RAILS_ENV) && RAILS_ENV == 'development'

  require 'editor_kicker'

  module ::EditorKicker

    class RailsErrorHandler < ErrorHandler

      ## detect filepath and linenum
      def detect_location(error)
        err = error.dup
        err.set_backtrace(error.application_backtrace)
        return super(err)
      end

    end

    self.handler = RailsErrorHandler.new

  end


  module ::ActionController   #:nodoc:
    module Rescue   #:nodoc:
      protected

      alias _rescue_action_locally_orig rescue_action_locally   #:nodoc:

      def rescue_action_locally(error)  # :nodoc:
        ret = _rescue_action_locally_orig(error) # call original
        ::EditorKicker.handle_error(error)
        ret
      end

    end
  end

  ::ActionController::Base.new.logger.info("** [EditorKicker] loaded.")

end
