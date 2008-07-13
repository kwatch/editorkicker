
if defined?(RAILS_ENV) && RAILS_ENV == 'development'

  require 'editor_kicker'

  module ::EditorKicker

    class RailsErrorHandler < ErrorHandler

      def initialize(*args)
        super
        self.check_writable = true
      end

      ## detect filepath and linenum
      def detect_location(error, backtrace=nil)
        if error.is_a?(ActionView::TemplateError)
          # assert error.respond_to?(:file_name)
          # assert error.respond_to?(:line_number)
          filepath, linenum = error.file_name, error.line_number
          if filepath && linenum
            filepath = "app/views/#{filepath}" unless filepath[0] == ?/ || filepath =~ /\Aapp\/views\//
            return filepath, linenum
          end
        end
        # assert error.respond_to?(:application_backtrace)
        return super(error, error.application_backtrace)
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
