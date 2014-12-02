class Email

    constructor: (@subject, @body, @reply_to, @attachments, @signature) ->
        assert @subject isnt null, "subject is required"
        assert @body isnt null, "body is required"
        @reply_to = new Buffer("0000000000000000000000000000000000000000", 'hex').toString('binary') unless @reply_to
        @attachments = [] unless @attachments

    Email.fromByteBuffer= (b) ->
        subject = b.readVString()
        body = b.readVString()

        # reply_to message Id ripemd 160 (160 bits / 8 = 20 bytes)
        len = 20
        _b = b.copy(b.offset, b.offset + len); b.skip len
        reply_to = new Buffer(_b.toBinary(), 'binary')

        # FC_REFLECT( bts::mail::attachment, (name)(data) )
        attachments = Array(b.readVarint32())
        throw "Message with attachments has not been implemented" unless attachments.length is 0

        sig_bin = b.copy(b.offset, b.offset + 65).toBinary(); b.skip 65
        sig_buf = new Buffer sig_bin, 'binary'
        #signature = Signature.fromBuffer sig_buf
        
        throw "Message contained #{b.remaining()} unknown bytes" unless b.remaining() is 0
        new Email(subject, body, reply_to, attachments, signature)

    toByteBuffer: (include_signature = true) ->
        b = new ByteBuffer(ByteBuffer.DEFAULT_CAPACITY, ByteBuffer.LITTLE_ENDIAN)
        b.writeVString @subject
        b.writeVString @body
        b.append @reply_to.toString('binary'), 'binary'
        b.writeVarint32 @attachments.length
        throw "Message with attachments has not been implemented" unless @attachments.length is 0
        
        #b.append @signature.toBuffer().toString('binary'), 'binary' if include_signature
        return b.copy 0, b.offset

    ### <helper_functions> ###
    
    Email.fromBuffer = (buf) ->
        b = ByteBuffer.fromBinary buf.toString('binary'), ByteBuffer.LITTLE_ENDIAN
        Email.fromByteBuffer b

    toBuffer: (include_signature) ->
        b=@toByteBuffer(include_signature)
        new Buffer b.toBinary(), 'binary'   
        
    Email.fromHex= (hex) ->
        b = ByteBuffer.fromHex hex
        return Email.fromByteBuffer b

    toHex: (include_signature) ->
        b=@toByteBuffer(include_signature)
        b.toHex()
        
    ### </helper_functions> ###
  
###
class Convert

    Convert.fromHex = (hex) ->
        str = ""; i = 0
        while i < hex.length
            str += String.fromCharCode parseInt(hex.substr(i, 2), 16)
            i += 2
        str
###

###* Private API mail service ###
class Mail
    
    ByteBuffer = window.dcodeIO.ByteBuffer

    constructor: (@q, @MailAPI) ->
        @inbox = []
        
    check_inbox: ->
        @MailAPI.inbox().then (result) =>
            @inbox.length = 0
            ids = {}
            for i in result
                @inbox.push i
                i.time = new Date(i.timestamp).toLocaleString()
                ids[i.id]= i
                ##
                @MailAPI.get_message(i.id).then (result) ->
                    i = ids[result.header.id]
                    i.type = result.content.type
                    switch i.type
                        when 'email'
                            # FC_REFLECT( bts::mail::email_message, (subject)(body)(reply_to)(attachments) )
                            ###
                            email = Email.fromHex result.content.data
                            i.message = email.body
                            ###
                            i.message = ''
                        else
                            i.message = ''
                ####

    
angular.module("app").service("mail", ["$q", "MailAPI", Mail])

