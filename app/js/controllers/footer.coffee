angular.module("app").controller "FooterController", ($scope, $filter, $translate, Info, Utils, Blockchain, Shared, WalletAPI, RpcService) ->
    $scope.connections = 0
    $scope.blockchain_blocks_behind = 0
    $scope.blockchain_status = "off"
    $scope.blockchain_last_block_num = 0
    $scope.alert_level = "normal-state"
    $scope.message = ""
    $scope.scan_progress_info = ""
    $scope.expected_client_version = Info.expected_client_version
    $scope.transaction_scanning_disabled = false
    transaction_scanning_enabling = false
    $scope.show_version_warning = false
    $scope.client_version = null
    $scope.expected_client_version = null

    $scope.enable_transaction_scanning = ->
        WalletAPI.set_transaction_scanning(true).then ->
            $scope.transaction_scanning_disabled = false
            transaction_scanning_enabling = true

    $scope.$watch ()->
        Shared.message
    , () ->
        $scope.message = Shared.message
        if $scope.message
            setTimeout ()->
                $scope.message = ""
                Shared.message = ""
            , 5000

    watch_for = ->
        Info.info

    on_update = (info) ->
        #console.log "[footer.coffee:35] ----- info ----->", info
        if not $scope.client_version and info.client_version
            $scope.client_version = info.client_version
            $scope.expected_client_version = Info.expected_client_version
            $scope.show_version_warning = Utils.version_to_number(info.client_version) < Utils.version_to_number(Info.expected_client_version)
            if $scope.show_version_warning
                $scope.show_version_warning_td = {expected_client_version: $scope.expected_client_version, client_version: $scope.client_version}
        connections = info.network_connections
        $scope.connections = connections
        if connections > 1
            $translate("footer.n_network_connection", {value: connections}).then (res) -> $scope.connections_str = res
        else if connections == 1
            $translate("footer.one_network_connection").then (res) -> $scope.connections_str = res
        else
            $translate("footer.not_connected").then (res) -> $scope.connections_str = res

        if connections and connections >= 0
            $scope.connections_class = if connections < 4 then "signal-#{connections}" else "signal-4"
        else
            $scope.connections_class = "signal-0"

        $scope.wallet_unlocked = info.wallet_unlocked

        $scope.percent_synced = 100
        $scope.show_progress = false

        if connections > 0
            if info.last_block_time
                seconds_diff = info.seconds_behind
                hours_diff = Math.floor seconds_diff / 3600
                minutes_diff = (Math.floor seconds_diff / 60) % 60
                hours_diff_str = if hours_diff == 1 then "#{hours_diff} hour" else "#{hours_diff} hours"
                minutes_diff_str = if minutes_diff == 1 then "#{minutes_diff} minute" else "#{minutes_diff} minutes"

                $scope.percent_synced = info.percent_synced
                $scope.show_progress = seconds_diff > Info.FULL_SYNC_SECS

                Blockchain.get_info().then (config) ->
                    $scope.blockchain_blocks_behind = Math.floor seconds_diff / (config.block_interval)
                    $scope.blockchain_time_behind = "#{hours_diff_str} #{minutes_diff_str}"
                    $scope.blockchain_status = if $scope.blockchain_blocks_behind < 3 then "synced" else "syncing"
                    $scope.blockchain_last_block_num = info.last_block_num
                    if seconds_diff > (2 * config.block_interval + 2)
                        $translate("footer.last_block", {value: $filter("formatSecond")(info.blockchain_head_block_age)}).then (res) -> $scope.blockchain_last_sync_info = res
                    else
                        $translate("footer.synced").then (res) -> $scope.blockchain_last_sync_info = res
            else
                $scope.blockchain_status = "off"
                $translate("footer.syncing").then (res) -> $scope.blockchain_last_sync_info = res
        else
            $scope.blockchain_status = "off"
            $translate("footer.not_connected").then (res) -> $scope.blockchain_last_sync_info = res

        $scope.blockchain_status_td =
            value: $scope.blockchain_last_block_num
            value1: $scope.blockchain_last_block_num
            value2: $scope.blockchain_last_block_num + $scope.blockchain_blocks_behind


        if info.wallet_scan_progress == -1
            if info.transaction_scanning
                if transaction_scanning_enabling
                    $scope.scan_progress_info = "Enabling Transaction Scanning"
                else
                    $scope.transaction_scanning_disabled = true
                    $scope.scan_progress_info = "Transaction Scanning Disabled"
            else
                $scope.scan_progress_info = "Failure during transaction scanning"
        else if info.wallet_scan_progress and info.wallet_scan_progress >= 0 and info.wallet_scan_progress < 1
            $scope.scan_progress_info = "Transaction scanning progress is " + Math.floor(info.wallet_scan_progress * 100) + "%"
        else
            $scope.scan_progress_info = ""

        if info.alert_level == "green"
            $scope.alert_level = "normal-state"
            $scope.alert_level_msg = ""
            $scope.alert_level_tip = ""
        else if info.alert_level == "yellow"
            $scope.alert_level = "warning-state"
            $translate("footer.network_problems").then (res) -> $scope.alert_level_msg = res
            $translate("footer.delegate_participation_below", {value: "80%"}).then (res) -> $scope.alert_level_tip = res
        else if info.alert_level == "red"
            $scope.alert_level = "severe-state"
            $translate("footer.severe_network_problems").then (res) -> $scope.alert_level_msg = res
            $translate("footer.delegate_participation_below", {value: "60%"}).then (res) -> $scope.alert_level_tip = res
        else
            $scope.alert_level = "other-state"
            $scope.alert_level_msg = ''
            $scope.alert_level_tip = ''
        $scope.blockchain_name = info.blockchain_name

    $scope.$watch(watch_for, on_update, true)
    
    $scope.profile_toggle = ->
        return if magic_unicorn?
        $scope.profiling = !$scope.profiling
        if $scope.profiling
            RpcService.start_profiler()
        else
            RpcService.stop_profiler()
        
