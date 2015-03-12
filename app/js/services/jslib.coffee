###* 
  Re-direct some RPC calls to BitShares-JS.  Only enabled  
  if ./vendor/js/bts.js is present.
###
class BitsharesJsRpc
    
    constructor: (@RpcService, @Growl, $timeout, $translate) ->
        
        return unless bts = window.bts
        WalletService = Wallet
        Wallet = null #
        
        base_tag = document.getElementsByTagName('base')[0]
        base_path = if base_tag then base_tag.getAttribute("href") else ""
        version_name = if base_tag then base_tag.getAttribute("href").match /[\w]+/ else ""
        
        console.log "[BitShares-JS] enabled #{version_name}"
        
        error_translator= (message)->
            message = JSON.parse message
            $translate(message.key, message).then (message)->
                message
        
        JsClient = bts.client.JsClient
        js_client = new JsClient @RpcService, version_name, error_translator
        js_client.init().then ->
            window.wallet_api = js_client.wallet_api
        
        js_client.event 'wallet.not_found', ()->
            #console.log '... window.location.hash', window.location.hash
            unless window.location.hash.match /login$/
                navigate_to "login"
        
        js_client.event 'wallet.must_be_opened',()->
            #console.log '... window.location.hash', window.location.hash
            unless window.location.hash.match /login$/
                navigate_to "login"
        
        js_client.event 'wallet.active_key_updated',=>
            @Growl "","Active key updated"
        
        js_client.event 'wallet.locked', ()->
            location.href = base_path

angular.module("app").service "BitsharesJsRpc", 
    ["RpcService", "Growl", "$timeout", "$translate", BitsharesJsRpc]

angular.module("app").run (BitsharesJsRpc, RpcService)->
    #console.log "[BitShares-JS] included"