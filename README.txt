======
README
======

Release: $Release$


About
-----

RoR::OpenErrfile is a plugin for Ruby on Rails to open errored file
by emacsclient automatically when error raised in development mode.


Target
------

* 2.1.X
* 2.0.X
* 1.2.X (I hope)


Usage
-----

1. Intall RoR::OpenErrfile plugin into your Rails application.
2. Restart Rails server.
3. Do 'M-x server-start' in your Emacs. (*** IMPORTANT! ***)


Environments
------------

* $EMACSCLIENT represents emacsclient command path (default 'emacsclient').

* $OPEN_ERRFILE_COMMAND represents command string to open errored file
  (default "emacsclient -n +%s '%s'").


Customize
---------

* RoR::OpenErrfile.handler.emacsclient = '/Users/yourname/bin/emacsclient'

* RoR::OpenErrfile.handler.command = proc {|filepath, linenum| `open #{filepath}` }


Autor
-----

makoto kuwata <kwa(at)kuwata-lab.com>

$Copyright$
