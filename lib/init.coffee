path = require 'path'

module.exports =
  configDefaults:
    coffeelintExecutablePath: path.join __dirname, '..', 'node_modules', '.bin'
