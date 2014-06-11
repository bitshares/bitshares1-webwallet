angular.module("app").controller "AccountsController", ($scope, $location, RpcService, Growl) ->
    $scope.new_account_label = ""
    $scope.accounts = []
    $scope.wallet_file = ""
    $scope.wallet_password = ""
    non0addr={}


    #TODO ADD a Barrier or something to deal with race condition
    refresh_accounts = ->
        RpcService.request('wallet_account_balance').then (response) ->
            console.log(response.result)
            non0acct={}
            angular.forEach response.result, (val) ->
                non0acct[val[0]]=val[1]
    refresh_accounts()

    refresh_more_accounts = ->
        RpcService.request('wallet_list_receive_accounts').then (response) ->
            $scope.accounts.splice(0, $scope.accounts.length)
            console.log response.result
            angular.forEach response.result, (val) ->
                active_key = val.active_key_history[val.active_key_history.length - 1][1]
                $scope.accounts.push({
                    name: val.name
                    balance: non0acct[val.name]
                    adress: val.address
                    active_key: active_key
                    regdat: val.registration_date
                })
    refresh_more_accounts()

    $scope.create_account = ->
        RpcService.request('wallet_create_account', [$scope.new_account_label]).then (response) ->
            $scope.new_account_label = ""
            refresh_accounts()
