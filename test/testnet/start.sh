testnet_datadir=${1?testnet data directory}
INVICTUS_ROOT=${INVICTUS_ROOT:-~/bitshares/bitshares_toolkit}

${INVICTUS_ROOT}/programs/client/bitshares_client --data-dir "$testnet_datadir" --genesis-config init_genesis.json --server --min-delegate-connection-count=0

