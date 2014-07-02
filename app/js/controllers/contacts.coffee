angular.module("app").controller "ContactsController", ($scope, $state, $location, $modal, $q, $http, $rootScope, RpcService, WalletAPI, Shared, Utils) ->
    $scope.contacts = []

    $scope.refresh_contacts = ->
        WalletAPI.list_accounts().then (contacts) ->
            $scope.contacts = []

            for c in contacts
                if !c.is_my_account and !Utils.is_registered(c)
                    $scope.contacts.push c

    $scope.refresh_contacts()

    $scope.deleteContact = (name) ->
        WalletAPI.remove_contact_account(name).then ->
            $scope.refresh_contacts()

    $scope.newContactModal = ->
        $modal.open
            templateUrl: "newcontact.html"
            controller: "NewContactController"
            resolve:
                refresh:  -> $scope.refresh_contacts
              
###
  $scope.sendHimFunds = (contact) ->
    Shared.contactName = contact.entity.Label.name
    $state.go "transfer"
###
