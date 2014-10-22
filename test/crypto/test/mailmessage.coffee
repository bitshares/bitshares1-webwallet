{MailMessage} = require '../src/mailmessage'
{Fixtures} = require('./fixtures/mailmessage')
fixtures = new Fixtures()
assert = require("assert")

describe "MailMessage", ->
    
    it "Parse and regenerate (using HEX)", ->
        fixtures.before.signed_messages.forEach (msg, i) ->
            MailMessage mm = MailMessage.fromHex(msg.hex)
            assert.equal mm.toHex(true), msg.hex

    it "Parses all fields", ->
        fixtures.before.signed_messages.forEach (msg, i) ->
            MailMessage mm = MailMessage.fromHex(msg.hex)
            assert.equal mm.subject, msg.subject, "subject"
            assert.equal mm.body, msg.body, "body"
            assert.equal mm.reply_to.toHex(), msg.reply_to_hex, "reply_to message id"
            assert.equal mm.attachments.length, msg.attachments.length, "num of attachments"
            assert.equal mm.attachments.length, 0, "attachments are not supported"
            assert.equal mm.signature.toHex(), msg.signature_hex, "signature"

    it "Signature Verifies", ->
        ECSignature = require("../src/ecsignature")
        crypto = require('../src/crypto')
        ecdsa = require('../src/ecdsa')
        ecurve = require('ecurve')
        curve = ecurve.getCurveByName('secp256k1')
        BigInteger = require('bigi')
        fixtures.before.signed_messages.forEach (msg, i) ->
            MailMessage mm = MailMessage.fromHex(msg.hex)
            signature = ->
                signature_buffer = new Buffer(msg.signature_hex, "hex")
                ECSignature.parseCompact(signature_buffer)
            signature = signature().signature
        
            # Content that is being signed:
            # mm.toByteBuffer(false).printDebug()
            hash = ->
                mail_buffer = new Buffer(mm.toHex(false), "hex")
                crypto.sha256(mail_buffer)
            hash = hash()

            d = BigInteger.fromHex(msg.private_key_hex)
            Q = curve.G.multiply(d) # public key Q
            assert.equal ecdsa.verify(curve, hash, signature, Q), true, "signature verify"

