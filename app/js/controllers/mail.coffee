angular.module("app").controller "MailController", ($scope, mail, MailAPI) ->

    mail.check_inbox()
    $scope.inbox = mail.inbox
