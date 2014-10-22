CryptoJS = require("crypto-js")
assert = require("assert")

###*
@see https://code.google.com/p/crypto-js/#The_Cipher_Input
###
describe "Crypto", ->
  
  # wallet.json backup under 'encrypted_key'  
  encrypted_key = "37fd6a251d262ec4c25343016a024a3aec543b7a43a208bf66bc80640dff" + "8ac8d52ae4ad7500d067c90f26189f9ee6050a13c087d430d24b88e713f1" + "5d32cbd59e61b0e69c75da93f43aabb11039d06f"
  
  # echo -n Password01|sha512|xxd -p
  #password
  #initalization vector
  password_sha512 = "a5d69dffbc219d0c0dd0be4a05505b219b973a04b4f2cd1979a5c9fd65bc0362" + "2e4417ec767ffe269e5e53f769ffc6e1" + "6bf05796fddf2771e4dc6d1cb2ac3fcf" #discard
  decrypted_key = "ab0cb9a14ecaa3078bfee11ca0420ea2" + "3f5d49d7a7c97f7f45c3a520106491f8" + "00000000000000000000000000000000000000000000000000000000" + "00000000"
  
  #https://github.com/InvictusInnovations/fc/blob/978de7885a8065bc84b07bfb65b642204e894f55/src/crypto/aes.cpp#L330
  #Bitshares aes_decrypt uses part of the password hash as the initilization vector
  #console.log(password_sha512.substring(64,96))
  iv = CryptoJS.enc.Hex.parse(password_sha512.substring(64, 96))
  
  #console.log(password_sha512.substring(0,64)
  key = CryptoJS.enc.Hex.parse(password_sha512.substring(0, 64))
  
  # Convert data into word arrays (used by Crypto)
  cipher = CryptoJS.enc.Hex.parse(encrypted_key)
  it "Decrypts master key", ->
    
    # see wallet_records.cpp master_key::decrypt_key
    decrypted = CryptoJS.AES.decrypt(
      ciphertext: cipher
      salt: null
    , key,
      iv: iv
    )
    
    #master private key=
    #console.log(CryptoJS.enc.Hex.stringify(decrypted))
    assert.equal decrypted_key, CryptoJS.enc.Hex.stringify(decrypted)
