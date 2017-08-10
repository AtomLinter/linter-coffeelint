# This file is a Task file that will run in a separate process
# https://atom.io/docs/api/v1.19.0/Task

resolve = require 'resolve'
path = require 'path'
semver = require 'semver'


_resolveCoffeeLint = (filePath) ->
  try
    return path.dirname(resolve.sync('coffeelint/package.json', {
      basedir: path.dirname(filePath)
    }))
  catch e
    expected = "Cannot find module 'coffeelint/package.json'"
    if e.message[...expected.length] is expected
      return 'coffeelint'
    throw e

configImportsModules = (config) ->
  return true for ruleName, rconfig of config when rconfig.module?
  return userConfig?.coffeelint?.transforms?

module.exports = (filePath, source, isLiterate) ->
  showUpgradeError = false

  coffeeLintPath = _resolveCoffeeLint(filePath)
  coffeelint = require(coffeeLintPath)

  # Versions before 1.9.1 don't work with Atom because of an assumption that
  # if window is defined, then it must be running in a browser. Atom breaks
  # this assumption, so CoffeeLint < 1.9.1 will fail to find CoffeeScript.
  # See https://github.com/clutchski/coffeelint/pull/383
  if semver.lt(coffeelint.VERSION, '1.9.1')
    coffeeLintPath = 'coffeelint'
    coffeelint = require(coffeeLintPath)
    showUpgradeError = true

  configFinder = require("#{coffeeLintPath}/lib/configfinder")

  result = []
  try
    config = configFinder.getConfig(filePath)
    if configImportsModules(config) and semver.lt(coffeelint.VERSION, '1.9.5')
      showUpgradeError = true
    else
      result = coffeelint.lint(source, config, isLiterate)
  catch e
    console.log(e.message)
    console.log(e.stack)
    result.push({
      lineNumber: 1
      level: 'error'
      message: 'CoffeeLint crashed, see console for error details.'
      rule: 'none'
    })

  if showUpgradeError
    result = [{
      lineNumber: 1
      level: 'error'
      message: "http://git.io/local_upgrade upgrade your project's CoffeeLint"
      rule: 'none'
    }]

  return result
