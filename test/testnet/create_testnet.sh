
INVICTUS_ROOT=${INVICTUS_ROOT:-~/bitshares/bitshares_toolkit}
num=${1-1}

#set -o errexit

function import_test_accounts {
  dir=$1
  echo Setting up wallet...
  cat <<-done|./client.sh "$dir" $num
wallet_create default Password00
wallet_import_private_key 5K1poDmFzYXd3Eyfuk4DR2jZbHuanzJdmTbxjNPKcrLzeS7EFDS tester true true
wallet_import_private_key 5JURMQGrUigepksfuRNd2z4gHuX3X1Gy6wfn6DJYG5yKm4uQUWQ init0 true
done
echo
}

function import_delegate_keys {
  dir=$1
  echo Importing delegate private keys....
  cat<<-END|./client.sh "$dir" $num
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
rnd=$(mktemp -u "XXX")

delegate_datadir="tmp/delegate_${rnd}"
import_delegate_keys "$delegate_datadir"

client_datadir="tmp/client_${rnd}"
import_test_accounts "$client_datadir"

echo "Start Commands:"
echo "./delegate.sh $delegate_datadir" $num
echo "./client.sh $client_datadir" $num
echo

echo "One-time setup for ./client.sh:"
cat <<-done
open default
unlock 9999 Password00
transfer 9000000 XTS tester init0

# wait for next block (check info)
info

wallet_asset_create USD BitUSD init0 "paper bucks" null 1000000000 10000 true
wallet_asset_create CNY BitCNY init0 "paper yuan" null 1000000000 10000 true
wallet_asset_create BTC BitBTC init0 "bitcoin" null 1000000000 10000 true
wallet_asset_create GLD BitGLD init0 "solid gold" null 1000000000 10000 true
done
