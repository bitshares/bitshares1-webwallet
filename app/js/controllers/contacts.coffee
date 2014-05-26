angular.module("app").controller "ContactsController", ($scope, $location, RpcService, InfoBarService) ->
  $scope.myData = []
  $scope.filterOptions = filterText: ""
  $scope.gridOptions =
    enableRowSelection: false
    enableCellSelection: false
    enableCellEdit: false
    data: "myData"
    filterOptions: $scope.filterOptions
    columnDefs: [
      {
        field: "Label"
        width: 80
        enableCellEdit: true
      }
      {
        field: "Address"
        enableCellEdit: false
      }
      {
        displayName: ""
        enableCellEdit: false
        width: 100
        #btn btn-danger btn-sm
        cellTemplate: "<div class='text-center' style='margin-top:4px'><button title='Copy' class='btn btn-xs btn-link' onclick=\"alert('You clicked  {{row.entity}} ')\"><i class='fa fa-lg fa-copy fa-fw'></i></button><button title='Send' class='btn btn-xs btn-link' onclick=\"alert('You clicked  {{row.entity}} ')\"><i class='fa fa-lg fa-sign-in fa-fw'></i></button><button title='Delete' class='btn btn-xs btn-link' onclick=\"alert('You clicked  {{row.entity}} ')\"><i style='color:#d14' class='fa fa-lg fa-times fa-fw'></i></button></div>"
        headerCellTemplate: "<div class='text-center' style='background:none; margin-top:2px'><i class='fa fa-wrench fa-fw fa-2x'></i></div>"
        #<i class='fa fa-copy fa-fw'></i>
      }
    ]
    
  $scope.filterNephi = ->
    filterText = "name:Nephi"
    if $scope.filterOptions.filterText is ""
      $scope.filterOptions.filterText = filterText
    else $scope.filterOptions.filterText = ""  if $scope.filterOptions.filterText is filterText
    return

  $scope.refresh_addresses = ->
    RpcService.request("wallet_list_receive_accounts").then (response) ->
      newData = []
      data = response.result
      i = 0

      while i < data.length
        newData.push
          Label: data[i][0]
          Address: data[i][1]

        i++
      $scope.myData = newData
      InfoBarService.message = "Click labels to edit"


  $scope.refresh_addresses()
