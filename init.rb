
if defined?(RAILS_ENV) && RAILS_ENV == 'development'

  require 'ror/open_errfile'

  module ::ActionController   #:nodoc:
    module Rescue   #:nodoc:
      protected

      alias _rescue_action_locally_orig rescue_action_locally   #:nodoc:

      def rescue_action_locally(exception)  # :nodoc:
        ret = _rescue_action_locally_orig(exception) # call original
        RoR::OpenErrfile.handle(exception)
        ret
      end

    end
  end

  ::ActionController::Base.new.logger.info("** RoR::OpenErrfile loaded.")

end
