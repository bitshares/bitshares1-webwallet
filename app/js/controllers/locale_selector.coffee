angular.module("app").controller "LocaleSelectorController", ($scope, $translate) ->

    localStorage = window.localStorage
    
    to_flag = (lang)->
        switch lang
            when 'zh-CN' then 'cn'
            when 'en' then 'us'
            when 'ko' then 'kr'
            else lang
    
    useLang=(lang)->
        return unless lang
        $scope.flag = ''
        $translate.preferredLanguage lang
        moment.locale(lang)
        $translate.use(lang).then ->
            $scope.flag = to_flag lang
    
    if localStorage
        useLang localStorage.getItem 'locale_selector_lang'
    
    $scope.flag = to_flag $translate.preferredLanguage()
    $scope.setFlag = (flag)->
        lang = switch flag
            when 'cn' then 'zh-CN'
            when 'us' then 'en'
            when 'kr' then 'ko'
            else flag
        useLang lang
        if localStorage
            localStorage.setItem 'locale_selector_lang', lang
        return
    
    