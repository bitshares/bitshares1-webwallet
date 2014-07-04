describe "controller: UnlockWalletController", ->

  beforeEach -> module("app")

  beforeEach inject ($q, $controller, @$rootScope, @$state, Wallet) ->
    @scope  = @$rootScope.$new()
    @deferred = $q.defer()
    @wallet = spyOn(Wallet, 'wallet_unlock').andReturn(@deferred.promise)
    @controller = $controller('UnlockWalletController', {$scope: @scope, @wallet})
    spyOn(@$rootScope, 'history_back')
    spyOn(@$rootScope, 'showLoadingIndicator')
    spyOn(Wallet, 'check_wallet_status')

  it 'should return user back if correct password submitted', ->
    @scope.spending_password = "password"
    @scope.submitForm()
    @deferred.resolve()
    @$rootScope.$apply()
    expect(@scope.wrongPass).toBeFalsy
    expect(@$rootScope.history_back).toHaveBeenCalled()


  it 'should set wrongPass if wallet_unlock rejected', ->
    @scope.spending_password = "password"
    @scope.submitForm()
    @deferred.reject 'wrong password'
    @$rootScope.$apply()
    expect(@scope.wrongPass).toBeTruthy
