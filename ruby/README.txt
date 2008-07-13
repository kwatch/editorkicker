= README.txt for EditorKicker

Release: $Release$

$Copyright$

http://rubyforge.org/projects/editorkicker/



== About

EditorKicker is a pretty utility to invoke your favorite editor
and open errored file when CGI script or Rails program cause error.



== Install

(for Ruby on Rails)

    $ ruby script/plugin install http://github.com/kwatch/editorkicker.git/ruby/plugin/rails/editorkicker

(for CGI/mod_ruby)

You must install cgi-exception library as well as EditorKicker.

    ## install EditorKicker
    $ sudo gem install editorkicker
    ## or
    $ cd /tmp
    $ wget http://rubyforge.org/projects/editorkicker/.../editorkicker-XXX.tar.gz
    $ tar xzf editorkicker-XXX.tar.gz
    $ cd editorkicker-XXX/
    $ sudo ruby install.rb
  
    ## install cgi-exception
    $ sudo gem install cgi-exception
    ## or
    $ cd /tmp
    $ wget http://rubyforge.org/projects/cgi-exception
    $ tar xzf cgi-exception-XXX.tar.gz
    $ cd cgi-exception-XXX/
    $ sudo ruby install.rb

It is not recommended to install by RubyGems, because 'require rubygems'
is an heavy-weight operation for CGI.



== Setup

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
    $ chmod 666 /tmp/emacs501/server
    $ sudo chown daemon /tmp/emacs501/server



== Trouble shooting


=== (Emacs) can't find socket

Error:

  emacsclient: can't find socket; have you started the server?
  To start the server in Emacs, type "M-x server-start".

Solution:

Type 'M-x server start' in your Emacs.
In addition if you are CGI user, set $EDITOR_KICKER environment variable
to "emacsclient -n -s /tmp/emacs501/server +%s '%s'" to specify socket
file by '-s' option.
(Notice that '-s' optio of emacsclient is available from Emacs 22.)



== Todo

* FastCGI support
* Merb support
* Mack support



== Author

$Author$ <$Email$>

$Copyright$



== License

$License$
