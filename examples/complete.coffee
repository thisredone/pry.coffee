pry = require('../src/pry')


class Complete

  constructor: ->
    localVariable = 'asdf'
    @prettyLongVariableName = 'sup'
    @thisVarIsnt = localVariable
    @anObjectWithProperties =
      theFirstOne: 'asdf'
      second: ['an', 'array']

  run: ->
    localVariable = 'hey'
    aSecondOne = 2
    alsoThisOne = asdf: 2, zxcv: 3
    eval pry.it

  functionName: ->
    {
      objectPropery: 'string'
    }


(new Complete).run()