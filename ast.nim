import tables

type
  ASTNode* = ref object of RootObj
  ASTTree* = ref object of ASTNode
    childs*: seq[ASTNode]
  ASTRawData* = ref object of ASTNode
    data*: string
  ASTExpression* = ref object of ASTNode
    name*: string
  ASTBasicExpression* = ref object of ASTExpression
  ASTCommandExpression* = ref object of ASTExpression
    args*: Table[string, string]
  ASTEscapeExpression* = ref object of ASTExpression
  ASTPartialExpression* = ref object of ASTExpression
  ASTBlockExpression* = ref object of ASTExpression
    items*: string
    childs*: ASTTree
  ASTBlockEndExpression* = ref object of ASTExpression # Only used in parser

proc newASTTree*(): ASTTree =
  result = ASTTree()
  result.childs = @[]

proc newASTRawData*(data: string): ASTRawData =
  result = ASTRawData()
  result.data = data

proc newASTBasicExpression*(name: string): ASTBasicExpression =
  result = ASTBasicExpression()
  result.name = name

proc newASTBlockExpression*(name: string, items: string): ASTBlockExpression =
  result = ASTBlockExpression()
  result.name = name
  result.items = items

proc newASTBlockEndExpression*(name: string): ASTBlockEndExpression =
  result = ASTBlockEndExpression()
  result.name = name
