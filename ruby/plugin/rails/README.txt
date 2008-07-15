=====================================
EditorKicker plugin for Ruby on Rails
=====================================

Release: $Release$


About
-----

EditorKicker is a pretty tool to invoke your favorite editor and
open errored file automatically when an exception raised on your script.
This is a plug-in of EditorKicker for Ruby on Rails.

Notice that this plug-in works only under development mode.
So it is no problem to commit this plug-in files into your app repository.


Target
------

* Rails version
  - 2.1.X
  - 2.0.X
  - 1.2.X (I hope)

* Supported text editor by default
  - TextMate
  - Emacs


Usage
-----

1. Intall EditorKicker plugin into your Rails application.
2. (optional) Set environtment variable $EDITOR_KICKER with command string to
   invoke text editor (default "mate -l %s '%s'" or "emacsclient -n +%s '%s').
3. Restart Rails server in development mode.
4. Do 'M-x server-start' if you want to use Emacs. (*** IMPORTANT! ***)


Setup
-----

Environment variable $EDITOR_KICKER represents command string to invoke your
favorite editor with filename and linenum.
Default is "mate -l %s '%s'" or "emacsclient -n +%s '%s'".


Author
------

$Author$ <$Email$>

$Copyright$


License
-------

$License$
