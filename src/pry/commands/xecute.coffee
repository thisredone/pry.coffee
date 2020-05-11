Command = require('../command')
Range = require('../range')
Compiler = require('../compiler')
pygmentize = require 'pygmentize-bundled'
deasync = require 'deasync'

class Xecute extends Command

  name: ''

  last_error: null

  args: new Range(1, Infinity)

  constructor: ->
    super
    isCoffee = @find_file().name?.slice(-6) is 'coffee'
    @compiler = new Compiler({@scope, isCoffee})
    @code = ''
    @indent = ''

  execute: (input, chain) ->
    return @switch_mode(chain) if input[0] == 'mode'
    @execute_code input.join(' ')
    chain.next()

  eval_code: (code, language) ->
    @output.send @compiler.execute(@code + @indent + code, language)
    @code = @indent = ''

  colorizeLastLine: (code) ->
    done = false
    pygmentize {lang: @compiler.mode(), format: "terminal"}, code, (_, res) =>
      done = true
      process.stdout.moveCursor(0, -1)
      console.log @prompt.cli._prompt + res.toString().slice(0, -1)
    deasync.runLoopOnce() until done

  execute_code: (code, language = null) ->
    try
      # process.stdout.moveCursor(0, -1)
      # console.log @prompt.cli._prompt + code
      @colorizeLastLine(code)

      if code.trim().slice(-1) is '\\'
        @code += @indent + code.trim().slice(0, -1) + "\n"
        @indent += '  '
      else
        if @indent
          if code
            @code += @indent + code.trim() + "\n"
          else
            process.stdout.moveCursor(0, -1)
            @prompt.count--
            @indent = @indent.slice(0, -2)
            @eval_code(code) unless @indent
        else
          @eval_code(code)

      @prompt.indent = @indent

    catch err
      @prompt.indent = @code = @indent = ''
      @last_error = err
      @output.send err

  switch_mode: (chain) ->
    @compiler.toggle_mode()
    @output.send "Switched mode to '#{@compiler.mode()}'."
    chain.next()

  # Should always fallback to this
  match: (input, chain) ->
    [input, input]

module.exports = Xecute
