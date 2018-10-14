# torbrowser-overlay [![gentoo qa-reports](https://img.shields.io/badge/gentoo-QA%20check-6E56AF.svg)](https://qa-reports.gentoo.org/output/repos/torbrowser.html) [![pipeline status](https://0xacab.org/Poncho/torbrowser-overlay/badges/master/pipeline.svg)](https://0xacab.org/Poncho/torbrowser-overlay/pipelines)

To add the torbrowser overlay, run `layman -a torbrowser` or `eselect repository enable torbrowser`.

Install either `www-client/torbrowser-launcher` or `www-client/torbrowser`. If unsure, choose `www-client/torbrowser-launcher`.

![Tor Browser Bundle start page](https://extra.torproject.org/blog/2018-09-05-tor-browser-80/tb8-onboarding.gif)


## www-client/torbrowser-launcher

[Homepage](https://github.com/micahflee/torbrowser-launcher)

Tor Browser Launcher is intended to make Tor Browser easier to install and use for GNU/Linux users. You install 'torbrowser-launcher' from your distribution's package manager and it handles everything else:

* Downloads and installs the most recent version of Tor Browser in your language and for your computer's architecture, or launches Tor Browser if it's already installed (Tor Browser will automatically update itself)
* Certificate pins to https://www.torproject.org, so it doesn't rely on certificate authorities
* Verifies Tor Browser's [signature](https://www.torproject.org/docs/verifying-signatures.html.en) for you, to ensure the version you downloaded was cryptographically signed by Tor developers and was not tampered with
* Adds "Tor Browser" and "Tor Browser Launcher Settings" application launcher to your desktop environment's menu
* Optionally plays a modem sound when you open Tor Browser (because Tor is so slow)


## www-client/torbrowser

[Git repository](https://gitweb.torproject.org/tor-browser.git)

This patched Firefox build is **not recommended by Tor upstream** but
uses the exact same sources. Use this only if you know what you are doing!

The profile folder includes pre-configuration recommended by upstream,
as well as the extensions Torbutton, NoScript and HTTPS-Everywhere.
If you want to start from scratch just remove the directory `~/.mozilla/torbrowser`.

Torbrowser uses port `9150` to connect to Tor. You can change the port
in `/etc/env.d/99torbrowser` to match your setup. See
[99torbrowser.example](https://github.com/MeisterP/torbrowser-overlay/blob/master/www-client/torbrowser/files/99torbrowser.example)
for possible settings.
You can do this either with gentoo's `/etc/env.d`
[mechanism](https://wiki.gentoo.org/wiki/Handbook:AMD64/Working/EnvVar/en#Defining_variables_globally)
or on the command line.


### Advanced torbutton functionality

To get the advanced functionality of Torbutton (network information,
new identity feature), `www-client/torbrowser` needs to access a control port.

![Tor Onion Menu ](https://extra.torproject.org/blog/2018-09-05-tor-browser-80/tb8-circuit-display-onion-small.gif)

* If you use `www-client/torbrowser`, you need to **adjust and export** the environment variables from
  [99torbrowser.example](https://github.com/MeisterP/torbrowser-overlay/blob/master/www-client/torbrowser/files/99torbrowser.example).
  You can do this either in `/etc/env.d/99torbrowser` with gentoo's `/etc/env.d`
  [mechanism](https://wiki.gentoo.org/wiki/Handbook:AMD64/Working/EnvVar/en#Defining_variables_globally)
  or on the command line.

  _Tor Network Settings_ and _Check for Tor Browser Update_ functionality is not working with the `www-client/torbrowser` and is therefore disabled.

* If you use `www-client/torbrowser-launcher`, make sure that the environment variables in `/etc/env.d/99torbrowser`
  are **unset** and that you **don't** have the system wide tor running on port `9150`.

  With `www-client/torbrowser-launcher`, all menu entries are available and working.


##  Tor Hidden Service

A hidden service of this repository is available at [vivmyccb3jdb7yij.onion](http://vivmyccb3jdb7yij.onion/poncho/torbrowser-overlay)

```
git -c http.proxy=socks5h://127.0.0.1:9050 clone http://vivmyccb3jdb7yij.onion/Poncho/torbrowser-overlay.git
cd torbrowser-overlay
git config --add remote.origin.proxy "socks5h://127.0.0.1:9050"
```
