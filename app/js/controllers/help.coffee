angular.module("app").controller "HelpController", ($scope, $location, RpcService) ->
  RpcService.request('about').then (response) =>  #TODO replace when CommonAPI is added
      $scope.about=response.result
      console.log(response.result)
