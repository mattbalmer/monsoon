{equalValue, aIncludesB, mismatch} = require('./common')
db = require('./db')

last = (fn)->
    (err, res)->
        throw err if err
        fn(res)

status = (code)->
    (res)->
        return "\nExpected status code: #{code}\nBut got: #{res.status}" unless res.status == code

body = (_body)->
    (res)->
        return "\nExpected body: #{JSON.stringify(_body)}\nBut got: #{JSON.stringify(res.body)}" unless aIncludesB(_body, res.body) && aIncludesB(res.body, _body)

body.includes = (_body)->
    (res)->
        return "\nExpected body: #{JSON.stringify(_body)}\nTo include: #{JSON.stringify(res.body)}" unless aIncludesB(res.body, _body)

expectDocument = (_id)->
    toEqual: (_obj)->
        end: (_done)->
            db.Event.findById(_id).lean().exec (err, _doc)->
                mismatch('document', _doc, _obj) unless equalValue(_doc, _obj)
                _done()

    toInclude: (_obj)->
        end: (_done)->
            db.Event.findById _id, (err, _doc)->
                mismatch('document', 'To include', _doc, _obj) unless aIncludesB(_doc, _obj)
                _done()

module.exports =
    last: last
    status: status
    body: body
    expectDocument: expectDocument