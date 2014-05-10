path = require 'path'

module.exports =
  configDefaults:
    coffeelintExecutablePath: path.join __dirname, '..', 'node_modules', 'coffeelint', 'bin'

  activate: ->
    console.log 'activate linter-coffelint'
