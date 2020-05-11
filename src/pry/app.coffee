SyncPrompt = require('./sync_prompt')
Output = require('./output/local_output')
commands = require('./commands')
AutoComplete = require('./completion')

class App

  _commands: []

  constructor: (@scope) ->
    @output = new Output()
    @prompt = new SyncPrompt(typeahead: new AutoComplete(@scope))
    @prompt.on('data', @find_command)

  commands: ->
    if @_commands.length is 0
      @_commands.push new command({@output, @scope, @prompt}) for _, command of commands
    @_commands

  find_command: (input, chain) =>
    for command in @commands()
      if match = command.match(input.trim())
        args = String(match[1]).trim().split(' ')
        return command.execute.call command, args, chain
    false

  open: ->
    @prompt.type('whereami')
    @prompt.open()

module.exports = App
