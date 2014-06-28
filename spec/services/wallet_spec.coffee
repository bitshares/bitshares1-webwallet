describe "service: Wallet", ->

  beforeEach -> module("app")

  beforeEach inject ($q, $rootScope, @Wallet, RpcService) ->
    @rootScope = $rootScope
    @deferred = $q.defer()
    @rpc = spyOn(RpcService, 'request').andReturn(@deferred.promise)

  describe "#create", ->

    it "should process correct rpc response", ->
      @Wallet.create 'test', 'password'
      @deferred.resolve {result: true}
      @rootScope.$apply()
      expect(@rpc).toHaveBeenCalledWith('wallet_create', ['test', 'password'])
