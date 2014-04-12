monsoon = require '../index'
chai = require 'chai'
expect = chai.expect

describe 'Core', ->
    it 'should exist', ->
        expect(monsoon).to.be.ok
        expect(monsoon).to.be.an 'object'

    it 'should have an app function', ->
        expect( monsoon.app ).to.be.a 'function'

    it 'should have a controllers function', ->
        expect( monsoon.controllers ).to.be.a 'function'