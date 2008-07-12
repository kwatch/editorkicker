= README.txt for EditorKicker

Release: $Release$

$Copyright$

http://rubyforge.org/projects/editor-kicker/



== About

EditorKicker is a pretty utility to invoke your favorite editor
and open errored file when CGI script or Rails program cause error.



== Install

(for Ruby on Rails)

    $ ruby script/plugin install http://github.com/kwatch/editor-kicker.git/ruby/rails/plugin/editor_kicker

(for CGI/mod_ruby)

You must install cgi-exception library as well as EditorKicker.

    ## install EditorKicker
    $ cd /tmp
    $ wget http://rubyforge.org/projects/editor-kicker/.../editor_kicker
    $ tar xzf editor-kicker-XXX.tar.gz
    $ cd editor-kicker-XXX/
    $ sudo ruby install.rb
  
    ## install cgi-exception
    $ cd /tmp
    $ wget http://rubyforge.org/projects/cgi-exception
    $ tar xzf cgi-exception-XXX.tar.gz
    $ cd cgi-exception-XXX/
    $ sudo ruby install.rb

It is not recommended to install by RubyGems, because 'require rubygems'
is an heavy-weight operation for CGI.



== Usage

ATTENTION!  Don't forget to call 'M-x server-start' if you're Emacs user.

(for Ruby on Rails)

    $ export EDITOR_KICKER="mate -n %s '%s'"             (for TextMate)
    $ export EDITOR_KICKER="emacsclient -n +%s '%s'"     (for Emacs)
    $ ruby script/server          # development mode

Setting of $EDITOR_KICKER is optional. If $EDITOR_KICKER is not set,
EditorKicker will detect TextMate or Emacs automatically.

(for CGI/mod_ruby)

    #!/usr/bin/env ruby
    require 'cgi'
    require 'cgi_exception'
  
    ### load and set up editor-kicker only when running in local machine
    if ENV['SERVER_NAME'] == 'localhost'
      require 'editor_kicker'
      ## for TextMate
      mate = '/Applications/TextMate.app/Contents/Resources/mate'
      ENV['EDITOR_KICKER'] = "#{mate} -l %s '%s'"
      ## for Emacs
      emacsclient = '/Applications/Emacs.app/Contents/MacOS/bin/emacsclient'
      ENV['EDITOR_KICKER'] = "#{emacsclient} -n -s /tmp/emacs501/server +%s '%s'"
    end
    
    cgi = CGI.new
    print cgi.header
    print "<h1>Hello</h1>"
    ...

If you're Emacs user, you have to make socket file (ex. /tmp/emacsXXX/server)
to be accessible by CGI/mod_ruby process.

    ### assume that CGI script is executed by 'daemon' user.
    $ chmod a+x /tmp/emacs501
    $ sudo chown daemon /tmp/emacs501/server



== Todo

* FastCGI support
* Rack support



== Author

$Author$

$Copyright$



== License

$License$
