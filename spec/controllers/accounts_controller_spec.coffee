describe "controller: AccountsController", ->

    accounts_json = '[{"index":7,"id":0,"name":"TestAccount","public_data":null,"owner_key":"XTS6jBU4Q3TQ1UJgYeMAqERRByNW7Xnq1RjuJAArvnwANnv4z7YPe","active_key_history":[["20140702T234915","XTS6jBU4Q3TQ1UJgYeMAqERRByNW7Xnq1RjuJAArvnwANnv4z7YPe"]],"registration_date":"1970-01-01T00:00:00","last_update":"1970-01-01T00:00:00","delegate_info":null,"meta_data":null,"account_address":"XTSMyvCJThzZxpY4BbZwBDQuxihwP4uhitFg","approved":false,"block_production_enabled":false,"private_data":{"gui_data":{"gravatarDisplayName":"Unknown Gravatar"}},"is_my_account":true,"is_favorite":false}]'
    mock_promise =
        then: (callback) ->
            #console.log "mock_promise ----------->", callback
            callback(JSON.parse(accounts_json))


    WalletMockAPI =
        list_accounts: ->
            return mock_promise

        account_balance: ->
            mock =
                then: ->
                    # TODO return something useful here, something like in mock_promise
            return mock

    beforeEach ->
        module("app")

        module ($provide) ->
            $provide.value 'WalletAPI', WalletMockAPI
            return

        inject ($q, $controller, @$rootScope) =>
            @scope = @$rootScope.$new()
            @deferred = $q.defer()
            #@wallet = spyOn(Wallet, 'wallet_unlock').andReturn(@deferred.promise)
            @controller = $controller('AccountsController', {$scope: @scope, @wallet})


    it 'should populate accounts with right balances', ->
        console.log @scope.balances['TestAccount']
        expect @scope.balances['TestAccount'].toBeDefined
        expect @scope.balances['TestAccount']['XTS'].toBeDefined
