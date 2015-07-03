path = require 'path'

module.exports =
  # Your configuration belongs in your project, not your editor.
  # https://github.com/clutchski/coffeelint/blob/master/doc/user.md
  #
  # If you include coffeelint in your project's dev dependencies it will use
  # that version. This is the same behavior the coffeelint commandline gives
  # you.
  config: {}

  provideLinter: ->
    return require('./plus-linter.coffee')
