
class Mail

    constructor: (@q, @MailAPI) ->
        @inbox = []

angular.module("app").service("mail", ["$q", "MailAPI", Mail])


