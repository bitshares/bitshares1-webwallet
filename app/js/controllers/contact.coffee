angular.module("app").controller "ContactController", ($scope, Wallet, $location, Shared) ->
	$scope.contactName = Shared.contactName
	$scope.contactAddress = Shared.contactAddress

	$scope.voteUp = ->
		Wallet.wallet_set_delegate_trust_level($scope.contactName, 1).then (trx) ->
			$scope.vote_up = !$scope.vote_up
			$scope.vote_down = false

	$scope.voteDown = ->
		Wallet.wallet_set_delegate_trust_level($scope.contactName, -1).then (trx) ->
			$scope.vote_down = !$scope.vote_down
			$scope.vote_up = false

