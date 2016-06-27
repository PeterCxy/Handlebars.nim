import ast, constants, strutils

type
  ParserError = object of RootObj
    msg: string

proc parseNode(content: string): ASTNode =
  echo content # TODO: Remove me
  if content.startsWith BLOCK_START:
    var list = content.replace(BLOCK_START, "").split(" ")
    result = newASTBlockExpression(list[0], list[1])
  elif content.startsWith BLOCK_END:
    result = newASTBlockEndExpression(content.replace(BLOCK_END, ""))
  else:
    result = newASTBasicExpression(content)

proc parse(source: string, current: var int, startTag: string): ASTTree =
  result = newASTTree()
  var next_start = source.find(EXPR_START, current)
  while next_start != -1:
    result.childs.add newASTRawData(source[current..next_start - 1])
    current = next_start + EXPR_START.len
    var content = ""
    var last: char
    var inQuotes = false
    while true:
      var c = source[current]

      if (not inQuotes) and (last & c == EXPR_END):
        current += 1
        content = content[0..content.len - 2]
        break

      # Escape content inside quotes
      if c == '"':
        inQuotes = not inQuotes

      content &= c
      last = c

      current += 1
    var node = parseNode content

    # Here we come to the start of a block
    # Parse the inner part of that block
    if node of ASTBlockExpression:
      let node = ASTBlockExpression(node)
      node.childs = parse(source, current, node.name)
    # We are now at the end of our own block
    # Goodbye!
    elif node of ASTBlockEndExpression:
      let node = ASTBlockEndExpression(node)
      if node.name == startTag:
        break
      else:
        raise newException(ParserError, "Invalid end of tag " & node.name)
    next_start = source.find(EXPR_START, current)
  result.childs.add newASTRawData(source[current..source.len - 1])

proc parseHandlebars*(source: string): ASTTree =
  var current = 0
  result = parse(source, current, nil)
