path = require 'path'

module.exports =
  config:
    coffeelintExecutablePath:
      type: "string"
      default: path.join __dirname, '..', 'node_modules', 'coffeelint', 'bin'
    coffeelintConfigPath:
      type: "string"
      default: ""

  activate: ->
    console.log 'activate linter-coffeelint'
