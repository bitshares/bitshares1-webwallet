
INVICTUS_ROOT=${INVICTUS_ROOT:-~/bitshares/bitshares_toolkit}
num=${1-1}

#set -o errexit

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

mkdir -p tmp
rnd=$(mktemp -u "XXX")

delegate_datadir="tmp/delegate_${rnd}"
import_delegate_keys "$delegate_datadir"

client_datadir="tmp/client_${rnd}"
import_test_accounts "$client_datadir"

echo "Start Commands:"
echo "./delegate.sh $delegate_datadir"
echo "./client.sh $client_datadir"
echo
