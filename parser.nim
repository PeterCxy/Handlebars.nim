import ast, constants, strutils, tables

type
  ParserError* = object of RootObj
    msg: string

proc parseArgumentList(str: string, cmd: var string): Table[string, string] =
  result = initTable[string, string]()

  var list: seq[string] = @[]
  var inQuotes = false
  var arg = ""
  for i in countup(0, str.len - 1):
    var current = str[i]

    if current == '"':
      inQuotes = not inQuotes
      continue
    elif current == ' ' and not inQuotes:
      if arg != "":
        list.add arg
      arg = ""
      continue

    arg &= current

  if arg != "":
    list.add arg

  cmd = list[0]

  if list.len > 1:
    for i in countup(1, list.len - 1):
      let splitted = list[i].split("=")

      if splitted.len < 2:
        result[""] = splitted[0]
      else:
        result[splitted[0]] = splitted[1]

proc parseNode(content: string): ASTNode =
  echo content # TODO: Remove me
  if content.startsWith COMMENT:
    result = nil
  elif content.startsWith BLOCK_START:
    var list = content.replace(BLOCK_START, "").split(" ")
    result = newASTBlockExpression(list[0], list[1])
  elif content.startsWith BLOCK_END:
    result = newASTBlockEndExpression(content.replace(BLOCK_END, ""))
  elif content.startsWith PARTIAL:
    var cmd = ""
    let list = parseArgumentList(content.replace(PARTIAL, ""), cmd)
    result = newASTPartialExpression(cmd, list)
  elif (content.startsWith NO_ESCAPE_START) and (content.endsWith NO_ESCAPE_END):
    result = newASTNoEscapeExpression(content[1..content.len - 2])
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

      if (not inQuotes) and (last & c == EXPR_END) and (current >= source.len or "" & source[current + 1] != NO_ESCAPE_END):
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
