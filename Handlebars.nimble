# Package

version       = "0.1.0"
author        = "Peter Cai"
description   = "Handlebars.js implementation in Nim"
license       = "WTFPL"

# Dependencies

requires "nim >= 0.14.0"

task debug, "debug Handlebars.nim":
  --run
  setCommand "c", "Handlebars"
