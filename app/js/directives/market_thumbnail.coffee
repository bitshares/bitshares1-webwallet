Highcharts.SparkLine = (options, callback) ->
  defaultOptions =
    chart:
      renderTo: (options.chart and options.chart.renderTo) or this
      backgroundColor: null
      borderWidth: 0
      type: "line"
      margin: [
        2
        0
        2
        0
      ]
      width: 120
      height: 36
      style:
        overflow: "visible"

      skipClone: true

    title:
      text: ""

    credits:
      enabled: false

    xAxis:
      type: "datetime"
      labels:
        enabled: false

      title:
        text: null

      startOnTick: false
      endOnTick: false
      tickPositions: []

    yAxis:
      endOnTick: false
      startOnTick: false
      labels:
        enabled: false

      title:
        text: null

      tickPositions: [0]

    legend:
      enabled: false

    tooltip:
      xDateFormat: "%m/%d/%Y %H:%M%p"
      backgroundColor: null
      borderWidth: 0
      shadow: false
      useHTML: true
      hideDelay: 0
      shared: true
      padding: 0
      positioner: (w, h, point) ->
        x: point.plotX - w / 2
        y: point.plotY - h
      valueDecimals: 2

    plotOptions:
      series:
        animation: false
        lineWidth: 1
        shadow: false
        states:
          hover:
            lineWidth: 1

        marker:
          radius: 1
          states:
            hover:
              radius: 2

        fillOpacity: 0.25

      column:
        negativeColor: "#910000"
        borderColor: "silver"

  options = Highcharts.merge(defaultOptions, options)
  new Highcharts.Chart(options, callback)

angular.module("app.directives").directive "marketThumbnail", ->
    template: '''
        <div class="market-thumbnail">
            <h6>{{name}}</h6>
            <div class="sparkchart pull-right"></div>
            <ul>
                <li>{{market.volume | formatDecimal : market.quantity_precision}} {{market.quantity_symbol}} 24h volume</li>
                <li>{{market.last_price | formatDecimal : market.price_precision}} {{market.price_symbol}}</li>
                <li>{{1.0/market.last_price | formatDecimal : market.price_precision}} {{market.inverse_price_symbol}}</li>
            </ul>
        </div>
    '''
    restrict: "E"
    replace: true
    scope:
        name: "="

    controller: ($scope, $element, $attrs, $q, Utils, BlockchainAPI) ->
        $scope.market = market = { inverted: false }
        prc = (price) -> if market.inverted then 1.0/price else price

        market_symbols = $scope.name.split(':')
        market.quantity_symbol = market_symbols[0]
        market.base_symbol = market_symbols[1]
        market.asset_quantity_symbol = market.quantity_symbol.replace("Bit", "")
        market.asset_base_symbol = market.base_symbol.replace("Bit", "")
        market.price_symbol = "#{market.base_symbol}/#{market.quantity_symbol}"
        market.inverse_price_symbol = "#{market.quantity_symbol}/#{market.base_symbol}"
        #console.log "------ market controller ------>", market
        $q.all([BlockchainAPI.get_asset(market.asset_quantity_symbol), BlockchainAPI.get_asset(market.asset_base_symbol)]).then (results) ->
            market.quantity_asset = results[0]
            market.quantity_precision = market.quantity_asset.precision
            market.base_asset = results[1]
            market.base_precision = market.base_asset.precision
            market.price_precision = Math.max(market.quantity_precision, market.base_precision)
            market.inverted = market.quantity_asset.id > market.base_asset.id
            start_time = Utils.formatUTCDate(new Date(Date.now()-24*3600*1000))
            price_history_call_promise = if market.inverted
                BlockchainAPI.market_price_history(market.asset_quantity_symbol, market.asset_base_symbol, start_time, 24*3600)
            else
                BlockchainAPI.market_price_history(market.asset_base_symbol, market.asset_quantity_symbol, start_time, 24*3600)
            price_history_call_promise.then (result) =>
                market.ohlc_data = []
                market.volume = 0.0
                market.last_price = 0.0
                for t in result
                    time = Utils.toUTCDate(t.timestamp)
                    o = prc(t.opening_price)
                    market.last_price = c = prc(t.closing_price)
                    lowest_ask = prc(t.lowest_ask)
                    highest_bid = prc(t.highest_bid)
                    h = if lowest_ask > highest_bid then lowest_ask else highest_bid
                    l = if lowest_ask < highest_bid then lowest_ask else highest_bid

                    h = o if o > h
                    h = c if c > h
                    l = o if o < l
                    l = c if c < l

                    oc_avg = (o + c) / 2.0
                    h = 1.10 * Math.max(o,c) if h/oc_avg > 1.25
                    l = 0.90 * Math.min(o,c) if oc_avg/l > 1.25

                    market.ohlc_data.push [time, o, h, l, c]
                    market.volume += t.volume / market.quantity_asset.precision

                series = [
                        data: market.ohlc_data,
                        pointStart: 1
                        name: 'Price'
                ]
#                tooltip:
#                        headerFormat: '<span style="font-size: 10px">' + $td.parent().find('th').html() + ', Q{point.x}:</span><br/>',
#                        pointFormat: '<b>{point.y}.000</b> USD'
                $(".sparkchart", $element).highcharts('SparkLine', {series: series})
#

                #console.log "------ ohlc_data ------>", market.volume, market.ohlc_data

