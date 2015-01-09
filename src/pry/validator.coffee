# Validates js/coffee is acceptable
class Validator

  @strings: /(["'])(?:\\\1|.)*?\1/gm

  @opening = ['[', '(', '{']

  @closing = [']', ')', '}']

  @valid: (code) =>
    stack = []
    for char in code.replace(@strings, '').split('')
      if @opening.indexOf(char) isnt -1
        stack.push char
      else if @closing.indexOf(char) isnt -1
        opening = @opening[@closing.indexOf(char)]
        last = stack[stack.length - 1]
        if opening is last
          stack = stack.slice(0, -1)
        else
          throw new Error("Mismatched #{char}")
    stack.length == 0

module.exports = Validator
