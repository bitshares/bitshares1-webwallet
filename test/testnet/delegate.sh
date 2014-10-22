# Usage:
# ./delegate.sh tmp/delegate_??? 1
# GDB="gdb -ex run --args" ./delegate.sh tmp/delegate_??? 1
testnet_datadir=${1?testnet data directory}
num=${2-1}

BTS_BUILD=${BTS_BUILD:-~/bitshares/bitshares_toolkit}
BTS_WEB=${BTS_WEB:-~/bitshares/bitshares_toolkit/programs/web_wallet}

HTTP_PORT=${HTTP_PORT-110${num}}	# 1101
RPC_PORT=${RPC_PORT-111${num}}		# 1111

function init {
  sleep 10
  . ./bin/rpc_function.sh
  rpc open '"default"' 
  rpc unlock '9999, "password"'
  for i in $(seq 0 100)
  do
    rpc wallet_delegate_set_block_production '"delegate'$i'", "true"'
  done
}
init&

set -o xtrace

${GDB-} \
"${BTS_BUILD}/programs/client/bitshares_client"\
 --data-dir "$testnet_datadir"\
 --genesis-config "$BTS_WEB/test/testnet/config/genesis.json"\
 --server\
 --httpport=$HTTP_PORT\
 --rpcport=$RPC_PORT\
 --rpcuser=test\
 --rpcpassword=test\
 --upnp=false\
 --p2p-port=10000\
 --min-delegate-connection-count=0
