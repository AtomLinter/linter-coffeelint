Core = require('./core.coffee')
path = require('path')

module.exports = new class # This only needs to be a class to bind lint()

  grammarScopes: Core.scopes
  scope: "file"
  lintOnFly: true

  # coffeelint: disable=no_unnecessary_fat_arrows
  # The fat arrow here is necessary
  lint: (TextEditor) =>
    TextBuffer = TextEditor.getBuffer()
  # coffeelint: enable=no_unnecessary_fat_arrows
    filePath = TextEditor.getPath()
    if filePath
      origPath = if filePath then path.dirname filePath else ''
      source = TextEditor.getText()

      window.lastTextEditor = TextEditor
      scopeName = TextEditor.getGrammar().scopeName


      transform = ({level, message, rule, lineNumber, context, column}) ->
        message = "#{message}. #{context}" if context
        message = "#{message}. (#{rule})";

        # Calculate range to make the error whole line
        # without the indentation at begining of line
        indentLevel = TextEditor.indentationForBufferRow(lineNumber - 1)

        startCol = (TextEditor.getTabLength() * indentLevel)
        endCol = TextBuffer.lineLengthForRow(lineNumber - 1)

        range = [[lineNumber - 1, startCol], [lineNumber - 1, endCol]]

        return {
          type: if level is 'error' then 'Error' else 'Warning'
          text: message
          filePath: filePath
          range: range
        }

      return Core.lint(filePath, origPath, source, scopeName).map(transform)

