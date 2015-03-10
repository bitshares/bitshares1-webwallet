angular.module("app").controller "BrainWalletController", ($scope, $rootScope, $rootElement, $modal, $log, $location, $idle, $q, $timeout, $http, RpcService, Wallet, Growl) ->
    
    return unless window.bts
    WalletDb = bts.wallet.WalletDb
    WalletBts = bts.wallet.Wallet
    WalletService = Wallet
    Wallet = null # Use WalletService instead
    
    $idle.unwatch()
    $scope.stopIdleWatch()
    
    $rootScope.splashpage = true
    $scope.has_secure_random = WalletBts.has_secure_random()
    $scope.has_wallet = WalletBts.has_wallet()
    $scope.data = {}
    LANDING_PAGE = 'accounts'
    
    $scope.stepChange=(step)->
        #console.log 'step change',step
        $scope.entropy_collection = off
        switch step
            when 'introduction'
                $scope.entropy = "" # Small visual during collection
                $scope.hide_brainkey = on
                # Clear data here, or there is a bug where
                # the login password is change but the confirm
                # form will still think the passwords match
                $scope.data = {}
            
            when 'create_brainkey'
                $scope.entropy_collection = on
                # have the dictionary ready
                dictionary()
            
            when 'review_brainkey'
                $scope.data.brainkey = WalletBts.normalize_brain_key(
                    $scope.data.brainkey
                )
                
            #when 'open'
            #    $scope.entropy_collection = off
            #    $scope.hide_brainkey = on
        
        $scope.step = step
    $scope.stepChange 'introduction'
    
    $scope.reset=->
        $scope.stepChange 'introduction'
    
    walletName = (spending_password) ->
        pw = spending_password
        # Master key checksum is 2 hashes so there is no
        # point in doing more here...
        pw = bts.hash.sha512 pw
        pw = bts.hash.sha512 pw
        name = pw.toString('hex').substring 0,32
        $scope.wallet_name = name
        
    $scope.submitForm = () ->
        $scope.entropy_collection = off
        #console.log '... $scope.step',JSON.stringify $scope.step
        switch $scope.step
            when 'open'
                spending_password = $scope.data.spending_password
                unless $scope.wform.$valid
                    console.log "ERROR, button should have been disabled.  Unable to create a wallet. Please correct the form."
                    return
                
                wallet_name = walletName spending_password
                if WalletDb.exists wallet_name
                    WalletService.open(wallet_name).then ->
                        WalletService.wallet_unlock(spending_password).then ->
                            navigate_to LANDING_PAGE
                else
                    $scope.wform.sp.$error.wrong_password = yes
                    $timeout ->
                        delete $scope.wform.sp.$error.wrong_password
                    ,
                        2000
            
            when 'recover_brainkey'
                $scope.stepChange 'review_brainkey'
            
            when 'create_wallet'
                # confirm_spending_password used because $scope.data.spending_password was undefined
                spending_password = $scope.data.confirm_spending_password
                wallet_name = walletName spending_password
                if WalletDb.exists wallet_name
                    $scope.wform.csp.$error.password_taken = yes
                    $timeout ->
                        delete $scope.wform.csp.$error.password_taken
                    ,
                        2000
                    #console.log "ERROR, wallet already exists '#{wallet_name}'"
                    return
                
                unless $scope.wform.$valid
                    console.log "ERROR, HTML form invalid, submit should have been disabled."
                    return
                
                brainkey = $scope.data.brainkey
                $scope.creating_wallet = 'fa fa-refresh fa-spin'
                $timeout -> # timeout gives refresh spin time to show
                    WalletService.create(
                        wallet_name
                        spending_password
                        brainkey
                    ).then ->
                        WalletService.open(wallet_name).then ->
                            WalletService.wallet_unlock(spending_password).then ->
                                navigate_to LANDING_PAGE
                    .finally ->
                        $scope.creating_wallet = ''
                ,
                    250

    $scope.$on "$destroy", ->
        $rootScope.splashpage = false
        $scope.startIdleWatch()
        $scope.reset()
    
    BRAINKEY_WORD_COUNT=16
    DICTIONARY_WORD_COUNT=49745
    
    dictionary_hashes=
        '/dictionary_en.txt':"562e4a7a914c6b907d836b4332629b555b14424b"
    dictionary_url=""
    dictionary_lines=[]
    dictionary=(url = '/dictionary_en.txt')->
        if (
            url is dictionary_url and 
            dictionary_lines.length is DICTIONARY_WORD_COUNT
        )
            return
        
        dictionary_url = url
        $http.get(url).success (data)->
            #console.log '... data',data
            dictionary_hash = bts.hash.sha1 data
            unless dictionary_hashes[url] is dictionary_hash.toString 'hex'
                throw new Error "dictionary #{url} sha1 didn't match #{dictionary_hashes[url]} (unknown #{dictionary_hash.toString 'hex'})"
            
            lines = data.split '\n'
            if lines.length isnt DICTIONARY_WORD_COUNT
                throw new Error "dictionary #{url} has #{lines.length} words, but needs needs #{DICTIONARY_WORD_COUNT}"
            dictionary_lines = lines
    
    # Shorter pharases may be gained while keeping the same bit strength
    # by changing parameters.  Assumes the full dictionary is sorted by 
    # word length.
    generateBrainkey=(
        word_count = BRAINKEY_WORD_COUNT
        dict_size = DICTIONARY_WORD_COUNT
    ) ->
        unless private_entropy.length >= 1000
            throw new Error 'Something is wrong, should have lots of entropy'
        if dictionary_lines.length isnt DICTIONARY_WORD_COUNT
            throw new Error "Something is wrong, should have #{DICTIONARY_WORD_COUNT} words instead of #{dictionary_lines.length}"
        
        entropy = private_entropy.join ''
        entropy += bts.secureRandom.randomBuffer(32).toString()
        #console.log '... entropy',entropy
        
        randomBuffer = bts.hash.sha512 entropy # 64 bytes
        #console.log '... randomBuffer',randomBuffer.toString 'hex'
        
        brainkey = for i in [0...(word_count * 2)] by 2
            # randomBuffer has 256 bits / 16 bits per word == 16 words
            num = (randomBuffer[i]<<8) + randomBuffer[i+1]
            # convert into a number between 0 and 1 (inclusive)
            rndMultiplier = num / Math.pow(2,16)
            wordIndex = Math.round dict_size * rndMultiplier
            #console.log '... i,num,rndMultiplier,wordIndex',i,num,rndMultiplier,wordIndex
            dictionary_lines[wordIndex]
        brainkey.join ' '
    
    #(->
    private_entropy = []
    public_entropy = []
    chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    chars_length = chars.length
    on_mouse_event = (event) ->
        #console.log event.type, event
        return unless $scope.entropy_collection
        if private_entropy.length % 10 is 0
            $scope.entropy_collection_progressbar = private_entropy.length
        
        if private_entropy.length >= 1000
            $scope.$apply ->
                $scope.entropy_collection = off
                $scope.entropy_collection_progressbar = 0
                $scope.data.brainkey = generateBrainkey()
                $scope.stepChange 'review_brainkey'
            WalletBts.add_entropy private_entropy.join ''
            private_entropy.length = 0
            return
        
        num = (x, y) ->
            new Date().getTime() + Math.pow(x,5) + Math.pow(y,4) +
            bts.secureRandom.randomUint8Array(1)[0]
        private_entropy.push i = num event.pageX, event.pageY
        private_entropy.push num event.clientX, event.clientY
        private_entropy.push num event.offsetX, event.offsetY
        private_entropy.push num event.screenX, event.screenY
        private_entropy.push event.force if event.force
        if public_entropy.length < 50
            public_entropy.push chars.charAt(i % chars_length)
        else
            public_entropy = public_entropy.slice 1
            public_entropy.push chars.charAt(i % chars_length)
        $scope.$apply ->
            $scope.entropy = public_entropy.join('')
    $rootElement.on 'mousemove', (event) ->
        on_mouse_event event
        #console.log event
        #on_mouse_event event.originalEvent.changedTouches[0] 
    $rootElement.on 'mousetouch', (event) ->
        on_mouse_event(event)
    $rootElement.on 'touchmove', (event) ->
        #console.log event
        on_mouse_event event.originalEvent.changedTouches[0]
    #)()
