
WEB_WALLET_GEN=${1?web_wallet\'s generated directory (like ~/bitshares/web_wallet/generated)}
INVICTUS_ROOT=${INVICTUS_ROOT:-~/bitshares/bitshares_toolkit}

set -o errexit

function config {
  dir=$1
  #create config.json
  echo First run, OK to error about a missing RPC password...
  ./client.sh "$dir"||true
  sed -i 's/"rpc_user": ""/"rpc_user": "test"/' ${dir}/config.json
  sed -i 's/"rpc_password": ""/"rpc_password": "test"/' ${dir}/config.json
  sed -i 's#./htdocs#'"$WEB_WALLET_GEN"'#' ${dir}/config.json
  echo
}

function import_test_accounts {
  dir=$1
  echo Setting up wallet...
  cat <<-done|./client.sh "$dir"
wallet_create default Password00
wallet_import_private_key 5K1poDmFzYXd3Eyfuk4DR2jZbHuanzJdmTbxjNPKcrLzeS7EFDS tester true true
wallet_account_balance tester
done
echo
}

function import_delegate_keys {
  dir=$1
  echo Importing delegate private keys....
  cat<<-END|./client.sh "$dir"
wallet_create default Password00
open default
unlock 9999 Password00
`
i=0
for key in $(egrep "[A-Za-z0-9]+" initgenesis_private.json -o)
do
  echo wallet_import_private_key $key init${i} false
  let "i+=1"
done
`
END
  echo
}

mkdir -p tmp

delegate_datadir=$(mktemp -d "tmp/XXXX")
config "$delegate_datadir"
import_delegate_keys "$delegate_datadir"

client_datadir=$(mktemp -d "tmp/XXXX")
config "$client_datadir"
import_test_accounts "$client_datadir"

echo Start Commands:
echo "./delegate.sh $delegate_datadir"
echo "./client.sh $client_datadir"
