compare = (actual, expected)->
    if actual.length != expected.length
        throw new Error("Expected "+expected.length+" arguments, got "+actual.length)
        return

    for i in [0..actual.length-1]
        if( actual[i] != expected[i] )
            throw new Error("Expected argument '"+expected[i]+"' as argument #"+(i+1)+", instead got '"+actual[i]+"'.")


module.exports = expectArgs = (spy)->
    actualArgs = spy.__spy.calls[0]

    to:
        have:
            been: ()->
                args = Array.prototype.slice.call(arguments)
                compare actualArgs, args