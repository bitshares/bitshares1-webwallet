###* 
  Re-direct some RPC calls to BitShares-JS.  Only enabled  
  if ./vendor/js/bts.js is present.
###
class BitsharesJsRpc
    
    constructor: (@RpcService, @Growl, $timeout) ->
        
        return unless bts = window.bts
        console.log "[BitShares-JS] enabled"
        
        JsClient = bts.client.JsClient
        js_client = new JsClient @RpcService, @Growl
        js_client.init().then ->
            window.wallet_api = js_client.wallet_api
        
        js_client.event 'wallet.not_found', ()->
            unless window.location.hash == "#/brainwallet"
                navigate_to "brainwallet"
        
        js_client.event 'wallet.must_be_opened',()->
            unless window.location.hash == "#/brainwallet"
                navigate_to "brainwallet"
        
        js_client.event 'wallet.active_key_updated',=>
            @Growl "","Active key updated"
        
        js_client.event 'wallet.locked', ()->
            $timeout ->
                window.location.reload()
            ,
                100
    
angular.module("app").service "BitsharesJsRpc", 
    ["RpcService", "Growl", "$timeout", BitsharesJsRpc]

angular.module("app").run (BitsharesJsRpc, RpcService)->
    #console.log "[BitShares-JS] included"