class MarketGrid

    defaultParams:
        enableColumnMenu: false
        enableSorting: true
        useExternalSorting: false
        minRowsToShow: 14
        rowHeight: 26
        data: []

    initGrid: ->
        deferred = @q.defer()
        angular.extend({rowTemplateDeferred: deferred, rowTemplate: deferred.promise}, @defaultParams)

    setupBidsAsksGrid: (grid, data, market, sort_direction) ->
        params =
            columnDefs: [
                field: "price"
                displayName: "#{@filter('translate')('th.price')} (#{market.price_symbol})"
                cellFilter: "formatDecimal:#{market.price_precision}:true"
                sort: { direction: sort_direction, priority: 1 }
            ,
                field: "quantity"
                displayName: "#{@filter('translate')('th.quantity')} (#{market.quantity_symbol})"
                cellFilter: "formatDecimal:#{market.quantity_precision}"
                sort: { direction: "asc", priority: 2 }
            ,
                field: "cost"
                displayName: "#{@filter('translate')('th.total')} (#{market.base_symbol})"
                cellFilter: "formatDecimal:#{market.base_precision}"
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
                sort: { direction: "asc", priority: 1 }
            ,
                field: "cost"
                displayName: "#{@filter('translate')('th.units_owed')} (#{actual_market.base_symbol})"
                cellFilter: "formatDecimal:#{actual_market.base_precision}"
                sort: { direction: "asc", priority: 2 }
            ,
                field: "collateral"
                displayName: "#{@filter('translate')('th.collateral')} (#{actual_market.quantity_symbol})"
                cellFilter: "formatDecimal:#{actual_market.quantity_precision}"
             ,
                field: "expiration_days"
                displayName: "#{@filter('translate')('th.expiration')}"
            ]
            data: data

        rowTemplate = '''
            <div ng-repeat="(colRenderIndex, col) in colContainer.renderedColumns track by col.colDef.name"
                 class="ui-grid-cell" ui-grid-cell>
            </div>
        '''
        grid.rowTemplateDeferred.resolve(rowTemplate)
        angular.extend grid, params


    constructor: (@q, @log, @filter) ->


angular.module("app").service("MarketGrid", ["$q", "$log", "$filter",  MarketGrid])
