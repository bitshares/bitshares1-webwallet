console.log "\n###\n#",process.argv[1],'\n#'

ByteBuffer=require 'bytebuffer'

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

MailMessageParse = ->

    data="077375626a656374c50231323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839300a31323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839300a31323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839300a31323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839300a31323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839300a31323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839300a656e64206f66207472616e736d697373696f6e0000000000000000000000000000000000000000001fef84ce41ed1ef17d7541845d0e5ef506f2a94c651c836e53dde7621fda8897890f0251e1f6dbc0e713b41f13e73c2cf031aea2e888fe54f3bd656d727a83fddb"
    process.stdout.write "Original:\t"
    ByteBuffer.fromHex(data).printDebug()
    throw "Parse and re-generate failed" unless\
        ByteBuffer.fromHex(data).toHex() is data

    mm=MailMessage.fromHex data
    console.log "subject\t\t", mm.subject
    console.log "body\t\t",mm.body
    console.log "reply_to\t", mm.reply_to.toHex()
    console.log "attachments (#{mm.attachments.length})\t",mm.attachments
    console.log "signature\t", mm.signature.toHex()

    if data isnt mm.toHex(true)
        process.stdout.write "\nRe-created:\t"
        mm.toByteBuffer(true).printDebug()
        throw "Messages do not match #{data} AND #{mm.toHex(true)}" 

    return mm
mailMessage = MailMessageParse()
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
MailMessageVerify = ->

    ECSignature = require("./src/ecsignature")
    crypto = require('./src/crypto')
    ecdsa = require('./src/ecdsa')
    ecurve = require('ecurve')
    curve = ecurve.getCurveByName('secp256k1')
    bs58 = require('bs58')
    BigInteger = require('bigi')

    signature = ->
        signature_buffer = new Buffer(mailMessage.signature.toHex(), "hex")
        ECSignature.parseCompact(signature_buffer)
    signature = signature().signature

    # what is being signed = mailMessage.toByteBuffer(false).printDebug()
    hash = ->
        mail_buffer = new Buffer(mailMessage.toHex(false), "hex")
        crypto.sha256(mail_buffer)
    hash = hash()

    d = ->
        #privateKeyBs58 = "5JSSUaTbYeZxXt2btUKJhxU2KY1yvPvPs6eh329fSTHrCdRUGbS"# init1
        #privateKeyBuffer = bs58.decode(privateKeyBs58)
        #privateKeyHex = privateKeyBuffer.toString("hex")
        #console.log privateKeyHex
        privateKeyHex = "52173306ca0f862e8fbf8e7479e749b9859fa78588e0e5414ec14fc8ae51a58b"
        BigInteger.fromHex(privateKeyHex)
    d = d()
    Q = curve.G.multiply(d)
    verified = ecdsa.verify(curve, hash, signature, Q)
    if verified
        console.log "Mail message verified"
    else
        throw "Mail message did not verify"

MailMessageVerify()

SignVerify = ->
    crypto = require('./src/crypto')
    ecdsa = require('./src/ecdsa')
    BigInteger = require('bigi')
    ecurve = require('ecurve')
    curve = ecurve.getCurveByName('secp256k1')
    bs58 = require('bs58')

    message = "abc"
    hash = crypto.sha256(message)
    
    d = ->
        privateKeyBs58 = "5JSSUaTbYeZxXt2btUKJhxU2KY1yvPvPs6eh329fSTHrCdRUGbS"
        privateKeyBuffer = bs58.decode(privateKeyBs58)
        privateKeyHex = privateKeyBuffer.toString("hex")
        BigInteger.fromHex(privateKeyHex)
    d = d()
    Q = curve.G.multiply(d)
    signature = ecdsa.sign(curve, hash, d)
    throw "does not verify" unless ecdsa.verify(curve, hash, signature, Q)
    throw "should not verify" if ecdsa.verify(curve, crypto.sha256("def"), signature, Q)
SignVerify()


