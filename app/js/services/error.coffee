servicesModule = angular.module("app.services", [])

servicesModule.config ($httpProvider) ->
  $httpProvider.interceptors.push('myHttpInterceptor')

servicesModule.factory "myHttpInterceptor", ($q, $rootScope, Growl) ->
  dont_report_methods = ["wallet_open", "wallet_unlock", "walletpassphrase", "get_info", "blockchain_get_block_by_number", "wallet_get_account"]

#  request: (config) ->
#    config
#
#  response: (response) ->
#    response

  responseError: (response) ->
    promise = null
    method = null
    error_msg = if response.data?.error?.message? then response.data.error.message else response.data
    if response.config? and response.config.url.match(/\/rpc$/)
      if error_msg.match(/No such wallet exists/)
        location.href = "blank.html#/createwallet"
      if error_msg.match(/is_open\(\)\:/)
        promise = $rootScope.open_wallet_and_repeat_request("open_wallet", response.config.data)
      if error_msg.match(/The wallet's spending key must be unlocked before executing this command/)
        promise = $rootScope.open_wallet_and_repeat_request("unlock_wallet", response.config.data)
      if error_msg.match(/Invalid password/)
        Growl.error "Wrong Password", ""
      if error_msg.match(/BTS_WALLET_MIN_PASSWORD_LENGTH/)
        Growl.error "Wrong Password", ""
      method = response.config.data?.method
      error_msg = if method then "In method '#{method}': #{error_msg}" else error_msg
    else if response.message
      error_msg = response.message
    console.log "#{error_msg.substring(0, 512)} (#{response.status})", response
    method_in_dont_report_list = method and (dont_report_methods.filter (x) -> x == method).length > 0
    if !promise and !method_in_dont_report_list
      Growl.error "RPC Server Error", "#{error_msg.substring(0,512)} (#{response.status})"
    return (if promise then promise else $q.reject(response))
