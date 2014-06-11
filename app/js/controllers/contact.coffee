angular.module("app").controller "ContactController", ($scope, Wallet, $location, $stateParams) ->
	$scope.contactName = $stateParams.name
	$scope.contactAddress = "Make a request for contact address"

	$scope.voteUp = ->
		Wallet.wallet_set_delegate_trust_level($scope.contactName, 1).then (trx) ->
			$scope.vote_up = !$scope.vote_up
			$scope.vote_down = false

	$scope.voteDown = ->
		Wallet.wallet_set_delegate_trust_level($scope.contactName, -1).then (trx) ->
			$scope.vote_down = !$scope.vote_down
			$scope.vote_up = false

	Wallet.wallet_get_account($scope.contactName).then (resp) ->
		console.log(resp)
		$scope.vote_up = (if resp.trust_level > 0 then true else false)
		$scope.vote_down = (if resp.trust_level < 0 then true else false)
