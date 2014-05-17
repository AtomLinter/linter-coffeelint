{parseString} = require 'xml2js'

{Range} = require 'atom'

linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
findFile = require "#{linterPath}/lib/util"

class LinterCoffeelint extends Linter
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  @syntax: ['source.coffee', 'source.litcoffee']

  # A string, list, tuple or callable that returns a string, list or tuple,
  # containing the command line (with arguments) used to lint.
  cmd: 'coffeelint --checkstyle'

  regexFlags: 's'

  constructor: (editor)->
    super(editor)

    config = findFile(@cwd, ['coffeelint.json'])
    if config
      @cmd += " -f #{config}"

    atom.config.observe 'linter-coffeelint.coffeelintExecutablePath', =>
      @executablePath = atom.config.get 'linter-coffeelint.coffeelintExecutablePath'

    if editor.getGrammar().scopeName is 'source.litcoffee'
      @cmd += ' --literate'

  processMessage: (xml, callback) ->
    parseString xml, (err, messagesUnprocessed) ->
      return err if err
      messages = messagesUnprocessed.checkstyle.file?[0].error.map (message, index) ->
        message: message.$.message.replace(/; context: .*?$/, '')
        line: message.$.line
        level: message.$.severity
        linter: message.$.source
        range: new Range([message.$.line - 1, 1], [message.$.line, -1])
      callback messages

  destroy: ->
    atom.config.unobserve 'linter-coffeelint.coffeelintExecutablePath'

module.exports = LinterCoffeelint
