# Usage (one of these):
# ./client.sh
# ./client.sh 001
# GDB="gdb -ex run --args" ./client.sh

num=${1-000}
testnet_datadir="tmp/client${num}"

BTS_BUILD=${BTS_BUILD:-~/bitshares/bitshares_toolkit}
BTS_WEB=${BTS_WEB:-~/bitshares/bitshares_toolkit/programs/web_wallet}

HTTP_PORT=${HTTP_PORT-44${num}}       # 44000
RPC_PORT=${RPC_PORT-45${num}}         # 45000

function init {
  . ./bin/rpc_function.sh
  if test -d "$testnet_datadir/wallets/default"
  then
    if [ -z "$GDB" ]
    then
        sleep 3
    else
        sleep 10
    fi
    echo "Login..."
    # the process may be gone, re-indexing, etc. just error silently
    rpc open '"default"' > /dev/null 2>&1
    rpc unlock '9999, "Password00"' > /dev/null 2>&1
  else
    sleep 3
    echo "Creating default wallet..."
    rpc wallet_backup_restore '"config/wallet.json", "default", "Password00"'
  fi
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
 --connect-to=127.0.0.1:10000
