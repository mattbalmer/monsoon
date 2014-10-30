module.exports =
    duplicate: (doc)->
        name: 'MongoError'
        code: 11000
        err: "insertDocument :: caused by :: 11000 E11000 duplicate key error index: monsoon-demo.events.$_id_  dup key: { : ObjectId(\'"+doc._id+"\') }"