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
      return resolve('coffeelint', {
        basedir: path.dirname(filePath)
      })
    return 'coffeelint'

  lintFile: (filePath, callback) ->
    coffeeLintPath = @_resolveCoffeeLint(filePath)
    coffeelint = require(coffeeLintPath)

    # Versions before 1.9.1 don't work with atom because of an assumption that
    # if window is defined, then it must be running in a browser. Atom breaks
    # this assumption, so CoffeeLint < 1.9.1 will fail to find CoffeeScript.
    # See https://github.com/clutchski/coffeelint/pull/383
    [major, minor, patch] = coffeelint.VERSION.split('.').map(toInt)
    if (major <= 1 and minor < 9) or (major is 1 and minor is 9 and patch is 0)
      coffeeLintPath = 'coffeelint'
      coffeelint = require(coffeeLintPath)

    configFinder = require("#{coffeeLintPath}/lib/configfinder")

    filename = path.basename filePath
    origPath = path.join @cwd, filename

    isLiterate = @editor.getGrammar().scopeName is 'source.litcoffee'
    source = @editor.getText()

    try
      config = configFinder.getConfig(origPath)
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

    callback(result.map(@transform))

  transform: (m) =>
    @createMessage {
      line: m.lineNumber,
      # None of the rules currently return a column, but they may in the future.
      col: m.column,
      error: m.level is 'error'
      warning: m.level is 'warn'
      message: "#{m.message} (#{m.rule})"
    }

module.exports = LinterCoffeelint
