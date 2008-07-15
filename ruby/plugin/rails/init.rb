##
## $Rev$
## $Release: $
## $Copyright$
##

##
## Notice that this plugin is loaded only when in development mode.
## So you can commit this plugin into your Rails app repository.
##

if defined?(RAILS_ENV) && RAILS_ENV == 'development'

  require 'editor_kicker'

  module ::EditorKicker

    class RailsExceptionHandler < ExceptionHandler

      def initialize(*args)
        super
        self.writable_check = true
      end

      ## detect filepath and linenum
      def detect_location(ex, backtrace=nil)
        if ex.is_a?(ActionView::TemplateError)
          # assert ex.respond_to?(:file_name)
          # assert ex.respond_to?(:line_number)
          filepath, linenum = ex.file_name, ex.line_number
          if filepath && linenum
            filepath = "app/views/#{filepath}" unless filepath[0] == ?/ || filepath =~ /\Aapp\/views\//
            return filepath, linenum
          end
        end
        # assert ex.respond_to?(:application_backtrace)
        return super(ex, ex.application_backtrace)
      end

    end

    self.handler = RailsExceptionHandler.new

  end


  module ::ActionController   #:nodoc:
    module Rescue   #:nodoc:
      protected

      alias _rescue_action_locally_orig rescue_action_locally   #:nodoc:

      def rescue_action_locally(ex)  # :nodoc:
        ret = _rescue_action_locally_orig(ex) # call original
        ::EditorKicker.handle_exception(ex)
        ret
      end

    end
  end

  ::ActionController::Base.new.logger.info("** [EditorKicker] loaded.")

end
