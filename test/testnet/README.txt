## SETUP

export INVICTUS_ROOT=~/bitshares/bitshares_toolkit

# In-source build OR out-of-source build
export BTS_BUILD=~/bitshares/bitshares_toolkit
export BTS_BUILD=~/bitshares/bitshares_toolkit/4nbuild
export BTS_WEB=~/bitshares/bitshares_toolkit/programs/web_wallet

## RUN

Exit and re-start the servers anytime using ./delegate.sh and ./client.sh and
your testnet should be ready to go without any further setup.

Start a delegate for block production:
./delegate.sh

Use a client for most or all of your RPC commands.  
./client.sh

#
# Publish price feeds (client)
#
wallet_publish_price_feed delegate0 .01 USD
...
wallet_publish_price_feed delegate100 .01 USD
.. OR ..
wallet_publish_feeds delegate0 [["USD",0.0341],["CNY",0.2040]]
.. OR ..
for i in $(seq 0 100); do echo wallet_publish_price_feed delegate$i 0.0341 USD; done
#

## WEB WALLET

Ensure that the web_wallet has been compiled using lineman and has a generated directory (see ./htdocs link)

Use the ./client.sh http port to access the web_wallet:
http://localhost:44000

The wallet password is: Password00
The RPC user/password: test/test (browser will prompt)
