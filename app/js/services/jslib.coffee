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
        version_name = (->
            return "" unless base_tag
            version = base_tag.getAttribute("href").match /[\w]+/
            return "" unless version.length > 0
            version[0]
        )()
        
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
        
        js_client.event 'wallet.locked', ()->
            console.log '... js_client.wallet_api.current_wallet_name', js_client.wallet_api.current_wallet_name
            if js_client.wallet_api.current_wallet_name is "guest"
                
                navigate_to "login"
            else
                # reload page (stay on same version url path)
                location.href = base_path + "/markets"

angular.module("app").service "BitsharesJsRpc", 
    ["RpcService", "Growl", "$timeout", "$translate", BitsharesJsRpc]

angular.module("app").run (BitsharesJsRpc, RpcService)->
    #console.log "[BitShares-JS] included"