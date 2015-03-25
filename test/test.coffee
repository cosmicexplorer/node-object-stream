SimpleObjectStream = require './simple-object-stream'

fs = require 'fs'

readObject = false

nos = process.stdin.pipe(new SimpleObjectStream)

nos.on 'object', (obj) ->
  if readObject
    throw "test FAILED: parsed incorrect number of objects"
  fs.readFile "#{__dirname}/../test/test_file", (err, data) ->
    throw err if err
    if JSON.stringify(obj) != JSON.stringify(JSON.parse(data.toString()))
      console.warn "obj: "
      console.warn obj
      console.warn "JSON.parse(data.toString()): "
      console.warn JSON.parse(data.toString())
      throw "test FAILED: incorrectly parsed object"
    console.log "object parsing test: passed"
  readObject = true

nos.on 'end', ->
  console.log "object recognition test: passed"
