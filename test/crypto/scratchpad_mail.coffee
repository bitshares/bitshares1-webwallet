console.log "-------------------"
PORT=process.argv[2] or 9989
console.log "(param 1) PORT",PORT

class Mail
    constructor: (@common, @rpc) ->

    send: (
        from = "tester"
        to = "tester"
        subject = "The Subject"
        body = "Body..."
    ) ->
        @rpc.request("mail_send", [from, to, subject, body]).then (response) ->
            @message_id = response
            console.log "Submitted Message ID",message_id

    check: ->
        @common.run("mail_get_processing_messages").then (response) ->
            for x in response
                if x[1] == @message_id
                    console.log "check (status) ", x[0]

    cancel_all: ->
        #https://github.com/BitShares/bitshares_toolkit/commit/57d04e8fb2b0dda15623e83a6855f77b2dc1cbd6
        #mail_cancel_message id
        @common.run("mail_get_processing_messages").then (response) ->
            for x in response
                @common.run("mail_cancel_message #{x[1]}")

MailTest= ->
    {Common} = require "./rpc_common"
    {Rpc} = require "./rpc_json"
    
    @rpc=new Rpc(on, PORT, "localhost", "test", "test")
    @common=new Common(@rpc)
    @common.mkdefault("default", "9999", "Password00")
    @mail=new Mail(@common, @rpc)
    ###
    @mail.send "jtest", "jtest", "subject", 
        #
        # Send a message long enough to require a multi-byte
        # length prefix (longer than 256)
        #
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
    ###
    @common.run "mail_inbox"
    #@mail.cancel_all()
    @mail.check()
    @rpc.close()
MailTest()

class MailMessage
    ByteBuffer=require 'bytebuffer'

    constructor: (@subject, @body) ->
        console.log @subject, @body

    MailMessage.fromHex= (data) ->
        bb=ByteBuffer.fromHex(data, true)
        subject = bb.readVString()
        body = bb.readVString()
        new MailMessage(subject, body)

MailMessageTest= ->
    data="0373756203626f640000000000000000000000000000000000000000001f63d9f9e1205256d57cbf3641d4e6753521fea3f066ebc9b7d84cf49fd5ca126c2e47c47f39e8394ea57a66da7e78fe83da9ef9ae8a07ecd54c786928e0db170d"
    mm=MailMessage.fromHex data
    #len=bb.readUint8()
MailMessageTest()
