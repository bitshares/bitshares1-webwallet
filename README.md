[![Stories in Ready](https://badge.waffle.io/BitShares/web_wallet.png?label=ready&title=Ready)](https://waffle.io/BitShares/web_wallet)
# BitShares GUI (web wallet)

This repository holds the BitShares graphical user interface, also
known as the web wallet.  The web wallet is wrapped by the Qt client
and released as part of the platform-specific BitShares binaries.

## Hacking

To start hacking on the GUI, first follow the directions to build the bitshares client.

* Windows <https://github.com/BitShares/bitshares/blob/master/BUILD_WIN32.md>
* OSX <https://github.com/BitShares/bitshares/blob/master/BUILD_OSX.md>
* Ubuntu <https://github.com/BitShares/bitshares/blob/master/BUILD_UBUNTU.md>

Install Node.js (<http://nodejs.org/download/>)

Navigate to the web_wallet directory where `package.json` is located and run these commands:

    $ npm install
    $ npm start

Edit htdocs parameter in config.json  `AppData/Roaming/BitShares` to point to the `web_wallet/generated/` directory.  For example: ` "htdocs": "C:/bitshares/web_wallet/generated" `

Start another shell, navigate to `/bin/programs/client/RelWithDebInfo` directory, and start
the BitShares client:

    $ ./bitshares_client --server \
        --rpcuser=test --rpcpassword=test \
        --httpdendpoint=127.0.0.1:5000
(You could also achieve this by changing these parameters in your config file.)

The client finds the local GUI code and launches a web server, which
you can access by opening <http://localhost:5000>.  

As long as you keep `npm start` running, the app will automatically be
recompiled (into the `generated/` directory) whenever you make any
changes to the source files in `app/`.

You will want to start by looking at `app/js/app.coffee` and then
browsing the `app/templates` and `app/js/controllers` directories.

## Notes

* If you are using Debian or Ubuntu, you may need to install the
  `nodejs-legacy` package before you run `npm install`.

* The Lineman.js framework (<http://linemanjs.com/>) is responsible
  for most of the features in the development environment.
