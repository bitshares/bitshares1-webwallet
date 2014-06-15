angular.module("app").filter "is_my_account", ()->
    (account) ->
        account.is_my_account
