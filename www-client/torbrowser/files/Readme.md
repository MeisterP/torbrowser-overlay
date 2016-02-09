# Advanced torbutton functionality

To get the advanced functionality of Torbutton (network information,
new identity feature), `www-client/torbrowser` needs to access a control port.

![Tor Onion Menu ](https://people.torproject.org/~mikeperry/images/OnionMenu.jpg)

* If you use `www-client/torbrowser`, you need to **adjust and export** the environment variables from
  [99torbrowser.example](https://github.com/MeisterP/torbrowser-overlay/blob/master/www-client/torbrowser/files/99torbrowser.example).
  You can do this either with gentoo's `/etc/env.d`
  [mechanism](https://wiki.gentoo.org/wiki/Handbook:X86/Working/EnvVar#Defining_variables_globally)
  or on the command line.

  _Tor Network Settings_ and _Check for Tor Browser Update_ functionality is not working with the `www-client/torbrowser`.

* If you use `www-client/torbrowser-launcher`, make sure that the environment variables from
  [99torbrowser.example](https://github.com/MeisterP/torbrowser-overlay/blob/master/www-client/torbrowser/files/99torbrowser.example)
  are **unset** and that you **don't** have the system wide tor running on port `9150`.

  With `www-client/torbrowser-launcher`, all menu entries are available and working.
