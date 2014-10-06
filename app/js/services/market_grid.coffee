class MarketGrid

    defaultParams:
        enableColumnMenu: false
        enableSorting: false
        minRowsToShow: 14
        rowHeight: 26
        data: []

    initGrid: ->
        angular.extend({}, @defaultParams)

    setupBidsAsksGrid: (grid, data, market) ->
        params =
            columnDefs: [
                field: "quantity"
                displayName: "#{@filter('translate')('th.quantity')}  (#{market.quantity_symbol})"
                cellFilter: "formatDecimal:#{market.quantity_precision}"
            ,
                field: "price"
                displayName: "#{@filter('translate')('th.price')}  (#{market.price_symbol})"
                cellFilter: "formatDecimal:#{market.price_precision+4}:true"
            ,
                field: "cost"
                displayName: "#{@filter('translate')('th.total')}  (#{market.base_symbol})"
                cellFilter: "formatDecimal:#{market.base_precision}"
            ]
            data: data
        angular.extend grid, params


    constructor: (@q, @log, @filter) ->


angular.module("app").service("MarketGrid", ["$q", "$log", "$filter",  MarketGrid])
