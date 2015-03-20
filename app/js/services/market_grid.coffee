class MarketGrid

    defaultParams:
        enableColumnMenus: false
        enableSorting: true
        useExternalSorting: false
        minRowsToShow: 11
        rowHeight: 22
        enableVerticalScrollbar: 2
        data: []

    defaultRowTemplate: '''
        <div ng-repeat="(colRenderIndex, col) in colContainer.renderedColumns track by col.colDef.name"
             class="ui-grid-cell" ui-grid-cell>
        </div>
    '''

    sortByTimestamp: (a, b) ->
        return -1 if a.timestamp < b.timestamp
        return  1 if a.timestamp > b.timestamp
        return 0

    initGrid: ->
        deferred = @q.defer()
        angular.extend({rowTemplateDeferred: deferred, rowTemplate: deferred.promise}, @defaultParams)

    setupBidsAsksGrid: (grid, data, market, sort_direction) ->
        params =
            columnDefs: [                
                field: "quantity"
                displayName: "#{@filter('translate')('th.quantity')} (#{market.quantity_symbol})"
                cellFilter: "formatDecimal:#{market.quantity_precision}"
                sort: { direction: "desc", priority: 2 }
            ,
                field: "price"
                displayName: "#{@filter('translate')('th.price')} (#{market.price_symbol})"
                cellFilter: "formatDecimal:#{market.price_precision}:true"
                sort: { direction: sort_direction, priority: 1 }
            ]
            data: data

        rowTemplate = '''
            <div ng-click="getExternalScopes().grid_row_clicked(row.entity)"
                 ng-repeat="(colRenderIndex, col) in colContainer.renderedColumns track by col.colDef.name"
                 class="ui-grid-cell" ng-class="row.entity.type" ui-grid-cell>
            </div>
        '''
        grid.rowTemplateDeferred.resolve(rowTemplate)
        angular.extend grid, params

    setupMarginsGrid: (grid, data, market) ->
        actual_market = market.get_actual_market()
        params =
            columnDefs: [
                field: "price"
                displayName: "#{@filter('translate')('th.call_price')} (#{market.price_symbol})"
                cellFilter: "formatDecimal:#{market.price_precision}:true"
                sort: { direction: "asc", priority: 2 }
            ,
                field: "interest_rate"
                displayName: "#{@filter('translate')('th.interest_rate')}"
                cellFilter: "formatDecimal:2"
                sort: { direction: "desc", priority: 3 }
            ,
                field: "cost"
                displayName: "#{@filter('translate')('th.units_owed')} (#{actual_market.base_symbol})"
                cellFilter: "formatDecimal:#{actual_market.base_precision}"
            ,
                field: "collateral"
                displayName: "#{@filter('translate')('th.collateral')} (#{actual_market.quantity_symbol})"
                cellFilter: "formatDecimal:#{actual_market.quantity_precision}"
             ,
                field: "expiration"
                displayName: "#{@filter('translate')('th.expiration')}"
                sortingAlgorithm: @sortByTimestamp
                cellFilter: "formatSortableExpiration"
                sort: { direction: "asc", priority: 1 }
            ]
            data: data

        grid.rowTemplateDeferred.resolve(@defaultRowTemplate)
        angular.extend grid, params

    setupShortsGrid: (grid, data, market) ->
        actual_market = market.get_actual_market()
        params =
            columnDefs: [
                field: "collateral"
                displayName: "#{@filter('translate')('th.collateral')} (#{actual_market.quantity_symbol})"
                cellFilter: "formatDecimal:#{actual_market.quantity_precision}"
                sort: { direction: "desc", priority: 3 }
            ,
                field: "interest_rate"
                displayName: "#{@filter('translate')('th.interest_rate')}"
                cellFilter: "formatDecimal:2"
                sort: { direction: "desc", priority: 2 }
            ,
                field: "quantity"
                displayName: "~ #{@filter('translate')('th.quantity')} (#{actual_market.base_symbol})"
                cellFilter: "formatDecimal:#{actual_market.base_precision}"
            ,
                field: "short_price_limit"
                displayName: "#{@filter('translate')('th.price_limit')} (#{market.price_symbol})"
                cellFilter: "formatDecimal:#{market.price_precision}"
                sort: { direction: "asc", priority: 1 }
            ]
            data: data

        grid.rowTemplateDeferred.resolve(@defaultRowTemplate)
        angular.extend grid, params

    setupBlockchainOrdersGrid: (grid, data, market) ->
        actual_market = market.get_actual_market()
        params =
            columnDefs: [
                field: "display_type"
                displayName: "#{@filter('translate')('th.type')}"
                width : '10%'
            ,
                field: "price"
                displayName: "#{@filter('translate')('th.order_price')} (#{market.price_symbol})"
                cellFilter: "formatDecimal:#{market.price_precision}:true"
                width : '20%'
            ,
                field: "paid"
                displayName: "#{@filter('translate')('th.paid')} (#{actual_market.quantity_symbol})"
                cellFilter: "formatDecimal:#{actual_market.quantity_precision}"
                width : '20%'
            ,
                field: "received"
                displayName: "#{@filter('translate')('th.received')} (#{actual_market.base_symbol})"
                cellFilter: "formatDecimal:#{actual_market.base_precision}"
                width : '20%'
            ,
                field: "timestamp"
                displayName: "#{@filter('translate')('th.time')}"
                width : '30%'
                sortingAlgorithm: @sortByTimestamp
                cellFilter: "formatSortableTime"
                sort: { direction: "desc", priority: 1 }
            ]
            data: data

        grid.rowTemplateDeferred.resolve(@defaultRowTemplate)
        angular.extend grid, params

    setupAccountOrdersGrid: (grid, data, market) ->
        params =
            columnDefs: [
                field: "memo"
                displayName: "#{@filter('translate')('th.action')}"
                width : '50%'
            ,
                field: "amount_asset"
                displayName: "#{@filter('translate')('th.amount')}"
                cellFilter: "formatAsset"
                width : '22%'
            ,
                field: "time"
                displayName: "#{@filter('translate')('th.time')}"
                width : '28%'
                sortingAlgorithm: @sortByTimestamp
                cellFilter: "formatSortableTime"
                sort: { direction: "desc", priority: 1 }
            ]
            data: data

        grid.rowTemplateDeferred.resolve(@defaultRowTemplate)
        angular.extend grid, params

#    disableMouseScroll: ->
#        $(".ui-grid-viewport, .ui-grid-top-panel").bind 'mousewheel', (e) ->
#            e.stopPropagation()
#            e.preventDefault()
#            content = $("section.content")
#            scrollTo= content.scrollTop() - e.originalEvent.wheelDeltaY
#            content.scrollTop(scrollTo)
#            return false


    constructor: (@q, @log, @filter) ->


angular.module("app").service("MarketGrid", ["$q", "$log", "$filter",  MarketGrid])
