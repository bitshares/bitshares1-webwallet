servicesModule = angular.module("app.services")

servicesModule.factory "Shared", ->
  contactName: null

  message: ""
