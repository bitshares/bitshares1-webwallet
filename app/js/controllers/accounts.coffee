angular.module("app").controller "AccountsController", ($scope, $location, RpcService, Growl) ->
    $scope.new_address_label = ""
    $scope.addresses = []
    $scope.wallet_file = ""
    $scope.wallet_password = ""
    non0addr={}


    #TODO ADD a Barrier or something to deal with race condition
    refresh_addresses = ->
        RpcService.request('wallet_account_balance').then (response) ->
            console.log(response.result)
            non0addr={}
            angular.forEach response.result, (val) ->
                non0addr[val[0]]=val[1]
    refresh_addresses()


    refresh_more_addresses = ->
        RpcService.request('wallet_list_receive_accounts').then (response) ->
            $scope.addresses.splice(0, $scope.addresses.length)
            console.log response.result
            angular.forEach response.result, (val) ->
                active_key = val.active_key_history[val.active_key_history.length - 1][1]
                $scope.addresses.push({
                    name: val.name
                    balance: non0addr[val.name]
                    adress: val.address
                    active_key: active_key
                    regdat: val.registration_date
                })
    refresh_more_addresses()

    $scope.create_address = ->
        RpcService.request('wallet_create_account', [$scope.new_address_label]).then (response) ->
            $scope.new_address_label = ""
            refresh_addresses()
