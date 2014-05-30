generateController = require '../../lib/generateController'
chai = require 'chai'
spies = require 'chai-spies'
expectArgs = require './../helpers'
chai.use spies
expect = chai.expect

# Init
@keys = []
for key, func of defaultControllers
    @keys.push key

they = (description, callback) =>
    it description, =>
        callback method for method in @keys

describe 'Core', ->
    it 'should exist', ->
        expect(monsoon).to.be.ok
        expect(monsoon).to.be.an 'object'

    it 'should have an app function', ->
        expect( monsoon.app ).to.be.a 'function'

    it 'should have a controllers function', ->
        expect( monsoon.controllers ).to.be.a 'function'