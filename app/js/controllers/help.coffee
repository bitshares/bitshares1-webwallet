angular.module("app").controller "HelpController", ($scope, RpcService, Info) ->
  RpcService.request('about').then (response) =>  #TODO replace when CommonAPI is added
      $scope.about=response.result

  cancel = $scope.$watch ->
    Info.info.client_version
  , ->
    if (Info.info.client_version)
      cancel()
      $scope.client_version = Info.info.client_version
