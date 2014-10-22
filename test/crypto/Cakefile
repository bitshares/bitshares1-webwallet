#:mode=coffeescript:
require 'coffee-script/register'
{exec} = require "child_process"

REPORTER = "min"

task "test", "run tests", ->
    exec "NODE_ENV=test 
        ./node_modules/.bin/mocha
        --compilers coffee:coffee-script
        --require coffee-script/register
    ", (err, output) ->
        throw err if err
        console.log output
###
        --reporter #{REPORTER}
        --require test/test_helper.coffee
        --colors
###


task "browserify", "package for the browser", ->
    exec "
        browserify --transform coffeeify -s bitshares src/index.coffee --debug > bitshares-debug.js
    ", (err, output) ->
        throw err if err
        console.log output
###
    browserify = require('browserify')
    b = browserify(
        standalone: 'bitshares'
        outfile: 'bitshares-debug.js'
    )
    b.transform 'coffeeify'
    b.add './src/index.coffee'
    b.bundle()
###
