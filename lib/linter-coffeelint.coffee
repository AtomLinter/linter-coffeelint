linterPath = atom.packages.getLoadedPackage('linter').path
Linter = require "#{linterPath}/lib/linter"
path = require('path')
resolve = require('resolve').sync

# I can't just map over parseInt because it needs the 2nd parameter and map
# passes the current index as the 2nd parameter
toInt = (str) -> parseInt(str, 10)

class LinterCoffeelint extends Linter
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  #
  # If you have the react plugin it switches source.coffee to source.coffee.jsx
  # even if you aren't actually using jsx in that file.
  @syntax: ['source.coffee', 'source.litcoffee', 'source.coffee.jsx']

  linterName: 'coffeelint'

  _resolveCoffeeLint: (filePath) ->
    try
      return path.dirname(resolve('coffeelint/package.json', {
        basedir: path.dirname(filePath)
      }))
    return 'coffeelint'

  configImportsModules: (config) ->
    return true for ruleName, rconfig of config when rconfig.module?
    return userConfig?.coffeelint?.transforms?

  canImportModules: (coffeelint) ->
    [major, minor, patch] = coffeelint.VERSION.split('.').map(toInt)

    if major > 1
      return true
    if major is 1 and minor > 9
      return true
    if major is 1 and minor is 9 and patch >= 5
      return true
    false

  isCompatibleWithAtom: (coffeelint) ->
    [major, minor, patch] = coffeelint.VERSION.split('.').map(toInt)

    if major > 1
      return true
    if major is 1 and minor > 9
      return true
    if major is 1 and minor is 9 and patch >= 1
      return true
    false

  lintFile: (filePath, callback) ->
    filename = path.basename filePath
    origPath = path.join @cwd, filename
    showUpgradeError = false

    coffeeLintPath = @_resolveCoffeeLint(origPath)
    coffeelint = require(coffeeLintPath)

    # Versions before 1.9.1 don't work with atom because of an assumption that
    # if window is defined, then it must be running in a browser. Atom breaks
    # this assumption, so CoffeeLint < 1.9.1 will fail to find CoffeeScript.
    # See https://github.com/clutchski/coffeelint/pull/383
    [major, minor, patch] = coffeelint.VERSION.split('.').map(toInt)
    if not @isCompatibleWithAtom(coffeelint)
      coffeeLintPath = 'coffeelint'
      coffeelint = require(coffeeLintPath)
      showUpgradeError = true

    configFinder = require("#{coffeeLintPath}/lib/configfinder")

    isLiterate = @editor.getGrammar().scopeName is 'source.litcoffee'
    source = @editor.getText()

    try
      config = configFinder.getConfig(origPath)
      console.log('using coffeelint', coffeelint.VERSION,
        @configImportsModules(config), @canImportModules(coffeelint) )
      if @configImportsModules(config) and not @canImportModules(coffeelint)
        showUpgradeError = true
      else
        result = coffeelint.lint(source, config, isLiterate)
    catch e
      result = []
      console.log(e.message)
      console.log(e.stack)
      result.push({
        lineNumber: 1
        level: 'error'
        message: "CoffeeLint crashed, see console for error details."
        rule: 'none'
      })

    if showUpgradeError
      result = [{
        lineNumber: 1
        level: 'error'
        message: "http://git.io/local_upgrade upgrade your project's CoffeeLint"
        rule: 'none'
      }]

    callback(result.map(@transform))

  transform: (m) =>
    message = m.message
    if m.context
      message += ". #{m.context}"
    @createMessage {
      line: m.lineNumber,
      # None of the rules currently return a column, but they may in the future.
      col: m.column,
      error: m.level is 'error'
      warning: m.level is 'warn'
      message: "#{message}. (#{m.rule})"
    }

module.exports = LinterCoffeelint
