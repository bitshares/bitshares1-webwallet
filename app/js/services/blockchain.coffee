servicesModule = angular.module("app.services", [])

servicesModule.factory "Blockchain", ->
    asset_records: {
        XTS:
            symbol: "XTS"
            precision: 0.000001
    }
