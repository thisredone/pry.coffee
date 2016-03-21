readline = require 'readline'
fs = require 'fs'
EventEmitter = (require 'events').EventEmitter
deasync = require 'deasync'
chalk = require 'chalk'


class MultilineState
  data: ''

  keypress: (input, chars) ->
    @data += chars
    if @data.match(/(\r|\n)\1$/)
      @data = ''
      input.state('single')
      input.send_data()
    else if chars.match(/(\r|\n)$/)
      input.prompt()

  prompt: (input, prompt) ->
    if @data == ''
      input.cli.setPrompt(prompt.replace(/[^>](?!$)/g, '-'))
    else
      input.cli.setPrompt(prompt.replace(/.(?!$)/g, '.'))
    input.cli._refreshLine()


class SinglelineState
  keypress: (input, chars) ->
    if chars is ''
      input.state('search')
      input.prompt()
    else if chars is '\u0016'
      input.state('multi')
      input.prompt()
    else if chars.match(/(\r|\n)$/)
      input.send_data()

  prompt: (input, prompt) ->
    input.cli.setPrompt(prompt)
    input.cli.prompt()


class ReverseSearch
  init: ->
    @index = -1

  quit: (input) ->
    input.state('single')
    input.prompt()
    input.cli._moveCursor input.cli.line.length
    input.cli._refreshLine()

  keypress: (input, chars) ->
    if chars is ''
      return @quit(input)

    if chars.charCodeAt() is 13
      if @searchResult
        input.cli.history.shift()
        input.cli.history.unshift(@searchResult)
        input.type(@searchResult)
      return @quit(input)

    i = if chars is '' then @index else -1
    history = input.cli.history
    while i < history.length - 1
      if history[++i].indexOf(input.cli.line) > 0
        @index = i
        break
    @searchResult = history[@index]
    input.prompt()

  prompt: (input, prompt) ->
    pre = 'failed-' if @searchResult is null and input.cli.line isnt ''
    input.cli.setPrompt("(#{pre or ''}reverse-i-search)`#{input.cli.line}': #{@searchResult or ''}      # ")
    input.cli._refreshLine()


class SyncPrompt extends EventEmitter
  lines: ''
  count: 0
  done: false
  _state: 'single'

  states:
    multi: new MultilineState
    single: new SinglelineState
    search: new ReverseSearch

  constructor: ({typeahead, @mode}) ->
    @indent = ''
    @cli = readline.createInterface
      input: process.stdin
      output: process.stdout
      completer: typeahead
      terminal: true
      historySize: 500

    try
      hist = fs.readFileSync("#{process.env.HOME}/.pryjs_history").toString()
      @cli.history = hist.split('\n').reverse()
    catch
      null
    lastLine = @cli.history[0]
    @cli.on 'line', (line) =>
      if line and line.length and line isnt lastLine
        fs.appendFile("#{process.env.HOME}/.pryjs_history", "\n" + line)
        lastLine = line
      @line(line)
    
    process.stdin.on('data', @keypress)

  state: (state) =>
    if state
      @_state = state
      @states[state].init?()
    @states[@_state]

  line: (line) =>
    line = line.slice(1) if line.charCodeAt(0) is 22
    @lines += '\n' + line

  keypress: (chars) =>
    @state().keypress(@, chars.toString())

  send_data: =>
    @count++
    next = =>
      @lines = ''
      @prompt()
    res = @onData?(@lines.trim(), {next, stop: @close})
    res?.then?(next) or next()

  prompt: =>
    @state().prompt @, [
      "[#{@count}] "
      if @mode is 'js' then chalk.white('pryjs') else chalk.blue('pryjs')
      if @indent then "* #{@indent}" else '> '
    ].join('')

  open: ->
    @done = false
    @prompt()
    deasync.runLoopOnce() until @done

  # Manually trigger input
  type: (input) =>
    @lines = input
    @send_data()

  close: =>
    @done = true
    process.stdin.removeListener('data', @keypress)
    @cli.close()

module.exports = SyncPrompt
