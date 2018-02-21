scoreOf = (node) ->
  return 7 if node.specifiers.length is 0
  return 6 if node.importKind && node.importKind is 'type'
  return 5 if node.source.value is 'react'
  return 4 if node.source.value is 'react-dom'
  return 3 if node.source.value[0] isnt '~' and node.source.value[0] isnt '.'
  return 2 if node.source.value[0] is '~'
  return 1 if node.source.value[0] is '.'
  return 0

module.exports = scoreOf
