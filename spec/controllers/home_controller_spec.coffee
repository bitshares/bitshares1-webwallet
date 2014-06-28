describe "controller: HomeController", ->

  beforeEach -> module("app")

  beforeEach inject ($q, $controller, @$rootScope, @$state, Wallet) ->
    @scope  = @$rootScope.$new()
    @deferred = $q.defer()
    @wallet = spyOn(Wallet, 'get_balance').andReturn(@deferred.promise)
    @controller = $controller('HomeController', {$scope: @scope, @wallet})

  it 'should transition to #home', ->
    # nothing to do here


