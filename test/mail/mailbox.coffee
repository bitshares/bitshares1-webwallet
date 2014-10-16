
console.log "-------------------"

decode_msg = ->
    ByteBuffer=require 'bytebuffer'
    msg="0373756203626f640000000000000000000000000000000000000000001f63d9f9e1205256d57cbf3641d4e6753521fea3f066ebc9b7d84cf49fd5ca126c2e47c47f39e8394ea57a66da7e78fe83da9ef9ae8a07ecd54c786928e0db170d"
    bb=ByteBuffer.fromHex(msg, true)
    #len=bb.readUint8()
    console.log "Subject: " + bb.readVString()
    console.log bb.readVString()
#decode_msg()

{RpcJson} = require './rpc_json'
rpc = new RpcJson(on, 3000)
rpc.request("login test test").then (response) ->
    rpc.request("wallet_create default Password00")
    rpc.request([
        "open default"
        "unlock 9999 Password00"
    ]).then (response) ->
        console.log 'Logged in, wallet open and unlocked...'
        
        rpc.request("mail_inbox").then (data) ->
            console.log "inbox",data
    
        ###
            Send a message long enough to require a multi-byte
            length prefix (longer than 256)
        ###
        rpc.request("mail_send", [
            "jtest","jtest","The Subject", 
            
            """
            What have you seen?
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            12345678901234567890123456789012345678901234567890
            end of transmission
            """
        ]).then (response) ->
            message_id = response
            console.log "Submitted Message ID",message_id
            found=no
            check_messages = ->
                console.log "mail_get_processing_messages"
                rpc.request("mail_get_processing_messages").then (response) ->
                    y = x[0] for x in response when x[1] == message_id
                    if y
                        console.log "mail_get_processing_messages",y
                        rpc.end()
                    else
                        setTimeout(check_messages, 2000)
    
            check_messages()
        
    , (error) ->
        console.log "error",error