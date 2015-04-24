Highcharts.SparkLine = (options, callback) ->
  defaultOptions =
    chart:
      renderTo: (options.chart and options.chart.renderTo) or this
      backgroundColor: null
      borderWidth: 0
      type: "area"
      margin: [
        0
        0
        0
        0
      ]
      padding: 0
      height: 60
      style:
        overflow: "visible"

      skipClone: true

      events:
        click: -> options.chart_click()

      container:
        onclick: null

    title:
      text: ""

    credits:
      enabled: false

    xAxis:
      type: "datetime"
      minRange: 3600 * 1000
      labels:
        enabled: false

      title:
        text: null

      startOnTick: false
      endOnTick: false
      tickPositions: []
            
    legend:
      enabled: false

    tooltip:
      enabled: false

    plotOptions:
      series:
        animation: false
        lineWidth: 1
        shadow: false
        states:
          hover:
            enabled: false

        marker:
          enabled: false

        fillOpacity: 0.25

        point:
          events:
            click: -> options.chart_click()


  options = Highcharts.merge(defaultOptions, options)
  chart = new Highcharts.Chart(options, callback)
  #chart.tooltip.label.attr({zIndex: 9999});
  return chart

angular.module("app.directives").directive "marketThumbnail", ->
    template: '''
        <div class="market-thumbnail">
            <center><span class="spark-title">{{ name }}</span></center>
            <div>
              <span class="high"><label>H:</label> {{ market.high_price | number: 2 }}</span>
              <span class="low"><label>L:</label> {{ market.min_price | number: 2 }}</span>
              <span class="change pull-right" ng-class="{'change-positive':market.change >=0, 'change-negative':market.change < 0}"><span ng-if="market.change>0">+</span>{{ market.change | number: 2 }}%</span>
            </div>
            <div class="volume"><label>V:</label> {{market.volume | formatDecimal : 2}} {{market.asset_quantity_symbol}}</div>
            <div class="sparkchart"></div>
        </div>
    '''
    restrict: "E"
    replace: true
    scope:
        name: "="

    controller: ($scope, $element, $attrs, $q, Utils, BlockchainAPI) ->

        chart_click = ->
            $scope.$parent.select_market($scope.name)

        $scope.market = market = { inverted: false }
        prc = (price) -> if market.inverted then 1.0/price else price

        market_symbols = $scope.name.split(':')
        market.quantity_symbol = market_symbols[0]
        market.base_symbol = market_symbols[1]
        market.asset_quantity_symbol = market.quantity_symbol.replace("Bit", "")
        market.asset_base_symbol = market.base_symbol.replace("Bit", "")
        market.price_symbol = "#{market.base_symbol}/#{market.quantity_symbol}"
        market.inverse_price_symbol = "#{market.quantity_symbol}/#{market.base_symbol}"
        $q.all([BlockchainAPI.get_asset(market.asset_quantity_symbol), BlockchainAPI.get_asset(market.asset_base_symbol)]).then (results) ->
            if results[0] and results[1]
                market.quantity_asset = results[0]
                market.quantity_precision = market.quantity_asset.precision
                market.base_asset = results[1]
                market.base_precision = market.base_asset.precision
                market.price_precision = Math.max(market.quantity_precision, market.base_precision)
                market.inverted = market.quantity_asset.id > market.base_asset.id                
                start_time = Utils.formatUTCDate(new Date(Date.now()-2*24*3600*1000))
                price_history_call_promise = if market.inverted
                    BlockchainAPI.market_price_history(market.asset_quantity_symbol, market.asset_base_symbol, start_time, 2*24*3600)
                else
                    BlockchainAPI.market_price_history(market.asset_base_symbol, market.asset_quantity_symbol, start_time, 2*24*3600)
                price_history_call_promise.then (result) =>
                    return if !result or result.length == 0
                    market.ohlc_data = []
                    market.volume_data = []
                    market.volume = 0.0
                    market.last_price = 0.0
                    market.max_volume = 0
                    market.min_price = 99999999
                    market.high_price = 0
                    market.open = prc(result[0].opening_price)
                    market.close = market.open
                    
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

                        market.ohlc_data.push [time, oc_avg]
                        market.volume_data.push [time, t.quote_volume / market.quantity_asset.precision]
                        market.volume += t.quote_volume / market.quantity_asset.precision
                        market.max_volume = Math.max t.quote_volume / market.quantity_asset.precision, market.max_volume
                        market.min_price = Math.min oc_avg, market.min_price
                        market.high_price = Math.max oc_avg, market.high_price
                        market.close = c;

                    market.max_volume = 3 * Math.floor market.max_volume 
                    market.change = (market.close - market.open) / market.open * 100

                    area_color = if market.change > 0 then '#28a92e' else '#c90808'

                    series = [                            
                            {data: market.volume_data
                            pointStart: 1
                            name: 'Volume'
                            type: 'column'
                            yAxis: 1
                            dataGrouping:
                              enabled: true
                            tooltip:
                              valueDecimals: 0
                              valueSuffix: ' BTS'                            
                            },
                            {data: market.ohlc_data
                            pointStart: 1
                            name: 'Price'
                            dataGrouping:
                              enabled: true
                            tooltip:
                              valueDecimals: 2
                              valueSuffix: ' BTS/'+market.asset_quantity_symbol
                            min: market.min_price
                            color: area_color
                            }
                    ]



                    yAxis = [
                      {
                        opposite: true,
                        labels:
                          enabled: false
                        title:
                          text: null
                        gridLineWidth: 0      
                        min: 0.98 * market.min_price                  
                      },
                      {
                        endOnTick: false
                        startOnTick: false
                        labels:
                          enabled: false

                        title:
                          text: null
                        
                        gridLineWidth: 0
                      }]
                   
                    $(".sparkchart", $element).highcharts('SparkLine', {series: series, yAxis: yAxis, chart_click: chart_click})
