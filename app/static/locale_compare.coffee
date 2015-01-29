# for loc in locale-*.json; do coffee locale_compare.coffee $loc>$loc.keys.txt; done
loc=[]
walk_keys=(o, callback)->
    try
        keys = Object.keys o
    catch e
        #console.log e
        return #non object
    return if keys.length is 0
    for key in keys
        loc.push key
        callback loc.join '.'
        walk_keys o[key], callback
        loc.pop key
en_keys=[]
walk_keys (require './locale-en'), (key)->en_keys.push key
other_locales = ['de','it','ru','zh-CN']
for other in other_locales
    other_key={}
    walk_keys (require './locale-'+other), (key)->other_key[key]=on
    for en_key in en_keys
        unless other_key[en_key]
            console.log other+"\t"+"missing\t",en_key