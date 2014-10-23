console.log "-------------------"
JSON_PORT=process.argv[2] or 45000
console.log "(param 1) JSON_PORT=",JSON_PORT

{Rpc} = require "./rpc_json"
{Common} = require "./rpc_common"

@rpc=new Rpc(on, JSON_PORT, "localhost", "test", "test")
@common=new Common(@rpc)


class Mail
    constructor: (@rpc, @common) ->

    send: (
        from = "tester"
        to = "tester"
        subject = "The Subject"
        body = "Body..."
    ) ->
        @rpc.run("mail_send", [from, to, subject, body]).then (response) ->
            @message_id = response
            console.log "Submitted Message ID",message_id

    check: ->
        @rpc.run("mail_get_processing_messages").then (response) ->
            for x in response
                if x[1] == @message_id
                    console.log "check (status) ", x[0]

    processing_cancel_all: ->
        #https://github.com/BitShares/bitshares_toolkit/commit/57d04e8fb2b0dda15623e83a6855f77b2dc1cbd6
        @rpc.run("mail_get_processing_messages").then (response) ->
            for x in response
                console.log("mail_cancel_message #{x[1]}")
                @rpc.run("mail_cancel_message #{x[1]}")

class MailTest
    
    constructor: (@rpc, @common) ->
        @mail=new Mail(@rpc, @common)

    clear: ->
        @mail.processing_cancel_all()
    
    send: ->
        @mail.send "delegate0", "delegate1", "subject", 
            #
            # Send a message long enough to require a multi-byte
            # length prefix (longer than 256)
            #
            """
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            end of transmission
            """
    box: ->
        @rpc.run "mail_inbox"

    processing: =>
        @rpc.run("mail_get_processing_messages").then (response) ->
            for x in response
                console.log "processing_message", x

class TestNet

    WEB_ROOT=process.env.WEB_ROOT
    console.log "(param 1) WEB_ROOT=",WEB_ROOT

    WALLET_JSON="#{WEB_ROOT}/test/testnet/keys/default-wallet-backup.json"

    constructor: (@rpc, @common) ->

    unlock: ->
        @rpc.run """
            open default
            unlock 9999 Password00
        """

    mkdefault: ->
        @rpc.run """
            wallet_backup_restore #{WALLET_JSON} default Password00
        """
###
$BTS_BUILD/programs/client/bitshares_client --rpcport=3000 --httpport=2211 --rpcuser=test --rpcpassword=test --upnp=false --genesis-config init_genesis.json --data-dir tmp/client_tn --server

open default
unlock 9999 Password00

wallet_list_accounts
mail_send tester tester subject body
mail_get_processing_messages

## block production must be enabled
register tester tester "" -1 "titan_account"

###

TestNetTest = =>

    tn=new TestNet(@rpc, @common)
    tn.unlock()

    ## vi tmp/client_p8I/config.json  # "mail_server_enabled": true,
    ## web_wallet/test/testnet$ RPC_JSON_PORT=3000 ./client.sh tmp/client_p8I
    ## web_wallet/test/crypto$ coffee -w scratchpad_mail.coffee 3000

    m=new MailTest(@rpc, @common)
    m.send()

    @rpc.run "mail_check_new_messages"
    #m.clear()
    m.processing()
    m.box()

TestNetTest()

@rpc.close()

