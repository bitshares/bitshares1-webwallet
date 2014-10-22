
BTS_WEB=${BTS_WEB:-~/bitshares/bitshares_toolkit/programs/web_wallet}
num=${1-1}

set -o errexit

function import_wallet_backup {
  dir=$1
  echo Importing wallet backup...
  cat<<-END|./client.sh "$dir" $num
wallet_backup_restore $BTS_WEB/test/testnet/config/wallet.json default password
END
  echo
}

mkdir -p tmp
rnd=$(mktemp -u "XXX")

client_datadir="tmp/client_${rnd}"
import_wallet_backup "$client_datadir"

delegate_datadir="tmp/delegate_${rnd}"
import_wallet_backup "$delegate_datadir"

echo "Start Commands:"
echo "./delegate.sh $delegate_datadir"
echo "./client.sh $client_datadir"
echo
