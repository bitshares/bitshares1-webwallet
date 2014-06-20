angular.module("app").controller "ContactsController", ($scope, $state, $location, $modal, $q, $http, $rootScope, RpcService, Wallet, Shared) ->
  $scope.myData = []
  $scope.filterOptions = filterText: ""
  $scope.gridOptions =
    enableRowSelection: false
    enableCellSelection: false
    enableCellEdit: false
    data: "myData"
    filterOptions: $scope.filterOptions
    rowHeight: 68
    columnDefs: [
      {
        field: "Label"
        enableCellEdit: false
        displayName: "Name"
        cellTemplate: '<a href="#/accounts/{{row.entity.Label.name}}" class="btn btn-default btn-sm active" style="width:100%; opacity:0.7; text-align:left"><div><div style="font-size: 200%">{{row.entity[col.field].name}}</div><div style="font-family:monospace">{{row.entity[col.field].owner_key}}</div></div></a>'
      }
      #class="btn btn-default btn-sm active" style="width:100%"
      {
        displayName: ""
        enableCellEdit: false
        width: 200
        #btn btn-danger btn-sm
        cellTemplate: "<div class='text-center' style='margin-top:10px'><button title='Copy' class='btn btn-xs btn-link' ng-click='sendHimFunds(row)'><i class='fa fa-3x fa-sign-in fa-fw'></i></button><button title='Send' class='btn btn-xs btn-link'><i class='fa fa-3x fa-copy fa-fw'></i></button><button title='Delete' ng-click='deleteContact(row)' class='btn btn-xs btn-link'><i style='color:#d14' class='fa fa-lg fa-times fa-fw'></i></button></div>"
        headerCellTemplate: "<div class='text-center' style='background:none; margin-top:2px'><i class='fa fa-gear fa-fw fa-2x'></i></div>"
        #<i class='fa fa-copy fa-fw'></i>    ng-click=\"bam()\"
      }
    ]
    
  $scope.filterNephi = ->
    filterText = "name:Nephi"
    if $scope.filterOptions.filterText is ""
      $scope.filterOptions.filterText = filterText
    else $scope.filterOptions.filterText = ""  if $scope.filterOptions.filterText is filterText
    return

  $scope.refresh_addresses = ->
    Wallet.wallet_list_accounts().then (contacts) ->
      newData = []
      data = contacts
      i = 0

      while i < data.length
        if !data[i].is_my_account
          newData.push
            Label: data[i]

        i++
      $scope.myData = newData
  $scope.refresh_addresses()


  $scope.sendHimFunds = (contact) ->
    Shared.contactName = contact.entity.Label.name
    $state.go "transfer"

  #TODO:  instead of chaining calls do calls in parallel and handle callbacks in the right order
  $scope.deleteContact = (row) ->
    Wallet.wallet_remove_contact_account(row.entity.Label.name).then ->
      $scope.refresh_addresses()

  $scope.newContactModal = ->
    $modal.open
      templateUrl: "newcontact.html"
      controller: "NewContactController"
      resolve:
        refresh:  -> $scope.refresh_addresses
          
