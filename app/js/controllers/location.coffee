angular.module("app").controller "LocationController", ($scope, $location, $modal, $q, $http, $rootScope, Wallet, Client, $idle, Shared) ->
  $scope.unlockwallet = false
  console.log $location.path()
  if $location.path() == "/unlockwallet"
      $scope.unlockwallet = true
