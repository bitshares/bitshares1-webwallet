servicesModule = angular.module("app.services")

servicesModule.factory "Growl", ->

  error: (title, message) ->
    jQuery.growl.error(title: title, message: message)

  notice: (title, message) ->
    jQuery.growl.notice(title: title, message: message)

  warning: (title, message) ->
    jQuery.growl.warning(title: title, message: message)
