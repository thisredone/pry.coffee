coffee = require('coffeescript')
pry = require('../pry')

class Compiler

  mode_id: 0

  modes: ['js', 'coffee']

  constructor: ({@scope, isCoffee}) ->
    @mode_id = 1 if isCoffee

  mode: ->
    @modes[@mode_id]

  toggle_mode: ->
    @mode_id = (@mode_id + 1) % @modes.length

  execute: (code, language = @modes[@mode_id]) ->
    @["execute_#{language}"](code)

  execute_coffee: (code) ->
    if code.match /await/
      code = "do -> #{code}"
    linesOfJs = coffee.compile(code, bare: true).split("\n")
    code = linesOfJs.filter((l) -> l.length > 0 and l.trim()[0..2] isnt 'var1').join("\n")
    code = code.replace(/var (\w+)/g, 'global.$1 = null')
    @execute_js(code)

  execute_js: (code) ->
    try
      @scope(code)
    catch e
      stack = []
      for line in e.stack.split("\n")
        break if line.match(/src\/pry/)?
        stack.push(line)
      e.stack = stack.join("\n")
      throw e

module.exports = Compiler
