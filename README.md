# BitShares XT Web Wallet

## Installation

This appplication uses Lineman.js to compile assets located in app and vendor directories, the output goes either into generated or into dist directories.
The installation is very simple

Install node.js:

   http://nodejs.org/download/

Install Lineman and dependencies via the following commands:


    $ npm install -g lineman  
    $ npm install

Find more information here [https://travis-ci.org/linemanjs/lineman-angular-template](https://travis-ci.org/linemanjs/lineman-angular-template)


## Usage

1. Specify path to web_wallet/generated as htdocs in client's config.json. e.g.
```
{
  "rpc": {
    "rpc_user": "test",
    "rpc_password": "test",
    "rpc_endpoint": "127.0.0.1:0",
    "httpd_endpoint": "127.0.0.1:0",
    "htdocs": "/Users/dlarimer/dev/web_wallet/generated"
  },
  "default_peers": [
    "107.170.30.182:8764",
    "114.215.104.153:8764",
    "84.238.140.192:8764"
  ],
  "ignore_console": false,
  "logging": {
    "includes": [],
    "appenders": [],
    "loggers": []
  }
}
```

2. Start either bitshares_client (with --server option).
```
./bitshares_client --data-dir w1 --server --httpport 9989
```

3. Run lineman: $ lineman run

4. Open http://localhost:9989, if application is working it should load the idex page (may ask for credentials if client is using HTTP Basic Auth)

5. Now you can edit application's html, js and css files located in web_wallet/app.

