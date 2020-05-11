#!/usr/bin/env node
App = require('./pry/app')

class Pry

  constructor: ({@isStandAlone} = {}) ->
    repl = (_) ->
      pry.open (input) => _ = eval(input)
    @it = '(' + repl.toString() + ').call(this)'

  open: (scope) ->
    app = new App(scope, @isStandAlone)
    app.open()


module.exports = new Pry


if require.main is module
  eval (pry = new Pry(isStandAlone: true)).it
