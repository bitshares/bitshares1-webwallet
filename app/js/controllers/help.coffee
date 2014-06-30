angular.module("app").controller "HelpController", ($scope, RpcService) ->
  RpcService.request('about').then (response) =>  #TODO replace when CommonAPI is added
      $scope.about=response.result
