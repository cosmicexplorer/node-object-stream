NodeObjectStream = require './node-object-stream'

fs = require 'fs'

fileStream = fs.createReadStream './file'

nos = fileStream.pipe(new NodeObjectStream)

nos.on 'object', (str) ->
  console.log JSON.stringify(str)

nos.on 'end', ->
  console.log "asdf"

# fileStream2 = fs.createReadStream './file'

# fileStream2.pipe(new NodeObjectStream).on 'chunk' ->
#   console.log chunk
