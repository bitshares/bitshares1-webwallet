angular.module("app").filter "my_accounts", ()->
    (accounts) ->
        console.log(account.is_my_account)
        account.is_my_account
