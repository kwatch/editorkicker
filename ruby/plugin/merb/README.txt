============================
EditorKicker plugin for Merb
============================

Release: $Release$


About
-----

This is a plug-in for Merb to enable you to invoke your favorite editor
when you click line number link on Merb error page.

Notice that this plug-in works only under development mode.
So it is no problem to commit this plug-in files into your app repository.


Target
------

Merb 1.0 or higher


Install & Setup
---------------

1. sudo gem install merb_editorkicker
2. Add "dependency 'merb_editorkicker'" into 'config/dependencies.rb'.
3. Set ENV['EDITOR_KICKER'] in 'config/environments/development.rb' (see example).

If you don't set ENV['EDITOR_KICKER'], the original 'txmt://open?url...'
protocol will be used.


Example
-------

config/dependencies.rb:

    dependency 'merb_editorkicker'


config/environments/development.rb:

    ENV['EDITOR_KICKER'] = "/Applications/TextMate.app/Contents/Resources/mate -l %s %s"   # for TextMate
    ENV['EDITOR_KICKER'] = "emacsclient -n +%s %s"    # for Emacs (Don't forget M-x server-start)
    ENV['EDITOR_KICKER'] = "netbeans %2$s:%1$s"       # for NetBeans
    ENV['EDITOR_KICKER'] = "java -jar eclipsecall.jar %2$s -G%1$s"  # for EclipseCall plugin
    ENV['EDITOR_KICKER'] = "open %2$s"                # other


EclipseCall Plug-in
-------------------

If you are using Eclipse or Aptana, you should install EclipseCall plug-in.

http://www.jaylib.org/pmwiki/pmwiki.php/EclipsePlugins/EclipseCall
(M)Help > Software Updates > Find and Install...
http://www.jaylib.org/eclipsecall

And download eclipsecall.jar which is required to invoke Eclipse from command-line.

http://www.jaylib.org/eclipse/plugins/eclipsecall/eclipsecall.jar

After download eclipsecall.jar, you must modify it according to the following steps:

  $ wget http://editorkicker.rubyforge.org/CallClient.java.patch
  $ mkdir eclipsecall
  $ cd eclipsecall
  $ jar xf ../eclipsecall.jar
  $ patch -p1 < ../CallClient.java.patch
  $ javac CallClient.java
  $ jar cfm eclipsecall.jar META-INF/MANIFEST.MF CallClient*
  $ sudo mv eclipsecall.jar /home/yourname/eclipsecall.jar

It is recommended to confirm that you can open a file with new eclipsecall.jar
(Don't forget to invoke Eclipse or Aptana in advance).

  ### open $PWD/CallClient.java and hilight line 10
  $ java -jar /home/yurname/eclipsecall.jar $PWD/CallClient.java -G10

The final step is to add following line to 'config/environments/development.rb':

  ENV['EDITOR_KICKER'] = "java -jar /home/yourname/eclipsecall.jar %2$s -G%1$s"


Author
------

$Author$ <$Email$>

$Copyright$


License
-------

$License$
