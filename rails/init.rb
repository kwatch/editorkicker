
if defined?(RAILS_ENV) && RAILS_ENV == 'development'

  require 'editor_client'

  module ::EditorClient

    class RailsHandler < BaseHandler

      ## detect filepath and linenum
      def detect_location(exception)
        ex = exception.dup
        ex.set_backtrace(exception.application_backtrace)
        return super(ex)
      end

    end

    self.handler = RailsHandler.new

  end


  module ::ActionController   #:nodoc:
    module Rescue   #:nodoc:
      protected

      alias _rescue_action_locally_orig rescue_action_locally   #:nodoc:

      def rescue_action_locally(exception)  # :nodoc:
        ret = _rescue_action_locally_orig(exception) # call original
        ::EditorClient.handle(exception)
        ret
      end

    end
  end

  ::ActionController::Base.new.logger.info("** [EditorClient] loaded.")

end
