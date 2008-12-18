##
## Invoke your favorite editor when you click line number links on error page.
##
## Usage:
## 1. Add "dependency 'merb_editorkicker'" into 'config/dependencies.rb'.
## 2. Set ENV['EDITOR_KICKER'] in 'config/environments/development.rb'.
##
## Example:
##   ENV['EDITOR_KICKER'] = "/Applications/TextMate.app/Contents/Resources/mate -l %s %s"   # for TextMate
##   ENV['EDITOR_KICKER'] = "emacsclient -n +%s %s"    # for Emacs (Don't forget M-x server-start)
##   ENV['EDITOR_KICKER'] = "netbeans %2$s:%1$s"       # for NetBeans
##   ENV['EDITOR_KICKER'] = "java -jar eclipsecall.jar %2$s -G%1$s"  # for EclipseCall plugin
##   ENV['EDITOR_KICKER'] = "open %2$s"                # other
##
## Notice:
## This plug-in works only under development mode.
## So you can commit this plug-in files into your app repository with no problem.
##


if Merb.environment == "development"


  ## cf. merb-action-args-0.9.14/lib/merb-action-args/abstract_controller.rb
  module ActionArgumentListModule_

    def action_argument_list
      klass = self
      Hash.new do |h,k|
        args = klass.instance_method(k).get_args
        arguments = args[0]
        defaults = []
        arguments.each {|a| defaults << a[0] if a.size == 2} if arguments
        h[k] = [arguments || [], defaults]
      end
    end

  end


  ## cf.  merb-core-0.9.14/lib/merb-core/dispatch/default_exception/default_exception.rb
  Merb::BootLoader.after_app_loads do

    class Merb::Dispatcher

      class DefaultException
        extend(ActionArgumentListModule_)  # define class method
      end

      module DefaultExceptionHelper

        def textmate_url(filename, line)
          #"<a href='txmt://open?url=file://#{filename}&amp;line=#{line}'>#{line}</a>"
          if ENV['EDITOR_KICKER'].blank?
            html = "<a href='txmt://open?url=file://#{filename}&amp;line=#{line}'>#{line}</a>"
          else
            url = "/invoke_editor?filename=#{filename}&line=#{line}"
            js = ""
            js << "var xhr=new XMLHttpRequest();"  # IE6 is not supported
            js << "xhr.open('GET',this.href,true);"
            js << "xhr.send(null);"
            js << "return false;"
            style = "font-style:italic"
            html = "<a href=\"#{url}\" onclick=\"#{js}\" style=\"#{style}\">#{line}</a>"
          end
          html
        end

        def render_source(filename, line)
          line = line.to_i
          ret   =  []
          ret   << "<tr class='source'>"
          ret   << "  <td class='collapse'></td>"
          str   =  "  <td class='code' colspan='2'><div>"

          __caller_lines__(filename, line, 5) do |lline, lcode|
            #str << "<a href='txmt://open?url=file://#{filename}&amp;line=#{lline}'>#{lline}</a>"
            str << textmate_url(filename, lline)
            str << "<em>" if line == lline
            str << Erubis::XmlHelper.escape_xml(lcode)
            str << "</em>" if line == lline
            str << "\n"
          end
          str   << "</div></td>"
          ret   << str
          ret   << "</tr>"
          ret.join("\n")
        end

      end

    end

  end


  class InvokeEditor < Merb::Controller
    extend(ActionArgumentListModule_)  # define class method

    def index
      filename, line = params[:filename], params[:line]
      unless filename.blank? || line.blank?
        #command = _command() % [line, filename.gsub(/'/, '\\\\\'')]
        command = ENV['EDITOR_KICKER'] % [line, filename.gsub(/'/, '\\\\\'')]
        Merb.logger.debug "*** InvokeEditor: command=#{command.inspect}"
        system(command)
      end
      ""
    end

    #private
    #
    #def _command()
    #  command = ENV['EDITOR_KICKER']
    #  return command if command
    #  mate = '/Applications/TextMate.app/Contents/Resources/mate'
    #  return "#{bin} -l %s %s" if File.exist?(mate)  # for TextMate
    #  return "emacsclient -n +%s %s"                 # for Emacs (M-x server-start)
    #  #socket = "/tmp/emacs501/server"
    #  #return "emacsclient -n -s #{socket} +%s %s" if File.exist?(socket)
    #  #return "open %2$s"
    #end

  end


end
