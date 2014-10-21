# Usage:
# ./client.sh tmp/client_???
# GDB="gdb -ex run --args" ./client.sh tmp/client_???
testnet_datadir=${1?testnet data directory}
num=${2-1}

BTS_ROOT=${BTS_ROOT:-~/bitshares/bitshares_toolkit}
HTTP_PORT=${HTTP_PORT-220${num}}       # 2201
RPC_PORT=${RPC_PORT-221${num}}         # 2211

function init {
  sleep 10
  . ./rpc_function.sh
  # the process may be gone, re-indexing, etc. just error silently
  rpc open '"default"' > /dev/null 2>&1
  rpc unlock '9999, "Password00"' > /dev/null 2>&1
}
init&

set -o xtrace

${GDB-} \
${BTS_ROOT}/programs/client/bitshares_client\
 --data-dir "$testnet_datadir"\
 --genesis-config init_genesis.json\
 --server\
 --httpport=$HTTP_PORT\
 --rpcport=$RPC_PORT\
 --rpcuser=test\
 --rpcpassword=test\
 --upnp=false\
 --connect-to=127.0.0.1:10000
