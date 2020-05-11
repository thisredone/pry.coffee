fs = require 'fs'
SyncHighlight = require './sync_highlight'


class File
  constructor: (@name, @line) ->
    lines = @content().split("\n")
    unless @line
      for l, i in lines
        if l.match(/eval +pry\.it/)?
          @line = i + 1
          break

  type: ->
    if @name.match /coffee$/ then 'coffee' else 'js'

  by_lines: (start, end = start) ->
    @content().split('\n').slice(start - 1, end).join('\n')

  content: ->
    @_content ||= fs.readFileSync(@name).toString()

  formatted_content_by_line: (start, end = start, line = @line) ->
    start = (if start < 0 then 0 else start)
    new SyncHighlight(@content(), @type()).code_snippet(start, end, line)

  _getIndentLevel: (line) ->
    line.length - line.trimLeft().length

  getLocalVariables: ->
    lines = @content().split("\n")
    currentIndentLevel = @_getIndentLevel(lines[@line-1]) # eval pry.it
    vars = []
    for i in [@line-2..0] when i > 0
      line = lines[i]
      indentLevel = @_getIndentLevel(line)
      continue if indentLevel > currentIndentLevel or not line.match(/\S/)
      currentIndentLevel = indentLevel
      match = line.match(/^\s*(?:\[|{)((?:\w+|\,|\s)+)(?:\]|})\s*\=|^\s*(\w+)\s*\=/)
      if match?
        [_, multiple, single] = match
        if multiple?
          for localVar in multiple.split(",")
            vars.push(localVar.trim())
        if single?
          vars.push(single.trim())
      else
        match = line.match(/class (\w+)/)
        if match?
          vars.push(match[1])
    vars


module.exports = File
