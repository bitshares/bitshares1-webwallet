angular.module("app").controller "BrainWalletController", ($scope, $rootScope, $rootElement, $modal, $log, $location, $idle, $q, $timeout, $http, RpcService, Wallet, Growl) ->
    
    return unless window.bts
    
    $idle.unwatch()
    $rootScope.splashpage = true
    $scope.has_secure_random = bts.wallet.Wallet.has_secure_random()
    $scope.new_brainkey_info = 'new_brainkey_info0'
    $scope.data = {}
    creating_wallet = off
    LANDING_PAGE = '/accounts'
    
    $scope.stepChange=(step)->
        #console.log 'step change',step
        $scope.entropy_collection = off
        switch step
            when 'open_create'
                $scope.new_brainkey_step = 'entropy_collection'
                $scope.entropy_collection = off
                $scope.entropy = "" # Small visual during collection
                $scope.hide_brainkey = on
                # Clear data here, or there is a bug where
                # the login password is change but the confirm
                # form will still think the passwords match
                $scope.data = {}
            #when 'confirm_password'
            #    false
            when 'entropy_collect'
                $scope.entropy_collection = on
                # have the dictionary ready for new_brainkey
                dictionary()
            when 'new_brainkey'
                $scope.data.brainkey = generateBrainkey()
                rotate_brainkey_help()
            when 'existing_brainkey'
                rotate_brainkey_help()
        
        $scope.step = step
    $scope.stepChange 'open_create'
    
    $scope.reset=->
        $scope.stepChange 'open_create'
    
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
            when 'open_create'
                spending_password = $scope.data.spending_password
                unless $scope.wform.$valid
                    console.log "ERROR, button should have been disabled.  Unable to create a wallet. Please correct the form."
                    return
                
                WalletDb = bts.wallet.WalletDb
                wallet_name = walletName spending_password
                if WalletDb.exists wallet_name
                    Wallet.open(wallet_name).then ->
                        Wallet.wallet_unlock(spending_password).then ->
                            navigate_to LANDING_PAGE
                else
                    $scope.stepChange 'confirm_password'
            
            when 'confirm_password'
                unless $scope.wform.csp.$valid
                    Growl.error "", "Unable to confirm password"
                    return
                $scope.stepChange 'entropy_collect'
            when 'new_brainkey', 'existing_brainkey'
                spending_password = $scope.data.spending_password
                unless $scope.wform.$valid
                    console.log "ERROR, but should have been disabled.  Unable to create a wallet. Please correct the form."
                    return
                
                WalletDb = bts.wallet.WalletDb
                wallet_name = walletName spending_password
                if WalletDb.exists wallet_name
                    console.log "ERROR, wallet already exists '#{wallet_name}'"
                    return
                brainkey = $scope.data.brainkey
                creating_wallet = true
                Wallet.create(
                    wallet_name
                    spending_password
                    brainkey
                ).then ->
                    Wallet.open(wallet_name).then ->
                        Wallet.wallet_unlock(spending_password).then ->
                            navigate_to LANDING_PAGE
                .finally ->
                    creating_wallet = false

    rotate_brainkey_help_promise = null
    rotate_brainkey_help=->
        if rotate_brainkey_help_promise
            $timeout.cancel rotate_brainkey_help_promise
        
        rotate_brainkey_help_promise = $timeout ()->
            $scope.brainKeyHelp 'right'
        ,
            5*1000
        return
    
    $scope.brainKeyHelp=(direction)->
        rotate_brainkey_help()
        info = $scope.new_brainkey_info
        num = parseInt info.match /[0-9]$/
        size = 4
        incr = if direction is 'right' then 1 else (size-1)
        $scope.new_brainkey_info = 'new_brainkey_info' + (num + incr) % size
    
    $scope.$watch ->
        creating_wallet
    , (unlocked)->
        $scope.creating_wallet = 
            if creating_wallet
                'fa fa-refresh fa-spin'
            else
                ''

    $scope.$on "$destroy", ->
        $rootScope.splashpage = false
        $scope.startIdleWatch()
        $scope.reset()
    
    # 3000,23 7555,20
    BRAINKEY_WORD_COUNT=20
    MIN_DICTIONARY_WORD_COUNT=10000
    
    dictionary_hashes=
        '/dictionary_en.txt':"b69691d7c679a21593782c18bd05497103217dde"
    dictionary_url=""
    dictionary_lines=[]
    dictionary=(url = '/dictionary_en.txt')->
        if (
            url is dictionary_url and 
            dictionary_lines.length >= MIN_DICTIONARY_WORD_COUNT
        )
            return
        
        dictionary_url = url
        $http.get(url).success (data)->
            #console.log '... data',data
            dictionary_hash = bts.hash.sha1 data
            unless dictionary_hashes[url] is dictionary_hash.toString 'hex'
                throw new Error "dictionary #{url} sha1 didn't match #{dictionary_hashes[url]} (unknown #{dictionary_hash.toString 'hex'})"
            
            lines = data.split '\n'
            if lines.length < MIN_DICTIONARY_WORD_COUNT
                throw new Error "dictionary #{url} needs at least #{MIN_DICTIONARY_WORD_COUNT} words"
            dictionary_lines = lines
    
    # Shorter pharases may be gained while keeping the same bit strength
    # by changing parameters.  Assumes the full dictionary is sorted by 
    # word length.
    generateBrainkey=(
        word_count = BRAINKEY_WORD_COUNT
        dict_size = MIN_DICTIONARY_WORD_COUNT
    ) ->
        unless private_entropy.length >= 1000
            throw new Error 'Something is wrong, should have lots of entropy'
        unless dictionary_lines.length >= MIN_DICTIONARY_WORD_COUNT
            throw new Error 'Something is wrong, should have a large dictionary'
        
        entropy = private_entropy.join ''
        entropy += bts.secureRandom.randomBuffer(32).toString()
        #console.log '... entropy',entropy
        
        randomBuffer = bts.hash.sha512 entropy # 64 bytes
        #console.log '... randomBuffer',randomBuffer.toString 'hex'
        
        # For a 100,000 word dictionary, 16 words are needed:
        #Math.pow(100*1000,15) = 1e+75
        #Math.pow(256,32)      = 1e+77 standard private key
        #Math.pow(100*1000,16) = 1e+80
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
        if private_entropy.length >= 1000
            $scope.$apply ->
                $scope.entropy_collection = off
                $scope.stepChange 'new_brainkey'
            bts.wallet.Wallet.add_entropy private_entropy.join ''
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
        if public_entropy.length < 40
            if new Date().getTime() % 3 == 0
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
