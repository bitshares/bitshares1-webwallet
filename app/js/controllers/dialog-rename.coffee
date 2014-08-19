angular.module("app").controller "DialogRenameController", ($scope, $modalInstance, oldname, Wallet, $location) ->

    $scope.m = {}
    $scope.m.oldname = oldname
    $scope.m.newname = oldname

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.ok = ->
      Wallet.wallet_rename_account(oldname, $scope.m.newname).then ->
        $modalInstance.close("ok")
        $location.path("accounts/"+$scope.m.newname)
