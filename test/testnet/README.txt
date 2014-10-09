SETUP

INVICTUS_ROOT=~/bitshares/bitshares_toolkit
./create_testnet.sh "${INVICTUS_ROOT}/programs/web_wallet/generated"

Upon successful execution you should see a lot of output followed by
directions like this:

...
Start this server as follows:
./delegate.sh tmp/delegate_Tk8
./client.sh tmp/client_Tk8

...more instructions...

Start the ./delegate.sh in one console.  Shortly some rpc commands will execute
enabling all delegates for block production.  You should see some output like this:

(wallet closed) >>> open "default"
{"id":0,"result":null}unlock 9999, "Password00"
{"id":0,"result":null}wallet_delegate_set_block_production "init0", "true"
{"id":0,"result":null}wallet_delegate_set_block_production "init1", "true"
{"id":0,"result":null}wallet_delegate_set_block_production "init2", "true"


#
# Start the ./client.sh and follow the last of the one-time directions 
# provided by ./create_testnet.sh
#

Exit and re-start the servers anytime using ./delegate.sh and ./client.sh and
your testnet should be ready to go without any further setup.


UNIT TESTS

Use the ./client.sh http port to access the web_wallet:
http://localhost:9989

... or to run the e2e unit tests when they become available


DETAILS

These are low level details about how this environment was created.  You probably do not need this.

# https://github.com/BitShares/bitshares_toolkit/blob/dryrun-8/docs/manual_testing_dpos.dox

export INVICTUS_ROOT=~/bitshares/bitshares_toolkit
${INVICTUS_ROOT}/programs/utils/bts_create_genesis
Creates
init_genesis.json
initgenesis_private.json

edit init_genesis.json to replace 11111111... with a valid PTS address:
$ ${INVICTUS_ROOT}/programs/utils/bts_create_key 
public key: XTS6CaeQRtCFjxNU3UWYgC8AwmMrZhQXMDMVBRQBBGLrHNvsTfYoT
private key: 9de51f9c7f8365ea4a1c3ac39cb5cbdc846b0bb5fb8c8d99017d5028b5e657de
private key WIF format: 5K1poDmFzYXd3Eyfuk4DR2jZbHuanzJdmTbxjNPKcrLzeS7EFDS
bts address: XTSE6wHbaQgYMQ1qCYgHeujUMSAToTmojj4P
pts address: PbsmKpWoZCee9VqVmank8cFZ1NdzqwtNz7

Also, the top of the init_genesis.json file was upraded with these header found in ${INVICTUS_ROOT}/tests/test_genesis.json:

  "timestamp": "20141007T105500",
  "supply": 10000000000000,
  "precision": 1000000,
  "base_name": "BitShares XTS",
  "base_symbol": "XTS",
  "base_description": "Stake in future BitShares X chains",


Delete all invalid keys.  So, the entire blances block may look like this:

  "balances": [[
      "PbsmKpWoZCee9VqVmank8cFZ1NdzqwtNz7",
      10000000000000
    ]
  ]

All balances must add up to the total supply.

start a server:

tmp_datadir=$(mktemp -d "tmp/XXXX")
${INVICTUS_ROOT}/programs/client/bitshares_client --data-dir "$tmp_datadir" --genesis-config init_genesis.json --server --min-delegate-connection-count=0

One catch, server exits the first time.  Edit the newly created config.json (log messages show the path) and include change the rpc_user and rpc_password to "test", "test".  Finally, adjust the ./htdocs path to point to the web_wallet's generated directory and re-run the bitshares_client command above.


Now running, setup the default wallet:

wallet_create default Password00


default (unlocked) >>> wallet_import_private_key 5K1poDmFzYXd3Eyfuk4DR2jZbHuanzJdmTbxjNPKcrLzeS7EFDS tester true true

default (unlocked) >>> wallet_account_balance tester
ACCOUNT                         BALANCE                     
============================================================
tester                          2,000,000,000.00000 XTS     


Create import keys for all 101 delegates (so you will have a fast block times):

