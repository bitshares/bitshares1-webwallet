angular.module("app").filter "is_my_account", ()->
    (account) ->
        console.log(account.is_my_account)
        account.is_my_account
