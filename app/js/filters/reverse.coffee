angular.module("app").filter "reverse", ->
  (items) ->
    items.slice().reverse()
