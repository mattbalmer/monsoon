{expect} = require 'chai'

x =
    docObj: (doc)->
        docString = JSON.stringify(doc)
        return JSON.parse(docString)

    includes: (a, b)->
        doesInclude = true
        for k, v of a
            continue unless a.hasOwnProperty(k)
            doesInclude = false if b[k] != a[k]
        doesInclude

    expectDoc: (doc)->
        doc = x.docObj(doc)
        toEqual: (obj)->
            expect( x.includes(doc, obj) ).to.equal true
            expect( x.includes(obj, doc) ).to.equal true

module.exports = x