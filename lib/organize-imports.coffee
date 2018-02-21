recast = require 'recast'
babel = require 'babel-core'
scoreOf = require './scoreOf'

module.exports =
  activate: (state) ->
    atom.commands.add 'atom-workspace', 'organize-imports:organize', => @organize()

  organizeImports: (code) ->
    ast = recast.parse code, {
      esprima: babel
    }
    return if not ast.program

    imports = ast.program.body.filter (node) ->
      node.type is 'ImportDeclaration'
    imports.sort (a, b) ->
      sA = scoreOf a
      sB = scoreOf b

      return sB - sA if sA isnt sB
      return a.source.value.localeCompare b.source.value

    ast.program.body = ast.program.body.map (node) ->
      return imports.shift() if node.type is 'ImportDeclaration'
      node

    return recast.print(ast).code

  organize: ->
    editor = atom.workspace.getActivePaneItem()

    contents = editor.getText()
    editor.setText @organizeImports contents

    newContents = editor.getText()
    lines = newContents.split(/\n/)

    # Retrieve last import line
    for line, index in lines
      if (/^import/.test line)
        lastImportLine = index

    # remove all empty lines in the import section and sort them by type of import
    updatedLines = []
    previousFirstCharacterAfterQuote = ''
    for line, index in lines
      updatedLines.push line if index > lastImportLine

      if index <= lastImportLine and line isnt ''
        firstQuoteOccurence = line.indexOf "'"
        firstCharacterAfterQuote = line[firstQuoteOccurence + 1]
        updatedLines.push '' if firstCharacterAfterQuote isnt previousFirstCharacterAfterQuote and ((firstCharacterAfterQuote is '~' or firstCharacterAfterQuote is '.') or (previousFirstCharacterAfterQuote is '~' or previousFirstCharacterAfterQuote is '.'))
        updatedLines.push line
        previousFirstCharacterAfterQuote = firstCharacterAfterQuote;

    # finally write back the data
    updatedContents = updatedLines.join "\n"
    editor.setText updatedContents
    return
