{Task} = require('atom')

module.exports =
class Linter

  name: 'CoffeeLint'
  grammarScopes: [
    'source.coffee'
    'source.litcoffee'
    'source.coffee.jsx'
    'source.coffee.angular'
  ]
  scope: 'file'
  lintsOnChange: true

  constructor: ->
    @worker = new Task(require.resolve('./core.coffee'))

  destroy: ->
    @worker?.terminate()

  lint: (textEditor) ->
    textBuffer = textEditor.getBuffer()
    filePath = textEditor.getPath()
    if filePath
      source = textEditor.getText()

      isLiterate = textEditor.getGrammar().scopeName is 'source.litcoffee'


      transform = ({level, message, rule, lineNumber, context}) ->
        message = "#{message}. #{context}" if context
        message = "#{message}. (#{rule})";

        # Calculate range to make the error whole line
        # without the indentation at begining of line
        indentLevel = textEditor.indentationForBufferRow(lineNumber - 1)

        startCol = (textEditor.getTabLength() * indentLevel)
        endCol = textBuffer.lineLengthForRow(lineNumber - 1)

        range = [[lineNumber - 1, startCol], [lineNumber - 1, endCol]]

        return {
          severity: if level is 'error' then 'error' else 'warning'
          excerpt: message
          location:
            file: filePath
            position: range
        }

      return new Promise (resolve) =>
        @worker.start(filePath, source, isLiterate, (results) ->
          resolve(results.map(transform))
        )
