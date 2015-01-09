Command = require('../command')
Range = require('../range')
Compiler = require('../compiler')
Validator = require('../validator')
SyncPrompt = require('../sync_prompt')

class Execute extends Command

  name: ''

  last_error: null

  args: new Range(1, Infinity)

  constructor: ->
    super
    @compiler = new Compiler({@scope})

  execute: (input...) ->
    return @switch_mode() if input[0] == 'mode'
    @executeCode input.join(' ')
    true

  executeCode: (code, language = null) ->
    try
      @output.send @compiler.execute(@cleanse(code), language)
    catch err
      @last_error = err

  cleanse: (code) ->
    try
      return code if Validator.valid(code)
      @prompt = new SyncPrompt
        callback: (input) ->
          code += '\n' + input
          !Validator.valid(code)
        format: '... '
      @prompt.open()
      code
    catch err
      return '\n'

  switch_mode: ->
    @compiler.toggle_mode()
    @output.send "Switched mode to '#{@compiler.mode()}'."
    true

  # Should always fallback to this
  command_regex: ->
    /(.*)/

module.exports = Execute
