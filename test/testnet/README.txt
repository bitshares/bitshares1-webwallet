## SETUP

export INVICTUS_ROOT=~/bitshares/bitshares_toolkit

# in-source build OR out-of-source build
export BTS_BUILD=~/bitshares/bitshares_toolkit/4nbuild

export BTS_WEB=~/bitshares/bitshares_toolkit/programs/web_wallet


./create_testnet.sh 

Upon successful execution you should see a lot of output followed by
directions like this:

...
Start this server as follows:
./delegate.sh tmp/delegate_Tk8
./client.sh tmp/client_Tk8

...more instructions...

Start the ./delegate.sh in one console.  Shortly some rpc commands will execute
enabling all delegates for block production.  You should see some output like this:

(wallet closed) >>> open "default"
{"id":0,"result":null}unlock 9999, "Password00"
{"id":0,"result":null}wallet_delegate_set_block_production "delegate0", "true"
{"id":0,"result":null}wallet_delegate_set_block_production "delegate1", "true"
{"id":0,"result":null}wallet_delegate_set_block_production "delegate2", "true"


#
# Publish price feeds
#
wallet_publish_price_feed delegate0 .01 USD
...
wallet_publish_price_feed delegate100 .01 USD
.. OR ..
wallet_publish_feeds delegate0 [["USD",0.0341],["CNY",0.2040]]
.. OR ..
for i in $(seq 0 100); do echo wallet_publish_price_feed delegate$i 0.0341 USD; done
#


Exit and re-start the servers anytime using ./delegate.sh and ./client.sh and
your testnet should be ready to go without any further setup.

WEB WALLET

Ensure that the web_wallet has been compiled using lineman and has a generated directory (see ./htdocs link)

Use the ./client.sh http port to access the web_wallet:
http://localhost:2201

