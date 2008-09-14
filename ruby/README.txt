= README.txt for EditorKicker

Release: $Release$

http://editorkicker.rubyforge.org/
http://rubyforge.org/projects/editorkicker/



== About

EditorKicker is a pretty utility to invoke your favorite editor
and open errored file when CGI script or Rails program cause error.



== Install

(for Ruby on Rails)

    $ ruby script/plugin install http://github.com/kwatch/editorkicker.git/ruby/plugin/rails/editorkicker

(for CGI/mod_ruby)

You must install CGI-Exception library, too.

    ## install EditorKicker
    $ sudo gem install editorkicker
    ## or
    $ cd /tmp
    $ wget http://rubyforge.org/projects/editorkicker/.../editorkicker-$Release$.tar.gz
    $ tar xzf editorkicker-$Release$.tar.gz
    $ cd editorkicker-$Release$/
    $ sudo ruby install.rb
  
    ## install cgi-exception
    $ sudo gem install cgi-exception
    ## or
    $ cd /tmp
    $ wget http://rubyforge.org/projects/cgi-exception
    $ tar xzf cgi-exception-XXX.tar.gz
    $ cd cgi-exception-XXX/
    $ sudo ruby install.rb

It is not recommended to install libraries by RubyGems, because
'require rubygems' is an heavy-weight operation for CGI.



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
      ## for NetBeans
      netbeans = "#{ENV['HOME']}/netbeans-6.1/bin/netbeans"
      ENV['EDITOR_KICKER'] = "#{netbeans} --open %2$s:%1$s"
    end

    ## you can specify include and/or exclude path to find file.
    ENV['EDITOR_KICKER_INCLUDE'] = '/usr/local/lib/ruby/1.8/site_ruby:./lib'
    ENV['EDITOR_KICKER_EXCLUDE'] = '/usr/local/lib:/opt/local/lib'
    
    cgi = CGI.new
    print cgi.header
    print "<h1>Hello</h1>"
    ...

If you're Emacs user, you have to change owner of socket file
(ex. '/tmp/emacsXXX/server') to Apache's process user.

    ### assume that CGI script is executed by 'daemon' user.
    ### ('/tmp/emacs501/server' will be created by M-x server-strart)
    $ sudo chown -R daemon /tmp/emacs501



== Trouble shooting


=== (Emacs) can't find socket

Error:

  emacsclient: can't find socket; have you started the server?
  To start the server in Emacs, type "M-x server-start".

Solution:

Type 'M-x server start' in your Emacs.

In addition if you are CGI user, set ENV['EDITOR_KICKER'] environment variable
to "emacsclient -n -s /tmp/emacs501/server +%s '%s'" in your CGI script
to specify socket file by '-s' option.
(Notice that '-s' option of emacsclient is available from Emacs 22.)



== Todo

* Merb support
* Mack support
* Ramaze support



== Author

$Author$ <$Email$>

$Copyright$



== License

$License$
