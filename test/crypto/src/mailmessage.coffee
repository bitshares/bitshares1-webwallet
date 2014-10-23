
ByteBuffer = require('bytebuffer')
# https://github.com/dcodeIO/ByteBuffer.js/issues/34
ByteBuffer = ByteBuffer.dcodeIO.ByteBuffer if ByteBuffer.dcodeIO

class MailMessage



    constructor: (@subject, @body, @reply_to, @attachments, @signature) ->

    MailMessage.fromByteBuffer= (b) ->
        subject = b.readVString()
        body = b.readVString()

        # reply_to message Id ripemd 160 (160 bits / 8 = 20 bytes)
        reply_to = b.copy(b.offset, b.offset + 20)
        b.skip 20

        attachments = Array(b.readVarint32())
        throw "Message with attachments has not been implemented" unless attachments.length is 0

        signature = b.copy(b.offset, b.offset + 65)
        b.skip 65

        throw "Message contained #{b.remaining()} unknown bytes" unless b.remaining() is 0

        new MailMessage(subject, body, reply_to, attachments, signature)

    MailMessage.fromHex= (data) ->
        b=ByteBuffer.fromHex(data)
        return MailMessage.fromByteBuffer(b)

    toByteBuffer: (include_signature) ->
        b = new ByteBuffer()
        b.writeVString @subject
        b.writeVString @body
        b.append @reply_to.copy()
        b.writeVarint32 @attachments.length
        throw "Message with attachments has not been implemented" unless @attachments.length is 0
        b.append @signature.copy() if include_signature
        return b.copy(0, b.offset)

    toHex: (include_signature) ->
        b=@toByteBuffer(include_signature)
        b.toHex()

exports.MailMessage = MailMessage
