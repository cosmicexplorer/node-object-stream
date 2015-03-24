NodeObjectStream = require './node-object-stream'

fs = require 'fs'

# fileStream = fs.createReadStream './file'

# nos = fileStream.pipe(new NodeObjectStream)

# nos.on 'object', (obj) ->
#   console.log JSON.stringify(obj)

# nos.on 'end', ->
#   console.log "asdf"

fileStream2 = fs.createReadStream './file'

nos2 = fileStream2.pipe(new NodeObjectStream)

# nos2.on 'data', (chunk) ->
#   console.log chunk.toString()

nos2.on 'readable', ->
  console.log nos2.read().toString()
