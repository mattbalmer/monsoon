{expect} = require 'chai'

x =
    docObj: (doc)->
        docString = JSON.stringify(doc)
        return JSON.parse(docString)

    arrayEqual: (a, b) ->
        a.length is b.length and a.every (elem, i) -> elem is b[i]

    aIncludesB: (a, b)->
        doesInclude = true
        for k, v of b
            continue unless b.hasOwnProperty(k)

            # mongoose _id is strange as hell
            if k == '_id'
                doesInclude = false unless (a[k] or '').toString() == (b[k] or '').toString()
            else
                doesInclude = false unless x.equalValue(a[k], b[k])
        doesInclude

    expectDoc: (doc)->
        doc = x.docObj(doc)
        toEqual: (obj)->
            docEqualObj = x.aIncludesB(doc, obj) && x.aIncludesB(obj, doc)
            x.mismatch('document', doc, obj) unless docEqualObj

    equalValue: (a, b)->
        return false if typeof a != typeof b
        return false if Array.isArray(a) != Array.isArray(b)
        type = if Array.isArray(a) then 'array' else typeof a

        return x.arrayEqual(a, b) if type == 'array'
        return x.aIncludesB(a, b) && x.aIncludesB(b, a) if type == 'object'
        return a == b

    mismatch: (thing, oops, a, b)->
        if arguments.length < 4
            b = a
            a = oops
            oops = 'But got'

        a = if typeof a == 'object' then JSON.stringify(a) else a
        b = if typeof b == 'object' then JSON.stringify(b) else b

        throw new Error("\nExpected #{thing}: #{a}\n#{oops}: #{b}")

module.exports = x