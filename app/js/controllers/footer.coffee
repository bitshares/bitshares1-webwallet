angular.module("app").controller "FooterController", ($scope, Info, Utils, Blockchain, Shared, $filter, WalletAPI) ->
    $scope.connections = 0
    $scope.blockchain_blocks_behind = 0
    $scope.blockchain_status = "off"
    $scope.blockchain_last_block_num = 0
    $scope.alert_level = "normal-state"
    $scope.message = ""
    $scope.scan_progress_info = ""
    $scope.transaction_scanning_disabled = false
    transaction_scanning_enabling = false

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
        connections = info.network_connections
        $scope.connections = connections
        if connections > 1
            $scope.connections_str = "#{connections} network connections"
        else if connections == 1
            $scope.connections_str = "1 network connection"
        else
            $scope.connections_str = "Not connected"

        $scope.connections_class = if connections < 4 then "signal-#{connections}" else "signal-4"

        $scope.wallet_unlocked = info.wallet_unlocked

        if connections > 0
            if info.last_block_time
                seconds_diff = (Date.now() - Utils.toDate(info.last_block_time).getTime()) / 1000
                hours_diff = Math.floor seconds_diff / 3600
                minutes_diff = (Math.floor seconds_diff / 60) % 60
                hours_diff_str = if hours_diff == 1 then "#{hours_diff} hour" else "#{hours_diff} hours"
                minutes_diff_str = if minutes_diff == 1 then "#{minutes_diff} minute" else "#{minutes_diff} minutes"

                Blockchain.get_info().then (config) ->
                    $scope.blockchain_blocks_behind = Math.floor seconds_diff / (config.block_interval)
                    $scope.blockchain_time_behind = "#{hours_diff_str} #{minutes_diff_str}"
                    $scope.blockchain_status = if $scope.blockchain_blocks_behind < 2 then "synced" else "syncing"
                    $scope.blockchain_last_block_num = info.last_block_num
                    if seconds_diff > (config.block_interval + 2)
                        $scope.blockchain_last_sync_info = "Last block was synced " + $filter("formatSecond")(info.blockchain_head_block_age) + " ago"
                    else
                        $scope.blockchain_last_sync_info = "Blocks are synced "
            else
                $scope.blockchain_status = "off"
                $scope.blockchain_last_sync_info = " Blocks are syncing ..."
        else
            $scope.blockchain_status = "off"
            $scope.blockchain_last_sync_info = "Not connected "

        if info.wallet_scan_progress == -1
            if info.transaction_scanning
                if transaction_scanning_enabling
                    $scope.scan_progress_info = "Enabling Transaction Scanning"
                else
                    $scope.transaction_scanning_disabled = true
                    $scope.scan_progress_info = "Transaction Scanning Disabled"
            else
                $scope.scan_progress_info = "Failure during transaction scanning"
        else if info.wallet_scan_progress >= 0 and info.wallet_scan_progress < 1
            $scope.scan_progress_info = "Transaction scanning progress is " + Math.floor(info.wallet_scan_progress * 100) + "%"
        else
            $scope.scan_progress_info = ""

        if info.alert_level == "green"
            $scope.alert_level = "normal-state"
            $scope.alert_level_msg = ''
            $scope.alert_level_tip = ''
        else if info.alert_level == "yellow"
            $scope.alert_level = "warning-state"
            $scope.alert_level_msg = 'Caution | '
            $scope.alert_level_tip = 'Delegate participation rate is below 90%'
        else if info.alert_level == "red"
            $scope.alert_level = "severe-state"
            $scope.alert_level_msg = 'Severe network problems | '
            $scope.alert_level_tip = 'Delegate participation rate is below 60%'
        else
            $scope.alert_level = "other-state"
            $scope.alert_level_msg = ''
            $scope.alert_level_tip = ''

    $scope.$watch(watch_for, on_update, true)
