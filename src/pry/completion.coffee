Compiler = require('./compiler')

class AutoComplete
  ACCESSOR  = /\s*([\@\w\.]+)(?:\.(\w*))$/
  THISPROP = /\s*(\@)(\w*)/
  SIMPLEVAR = /\s*(\w*)$/i

  KEYWORDS = [
    'undefined', 'then', 'unless', 'until', 'loop', 'of', 'by', 'when', 'require',
    'true', 'false', 'null', 'this', 'new', 'delete', 'typeof', 'in', 'instanceof',
    'return', 'throw', 'break', 'continue', 'if', 'else', 'switch', 'for', 'while',
    'do', 'try', 'catch', 'finally', 'class', 'extends', 'super',
    'whereami', 'kill!', 'exit', 'wtf', 'play', 'version', 'help' # commands
  ].concat(Object.getOwnPropertyNames(global))

  constructor: (@scope, @file) ->
    @localVars = @file.getLocalVariables()
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
      globalVars = (key for own key of global when KEYWORDS.indexOf(key) is -1)
      [@getCompletions(free, @localVars.concat(KEYWORDS, globalVars)), free]

  getCompletions: (prefix, candidates) ->
    if prefix
      (el for el in candidates when el.indexOf(prefix) is 0)
    else
      candidates

  getPropertyNames: (obj) ->
    props = (name for name, _ of obj)
    if typeof obj is 'string'
      props = Object.getOwnPropertyNames(String.prototype)
    else if obj instanceof Array
      props = Object.getOwnPropertyNames(Array.prototype)
    else if obj is Object or obj is Reflect
      props = Object.getOwnPropertyNames(obj)
    else
      tmpObj = obj
      while true
        break if not tmpObj?
        if typeof tmpObj in ['object', 'function']
          keys = Reflect.ownKeys(tmpObj)
          break if '__proto__' in keys
          for key in keys when key isnt 'constructor' and typeof key isnt 'symbol'
            props.push(key)
        tmpObj = Reflect.getPrototypeOf(tmpObj)
    Array.from(new Set(props))


module.exports = AutoComplete
