Compiler = require('./compiler')

class AutoComplete
  ACCESSOR  = /\s*([\@\w\.]+)(?:\.(\w*))$/
  THISPROP = /\s*(\@)(\w*)/
  SIMPLEVAR = /\s*(\w*)$/i

  KEYWORDS = [
    'undefined', 'then', 'unless', 'until', 'loop', 'of', 'by', 'when',
    'true', 'false', 'null', 'this', 'new', 'delete', 'typeof', 'in', 'instanceof',
    'return', 'throw', 'break', 'continue', 'if', 'else', 'switch', 'for', 'while',
    'do', 'try', 'catch', 'finally', 'class', 'extends', 'super'
  ]


  RESERVED = ['switch'
    'case', 'default', 'function', 'var', 'void', 'with'
    'const', 'let', 'enum', 'export', 'import', 'native'
    '__hasProp', '__extends', '__slice', '__bind', '__indexOf'
  ]

  constructor: (@scope, @file) ->
    @compiler = new Compiler({@scope, isCoffee: true})

  autocomplete: (text) =>
    try
      @completeAttribute(text) or @completeVariable(text) or [[], text]
    catch e
      [[], []]

  completeAttribute: (text) ->
    if match = text.match(ACCESSOR) or text.match(THISPROP)
      [all, obj, prefix] = match
      try
        val = @compiler.execute obj
      catch error
        return [[], text]
      completions = @getCompletions prefix, @getPropertyNames val
      [completions, prefix or '']

  completeVariable: (text) ->
    if free = text.match(SIMPLEVAR)?[1]
      [@getCompletions(free, KEYWORDS), free]

  getCompletions: (prefix, candidates) ->
    if prefix
      (el for el in candidates when el.indexOf(prefix) is 0)
    else
      candidates

  getPropertyNames: (obj) ->
    (name for own name of obj)


module.exports = AutoComplete
