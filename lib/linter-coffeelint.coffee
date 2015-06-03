linterPackage = atom.packages.getLoadedPackage('linter')

if linterPackage
  Core = require('./core.coffee')
  Linter = require "#{linterPackage.path}/lib/linter"
  path = require('path')
  resolve = require('resolve').sync


  class LinterCoffeelint extends Linter

    # Since linter-plus is backward compatible `init.coffee` will disable this
    # class if it detects linter-plus
    @enabled: true
    @syntax: Core.scopes

    linterName: 'coffeelint'

    lintFile: (filePath, callback) =>
      if not LinterCoffeelint.enabled
        return callback([])

      filename = path.basename filePath
      origPath = path.join @cwd, filename
      source = @editor.getText()
      scopeName = @editor.getGrammar().scopeName

      callback(Core.lint(filePath, origPath, source, scopeName).map(@transform))

    transform: (m) =>
      message = m.message
      if m.context
        message += ". #{m.context}"

      return @createMessage {
        line: m.lineNumber,
        # None of the rules currently return a column, but they may in the
        # future.
        col: m.column,
        error: m.level is 'error'
        warning: m.level is 'warn'
        message: "#{message}. (#{m.rule})"
      }

  module.exports = LinterCoffeelint
