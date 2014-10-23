console.log "\n###\n#",process.argv[1],'\n#'

{MailMessage} = require './src/mailmessage'

###
echo 0770...c414 | xxd -r -p - - > _msg
hexdump _msg -C
###

MailMessageParse = ->
    ByteBuffer=require 'bytebuffer'
    data="077375626a656374c50231323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839300a31323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839300a31323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839300a31323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839300a31323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839300a31323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839300a656e64206f66207472616e736d697373696f6e0000000000000000000000000000000000000000001fef84ce41ed1ef17d7541845d0e5ef506f2a94c651c836e53dde7621fda8897890f0251e1f6dbc0e713b41f13e73c2cf031aea2e888fe54f3bd656d727a83fddb"
    mm=MailMessage.fromHex data
    ###
    process.stdout.write "Original:\t"
    ByteBuffer.fromHex(data).printDebug()
    console.log "subject\t\t", mm.subject
    console.log "body\t\t",mm.body
    console.log "reply_to\t", mm.reply_to.toHex()
    console.log "attachments (#{mm.attachments.length})\t",mm.attachments
    console.log "signature\t", mm.signature.toHex()
    ###
    if data isnt mm.toHex(true)
        process.stdout.write "\nRe-created:\t"
        mm.toByteBuffer(true).printDebug()
        throw "Messages do not match #{data} AND #{mm.toHex(true)}" 

    return mm
mailMessage = MailMessageParse()

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


