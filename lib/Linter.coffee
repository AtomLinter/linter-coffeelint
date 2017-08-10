{Task} = require('atom')
{generateRange} = require('atom-linter')

workers = new Set
workerFile = require.resolve('./core.coffee')

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

  destroy: ->
    worker?.terminate() for worker in workers

  lint: (textEditor) ->
    filePath = textEditor.getPath()
    return [] unless filePath

    source = textEditor.getText()

    isLiterate = textEditor.getGrammar().scopeName is 'source.litcoffee'


    transform = ({level, message, rule, lineNumber, context}) ->
      message = "#{message}. #{context}" if context
      message = "#{message}. (#{rule})"

      return {
        severity: if level is 'error' then 'error' else 'warning'
        excerpt: message
        location:
          file: filePath
          position: generateRange(textEditor, lineNumber - 1)
      }

    return new Promise (resolve, reject) ->
      task = Task.once workerFile, filePath, source, isLiterate, (results) ->
        workers.delete(task)
        try
          resolve(results.map(transform))
        catch e
          reject(e)
      workers.add(task)
      task.on 'task:error', (e) -> reject(e)
