console.log "\n###\n#",process.argv[1],'\n#'

ByteBuffer=require 'bytebuffer'

class MailMessage

    constructor: (@subject, @body, @reply_to, @attachments, @signature) ->

    MailMessage.fromByteBuffer= (bb) ->
        subject = bb.readVString()
        body = bb.readVString()

        # reply_to message Id ripemd 160 (160 bits / 8 = 20 bytes)
        reply_to = bb.copy(bb.offset, bb.offset + 20).toBinary()
        bb.skip 20

        attachments = Array(bb.readVarint32())
        throw "Message with attachments has not been implemented" unless attachments.length is 0

        signature = bb.copy(bb.offset, bb.offset + 65).toBinary()
        bb.skip 65

        throw "Message contained #{bb.remaining()} unknown bytes" unless bb.remaining() is 0

        new MailMessage(subject, body, reply_to, attachments, signature)

    MailMessage.fromHex= (data) ->
        bb=ByteBuffer.fromHex(data)
        return MailMessage.fromByteBuffer(bb)

    toByteBuffer: ->
        bb = new ByteBuffer(99)
        bb.writeVString(@subject)
        bb.writeVString(@body)
        bb.append(@reply_to)
        bb.writeVarint32(@attachments.length)
        throw "Message with attachments has not been implemented" unless @attachments.length is 0
        bb.append ByteBuffer.fromBinary @signature
        bb.reset()
        return bb

    toHex: ->
        bb=@toByteBuffer()
        bb.toHex()

MailMessageTest = ->

    data="077375626a65637404626f64790000000000000000000000000000000000000000001f8ba9a5ee77a7946aec1cb5cffc5af687b60ee311c7d14d0bb198ef277187b198034ee6c3b7c9e511a749e3e61eb84258f833f2b360ceec0f5bfafc5114d0c414"
    process.stdout.write "Original:\t"
    ByteBuffer.fromHex(data).printDebug()
    throw "Parse and re-generate failed" unless ByteBuffer.fromHex(data).toHex() is data

    mm=MailMessage.fromHex data
    console.log "subject\t\t", mm.subject
    console.log "body\t\t",mm.body
    console.log "reply_to\t",ByteBuffer.fromBinary(mm.reply_to).toHex()
    console.log "attachments (#{mm.attachments.length})\t",mm.attachments
    console.log "signature\t",ByteBuffer.fromBinary(mm.signature).toHex()

    process.stdout.write "\nRe-created:\t"
    mm.toByteBuffer().printDebug()
    
    throw "Messages do not match #{data} AND #{mm.toHex()}" unless data is mm.toHex()

MailMessageTest()
###
echo 077375626a65637404626f64790000000000000000000000000000000000000000001f8ba9a5ee77a7946aec1cb5cffc5af687b60ee311c7d14d0bb198ef277187b198034ee6c3b7c9e511a749e3e61eb84258f833f2b360ceec0f5bfafc5114d0c414 | xxd -r -p - - > _msg
hexdump _msg -C
00000000  07 73 75 62 6a 65 63 74  04 62 6f 64 79 00 00 00  |.subject.body...|
00000010  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000020  00 00 1f 8b a9 a5 ee 77  a7 94 6a ec 1c b5 cf fc  |.......w..j.....|
00000030  5a f6 87 b6 0e e3 11 c7  d1 4d 0b b1 98 ef 27 71  |Z........M....'q|
00000040  87 b1 98 03 4e e6 c3 b7  c9 e5 11 a7 49 e3 e6 1e  |....N.......I...|
00000050  b8 42 58 f8 33 f2 b3 60  ce ec 0f 5b fa fc 51 14  |.BX.3..`...[..Q.|
00000060  d0 c4 14                                          |...|
00000063

###
