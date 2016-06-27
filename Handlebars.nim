import parser

when isMainModule:
  discard parseHandlebars("""
<h1>{{test1 "Test {{"}}</h1>
<h2>{{test2 "Test {{}}"}}</h2>{{haha}}""")
