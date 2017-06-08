expect = require('chai').expect
Command = require('../src/pry/command')
Range = require('../src/pry/range')

describe 'Command', ->

  subject = null

  beforeEach (complete) ->
    subject = new Command
      scope: (p) -> p
      output:
        send: -> true
    complete()

  describe '#command', ->

    beforeEach (complete) ->
      subject.constructor.commands =
        one:
          constructor:
            name: 'Blaine'
        two:
          constructor:
            name: 'Sch'
      complete()

    it 'matches case insensitive strings', ->
      expect(subject.command('blaine').constructor.name).to.equal 'Blaine'

  describe '#command_regex', ->

    describe 'given a name of foo and 1-3 arguments', ->

      beforeEach (complete) ->
        subject.name = 'foo'
        subject.args = new Range(0, 3)
        complete()

      it 'matches foo', ->
        expect('foo').to.match subject.command_regex()

      it 'matches foo bar', ->
        expect('foo bar').to.match subject.command_regex()

      it 'matches foo bar baz guz', ->
        expect('foo bar baz guz').to.match subject.command_regex()

      it 'doesnt matches foo bar baz guz gul', ->
        expect('foo bar baz guz gul').to.not.match subject.command_regex()
