testnet_datadir=${1?testnet data directory}
num=${2-1}

INVICTUS_ROOT=${INVICTUS_ROOT:-~/bitshares/bitshares_toolkit}
HTTP_PORT=${HTTP_PORT-220${num}}       # 2201
RPC_PORT=${RPC_PORT-221${num}}         # 2211

function init {
  sleep 1
  . ./rpc_function.sh
  rpc open '"default"'
  rpc unlock '9999, "Password00"'
}
init&

cat<<-done
##
# Publish price feeds
#
wallet_publish_price_feed init0 .01 USD
wallet_publish_feeds init0 [["USD",0.0341],["CNY",0.2040]]

done
#wallet_publish_price_feed init0 .02 CNY
#wallet_publish_price_feed init0 .03 BTC
#wallet_publish_price_feed init0 .04 GLD
${INVICTUS_ROOT}/programs/client/bitshares_client --data-dir "$testnet_datadir" --genesis-config init_genesis.json --server --httpport=$HTTP_PORT --rpcport=$RPC_PORT --upnp=false --connect-to=127.0.0.1:10000

