# BitShares XT Web Wallet

## Installation

This appplication uses Lineman.js to compile assets located in app and vendor directories, the output goes either into generated or into dist directories.
The installation is very simple, basically you need to install node.js
and install Lineman and dependencies via the following commands:

    $ npm install -g lineman  
    $ npm install

Find more information here [https://travis-ci.org/linemanjs/lineman-angular-template](https://travis-ci.org/linemanjs/lineman-angular-template)


## Usage

1. Specify path to web_wallet/generated as htdocs in client's config.json.
2. Start either bts_xt_client (with --server option) or bts_xt_gui (no --server needed).
3. Run lineman: $ lineman run
4. Open http://localhost:9989, if application is working it should load the idex page (may ask for credentials if client is using HTTP Basic Auth)
5. Now you can edit application's html, js and css files located in web_wallet/app.

