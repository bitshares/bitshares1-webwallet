# BitShares GUI (web wallet)

This repository holds the BitShares graphical user interface, also
known as the web wallet.  The web wallet is wrapped by the Qt client
and released as part of the platform-specific BitShares binaries.

## Hacking

To start hacking on the GUI, install Node.js and run these commands:

    $ npm install
    $ npm start

Start another shell, navigate to the web wallet directory, and start
the BitShares client:

    $ bitshares_client --server \
        --rpcuser=test --rpcpassword=test \
        --httpdendpoint=127.0.0.1:5000

The client finds the local GUI code and launches a web server, which
you can access by opening <http://localhost:5000>.  You could also
achieve this by setting the `htdocs` parameter in your config file.

As long as you keep `npm start` running, the app will automatically be
recompiled (into the `generated/` directory) whenever you make any
changes to the source files in `app/`.

You will want to start by looking at `app/app.coffee` and then
browsing the `app/templates` and `app/controllers` directories.

## Notes

* If you are using Debian or Ubuntu, you may need to install the
  `nodejs-legacy` package before you run `npm install`.

* The Lineman.js framework (<http://linemanjs.com/>) is responsible
  for most of the features in the development environment.