i=0; for key in $(egrep "[A-Za-z0-9]+" initgenesis_private.json -o); do echo wallet_import_private_key $key init${i}; let "i+=1"; done

#unlocked?
open default
unlock 9999 Password00

Output from the above based on the initgenesis_private.json data:

wallet_import_private_key 5JURMQGrUigepksfuRNd2z4gHuX3X1Gy6wfn6DJYG5yKm4uQUWQ init0
wallet_import_private_key 5KgJYxM8Yx9fdWHuJznWeD19oMKpmYdrv8YH8GzF3uTyP8Z29oE init1
wallet_import_private_key 5JPSupPokoMciqtyREraUXGT57xfSXy888fgjmzPdvtmniJZGNx init2
wallet_import_private_key 5JMaEzU5k7SqKESqadC3ePVA1kqeTZk7DHkfvWR6yfAaiSRLvKu init3
wallet_import_private_key 5KA134ogttxtoy61CZGvCeHd7GTxKuaxgJ9qHkP6FY2rFTrrCnn init4
wallet_import_private_key 5K63a7WPGZgKgq7Hww63ub8D8AzvGWbpkLdyjxrmCdDJ8UHGejT init5
wallet_import_private_key 5KPiuCeZqXsdxVBLKALYC7Gh6i3tZ9z2MVc9j55S1RqYvyFyeSQ init6
wallet_import_private_key 5K6cMG32arfaAacYeKfPo4PtPkAd9nZSqRkLDnXuvPxWfneJ6aU init7
wallet_import_private_key 5JETRSbMpBoPe68S2DwQMhbA33jWcUcjmL2D51xTtLLN1wZ9G8f init8
wallet_import_private_key 5JRMfZL4Z4XZctq9K1RAsSghEmgmKYuUAsVPbKbcr9aTrEVQBZM init9
wallet_import_private_key 5JQNyKutasXTDdzgFUMiBwKhddCHyq79BzdwaY7d5Dk6yW3nEEH init10
wallet_import_private_key 5JDLJ9m6rfBynfYUpHu3D1qQGCRMd47fWDKU4AzAfmAbry9w9Rt init11
wallet_import_private_key 5KCwBUxiBPqt4E16kRpTfAFoz6yPKFAjtBdsSnVFtFyRXg8LU7Y init12
wallet_import_private_key 5KNw63Pvv4ewp6qU5Wgii5hYbrigx351skuE856sfDopWQhxvh9 init13
wallet_import_private_key 5JURncDuTvetKETY4ceixvnGfunfwP1FJRmbJUuPLQRfn4MJbr6 init14
wallet_import_private_key 5Hy9ii5cYaQ84Vreki1o1PtYJQFJWfTjrwEEhMCjGmFjLGTeg5B init15
wallet_import_private_key 5JAG2aZwK668et5H6dUkbwwUsY7AbrZ7qhhhJ12FCyS8aPYg2oK init16
wallet_import_private_key 5KV7NSF5JCRLcfYfkNiJvoEKTnMVnkvKzatXMnYopT7HLkrZBqb init17
wallet_import_private_key 5KK3s57DKG1dqqP1N9oXXEeVGVGxeLE31CEDbqL3Ri47v1uXQmE init18
wallet_import_private_key 5KXTgXbKFoXESKbpciiVPkEKhh8CX39wd1SRNmQBFv1QLESqc1b init19
wallet_import_private_key 5KGCLJErFAFoX8vBTykRpwN9ZePb5HxPTV3aycH81fu5me8oTxr init20
wallet_import_private_key 5KRrNzUoDFWToM9KYBGVkag7vgMasbGRGozY4JCpJGmiQByMcLU init21
wallet_import_private_key 5JPETLcNkD3ZbGgsqm4bkovKv2H1roQMT818VuXSQaohe4scYxf init22
wallet_import_private_key 5JrsTw26Z8KwaTP91vUExKaTU4Zd623NN7KuXhuSvLxzU9e4BLe init23
wallet_import_private_key 5J4zSMfcU9YMsHzgES14z184WwHDdck8Xvw28pbpSYyyxmHaNvy init24
wallet_import_private_key 5KKcbX1gg3eJjqUit1FEbNws2C4tBZwBzpAjwfkpDg9zXKoy1tV init25
wallet_import_private_key 5KHFtVx7RWAWVXiWhXL5Bi9Nv2T54Jzxv2wu3bcUxM2rzuSPrSc init26
wallet_import_private_key 5JG6PgTcmn5jQuLiTK7NeUnz3S2W9FVqmut8kjXubpUWF2BpEUb init27
wallet_import_private_key 5HpRE5ywRVpg2ovpEuHU8t5e5U2WJVKDBqV8yXEpzuUSiPfp2WM init28
wallet_import_private_key 5J5CWMsnqvz8XeMp2KearTTuzBragUJoUESjky5ryhsNvoqM15g init29
wallet_import_private_key 5JtFDTpdK7V9dYx8QExNr2XN3t56wVKM7UAKXjFQ5Vfw3MRWViC init30
wallet_import_private_key 5J4auxbXfYaXmtkmGF5UgRWscabifRCofhVtA7AvaqcRqG4voU2 init31
wallet_import_private_key 5KbRzyoGgv41xvtSe6hRodXhduF9dqvJ22xfninXB3LsFpMvNis init32
wallet_import_private_key 5JxkieL59LdeZcZF1grgCRFY5rEAsf9VfudKT45Updw31bPjijf init33
wallet_import_private_key 5KTmRh9HkL7zhF38pBuiVuyLUku5qLYd1P1K241csuoPwpfWn8j init34
wallet_import_private_key 5JzLQsA7KBVM89LZpc9MVoyJc4BY5U4LLPtwE5eT7LSCngBAsC3 init35
wallet_import_private_key 5JdoyTn9SRCTxCKhFYcG8UaWsTT9rpHK7tGQ8q6jAmq1aSDk2YZ init36
wallet_import_private_key 5JpGhr4hYnKtJLkDmsQuLtJSeHxq7L1t3dW5dTHqSyD9KEyUUPs init37
wallet_import_private_key 5Jps5j1iPhHUsYgWUCLzWXghVGC5ijcn5sjfrH39YnhonVH4Y9c init38
wallet_import_private_key 5JTvns3QP144Fgt7W54wJTbNGteXTUyaPvYuUKpEtutAA99YrAC init39
wallet_import_private_key 5JHNLrLmQ4gk6QnH2casTFqVaMzFxXMc9f6WcED4yNFQ9wTjScG init40
wallet_import_private_key 5Jhd1UTzsWiDzWX9EqxmrWyAKbi4Niqzt3vWuG6fTEYDkpTcCQ6 init41
wallet_import_private_key 5KFtbzySYimCsy427mpykCyBVTe5qYKejSANtre9NVVTxDigg9c init42
wallet_import_private_key 5JCFDpuFVxA1AaJ7d8rtWBqMVhvRVNZRGkjXjnqKhwLf5RwLPWY init43
wallet_import_private_key 5HzFEY9tnHuzWDmoBFsGB8nqjH4QyFgwAcmuUSAiSwtHxtRgiUD init44
wallet_import_private_key 5KAWMD2HkZgPtk3QL4yaCnnZVm1z7rL57WGxwGqryz4AD3pVddQ init45
wallet_import_private_key 5K7bauPa4PEJ3zN5gbXkEVViPxsHanrTeesZ8ZGMKgmfFpudc8t init46
wallet_import_private_key 5K2eZrEpxYEuPfqZRnv2DAn4s6VW4bD1GH5PGzMDVuW173aLp2H init47
wallet_import_private_key 5Hpi44uSRbTJtQ1ZSLAGMHCP9mAmNhrLhpe6w7urinka4M7ouDj init48
wallet_import_private_key 5Hq5R76jj1Y1fNefpGcwXzr3yWakZKbxDCekeWonMoSXgutg188 init49
wallet_import_private_key 5KUS5yrNW3B78qw4CJs4cXmozgGgn2JvTfYKe6dCQ6HPxGXCvy4 init50
wallet_import_private_key 5HucN7QYQzDQiSghbfyEStffLeg2ZZ2sTK8mZBMzrGPuJGQy53X init51
wallet_import_private_key 5KhviUXFLDsqqtgSC1M1WdRYrHxBrRcxTdh8fvtCJsPHFZZpNS8 init52
wallet_import_private_key 5JsyvJjBrbG6fsU2ZJP2ej6hkqCJ1WdvpitrnBmNjVur3Si5MSb init53
wallet_import_private_key 5K8dE2ySM5KDE9yfHTEwrMonpMxCQQSPMboc5HxViyEuAuH7Nkw init54
wallet_import_private_key 5KkxGocd1DTpEkVTx6FmNKkNqV6vwKBbA3EMTDdgb15YqTJ2wny init55
wallet_import_private_key 5JfQnukE1QRc3iE5RVxdVa52wcYuF7KPAyk4kRTTp8pqJtuhMSL init56
wallet_import_private_key 5JBPy6ZZTMtQ8W3TbPdj1kMkJ6kMHMkwRNEm4aF4dHCyo8EaBvG init57
wallet_import_private_key 5JB8FTDphk9T51vbrEKhXuJ8jNi9hABmitvi1czNj3oA6DhKyNh init58
wallet_import_private_key 5Hxw3mX8VtM2E44GckeW4ScD4Z8JFuGca8MrmvHJxSHwEbBzdsq init59
wallet_import_private_key 5KSbHw1c1AA891cBCzTUkCbauVhSwsYrXKrSrz8S5rfcn2Bddjd init60
wallet_import_private_key 5KJGbqMHZE71sng7NK32dKRyu8XR8sguNWaq5C7Qh6Lz9Cr9G9f init61
wallet_import_private_key 5Kc1iVmHKKUXQqDm3tyDbRQcFpeXidG5k5Sg4z15GzZ8hwnMdUW init62
wallet_import_private_key 5Jqv3vGzqv2VpucDgum9CyDessANN232zzg1G5SdZ1Swymyhwtn init63
wallet_import_private_key 5KAc1FuhXo82UwoJSfnteMnnMq3BXyVdyEib6HEBNPmjqbiMkwy init64
wallet_import_private_key 5KL9uEcEwCYATpCzNwWKM1HoRFWPF7i6NfaXWwY5PzJATt7nrsb init65
wallet_import_private_key 5K6g31SjLhE9Qja6EtQi8eEogwrMPiHAo2dygvKaw4G9P3w3Teu init66
wallet_import_private_key 5HtMcGTKphS37PW3nq3RQuvfznPEt42qTn6UL1LpkmYQ3iXHFe9 init67
wallet_import_private_key 5K526MCTzoZW5T8unRg1ZZU89FBzwFF4aa3PKJyvqXkmG21Wm8g init68
wallet_import_private_key 5JuuJSQiZdnG1afDHZBn9n4V8jpmhQGpGeWSVKyeVzqo8wmUQef init69
wallet_import_private_key 5JJHzYuZUEMqLGWLFP5sbUQtB1UEEmozyWpWDYGAdoc36eJV4dG init70
wallet_import_private_key 5J92uNkeo2zdh2JSdrxR47yAmJinXvh2uZy3S6q4chXW7LvvkVj init71
wallet_import_private_key 5Kjg81TcQLjHPPjYPQivxQps38eMotyujqLY9Lr8db7wS1sapSk init72
wallet_import_private_key 5JK554wauXW5JQ7YSNhPepgKmjWKxsvYhyorSNxxr5zgj6YNsox init73
wallet_import_private_key 5JLvoEM9jhj8JhhfbMdSjr3ryfycp8yj8Tk5jCTFUU6yPsSFQja init74
wallet_import_private_key 5JAyRf4zMtcehvuyS5LbUjfeS6qCMxeh6AQ2u8YpBYN41a4MUqi init75
wallet_import_private_key 5K6WEJ5t49WQ1cxqeza1wFqbZVRMBHRHmWjTFcNpNXn5e83GD3w init76
wallet_import_private_key 5KPDGJdnGMUr7npeT1PE71a4MLSHdiE2Z6dN8ZVn5viCC58bnUB init77
wallet_import_private_key 5JXvubQCpwhf59Z5VEQTZtPK9926TckJP6SpBa5tUTxtPCXvm44 init78
wallet_import_private_key 5JbjM86FxmYVqJ8oGy7k8PKQXsuG48xEkMFF6F2nhWCmKNQBJXG init79
wallet_import_private_key 5J9WLmyJgPAXLf25r3rCGoPeESfzegb8skX1voyGN2pcufc7XLq init80
wallet_import_private_key 5K1F6YXS7jNMX3eubBSW9GheepWnjT13DS7CehNzL62xZ6gnMhc init81
wallet_import_private_key 5JxYYPJR4Tgc8Y3h9bTuSYiDhbcH9qfHU3rxs41n4MW2AZdoDxx init82
wallet_import_private_key 5HvX4a2C2SgSwWRjtoGU76KGbPYucCBUFfWRwoQuWaYnQ4VpAKx init83
wallet_import_private_key 5J7MjcFSuErjLv6eZCqNXJGWNAE4Pfmv86QVRpR4UKMkwWrm7EX init84
wallet_import_private_key 5KPJiEMkSjwkaywnxnwqtLdvpbUcjUGqA2FUmzauHMu3hetPSF2 init85
wallet_import_private_key 5HzvziDGiTrMk8Yhn3DCCP1mTEaJhBMbC3qqE8pzxcmQEHwFLPs init86
wallet_import_private_key 5K2LtvypycA7DABsjtoBW21KjGFenA3TQRU94SMg8zvkpWFFwpv init87
wallet_import_private_key 5K7oo2W2C8a99BUtzWcJa51Rmwf2CVFaFXjWnPwjhEvmDg65kK5 init88
wallet_import_private_key 5JPZAhaibqi26gWa13iorqaHP8T2zC4uacfPwhtprcJyU9BErV3 init89
wallet_import_private_key 5Kd9jRVKJuDZskapWFdGUdTwFvcWzh5DpvboHjC85MMvpx9nhoe init90
wallet_import_private_key 5JxyXq1QrbqSedPeudN5KWj19FdU7nSWFKaysxWLHdFGncLypgQ init91
wallet_import_private_key 5JMBBLA8NYthGiHTvmKmzQFYtnLPFTXSbQ3ii7Hh9YeC81cRB7d init92
wallet_import_private_key 5KipB5MSUq2HK2Z1DtKZJMAds49mxEHRL9fmWLi5p9WKrefjHq6 init93
wallet_import_private_key 5J2yFgHcdUu9Rns7hyQeo1NvRLqPHuFG97ukQrMpVf9914Bs6LF init94
wallet_import_private_key 5JgAzFg2jRRcTUX3YmJN2WPy2noEv6rBrAuSgcWqWmijxhLGWH3 init95
wallet_import_private_key 5J9Ux5FFDnHuwgwwNUtqyPnGGNRSQG8KRSUE8dNoxznpT9qj9CT init96
wallet_import_private_key 5JFL78yDCgWgMdMtY6iaweSeCBHkCG57jYKCC3KPnSrgCykC5Lr init97
wallet_import_private_key 5HwzLg8rcTq3ZxLAy5bj4hcZkevbKHDbYjXvKNo84Ly3oas7fp5 init98
wallet_import_private_key 5KiaQVu4SqFoWpsg1Uyn7Lnf1f3pmRyuxRbCtiUdUEDyqT7NLYp init99
wallet_import_private_key 5KiqsszyuacktfjaXprLQYAfp5MWD4gBEKUKHctoUySSrk9jyN6 init100


i=0; for key in $(egrep "[A-Za-z0-9]+" initgenesis_private.json -o); do echo wallet_delegate_set_block_production init${i} true; let "i+=1"; done

#unlocked?
open default
unlock 9999 Password00
wallet_delegate_set_block_production init0 true
...
wallet_delegate_set_block_production init100 true



