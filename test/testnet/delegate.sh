testnet_datadir=${1?testnet data directory}
INVICTUS_ROOT=${INVICTUS_ROOT:-~/bitshares/bitshares_toolkit}
HTTP_PORT=9980 
RPC_PORT=9979

function init {
  sleep 2
  . ./rpc_function.sh
  rpc open '"default"'
  rpc unlock '9999, "Password00"'
  for i in $(seq 0 100)
  do
    rpc wallet_delegate_set_block_production '"init'$i'", "true"'
  done
}
init&
${INVICTUS_ROOT}/programs/client/bitshares_client --data-dir "$testnet_datadir" --genesis-config init_genesis.json --server --httpport=$HTTP_PORT --rpcport=$RPC_PORT --upnp=false --p2p-port=10000 --min-delegate-connection-count=0
