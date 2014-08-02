servicesModule = angular.module("app.services")

servicesModule.factory "Shared", ->
    return { contactName: null, message: ""}
