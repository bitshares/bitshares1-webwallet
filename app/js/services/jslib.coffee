###* 
  Re-direct some RPC calls to BitShares-JS.  Only enabled only 
  if ./vendor/js/bts.js is present.
###
class BitsharesJsRpc
    
    constructor: (@RpcService, @Growl) ->
        return unless bts = window.bts
        console.log "[BitShares-JS] enabled\tPassword00"
        JsClient = bts.client.JsClient
        js_client = new JsClient @RpcService, @Growl
        # Wallet API available from the browser's console
        js_client.init().then ->
            window.wallet_api = js_client.wallet_api
            window.wallet = js_client.wallet
        
        js_client.event 'wallet.not_found', ()->
            unless window.location.hash == "#/brainwallet"
                navigate_to "brainwallet"
        
        js_client.event 'wallet.must_be_opened',()->
            unless window.location.hash == "#/brainwallet"
                navigate_to "brainwallet"
    
angular.module("app").service "BitsharesJsRpc", 
    ["RpcService", "Growl", BitsharesJsRpc]

angular.module("app").run (BitsharesJsRpc, RpcService)->
    #console.log "[BitShares-JS] included"