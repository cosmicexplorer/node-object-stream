util = require 'util'
Transform = require('stream').Transform

module.exports =
class SimpleObjectStream extends Transform

  constructor : ->
    if not @ instanceof SimpleObjectStream
      return new SimpleObjectStream
    else
      Transform.call @, readableObjectMode: true
      @delimiterStack = []
      @curObjArr = []
      @prevChar = ""
      @inString = no
      @curKey = []
      @curVal = []
      @isKey = no

      # buffer for in between chunks
      @buffer = ""

      # emit 'end' on end of input
      cbEnd = =>
        @emit 'end'
      # same for 'error'
      cbError = (err) =>
        @emit 'error'
      @on 'pipe', (src) =>
        src.on 'end', cbEnd
        src.on 'error', cbError
      @on 'unpipe', (src) =>
        src.removeListener 'end', cbEnd
        src.removeListener 'error', cbError

  _flush : (callback) ->
    @pushObjs @buffer           # mutates buffer
    if @buffer.match /[^\s]/g   # if any non-whitespace chars
      @emit 'error', new Error("Unparsable end of stream.")
    callback?()

  # validates JSON while reading from stream
  # i don't like all these if statements, but it seems to be the only way to
  # go. feel free to send a pull request if you prefer an alternate method
  #
  # OPTIMIZATION: construct json object as you go instead of putting into one
  # big string and calling JSON.parse(). I haven't seen any speed problems yet,
  # though.
  _transform : (chunk, encoding, callback) ->
    str = @buffer + chunk.toString()
    @pushObjs str
    callback?()

  pushObjs : (str) ->
    for i in [0..(str.length - 1)] by 1
      c = str.charAt(i)
      if @inString
        if @isKey
          @curKey.push c
        else
          @curVal.push c
        if c == "\"" and @prevChar != "\\"
          @inString = false
        @prevChar = c
      else
        # opening delimiter
        if c == "{" or c == "["
          # valid places for opening
          if @prevChar == "" or @prevChar == ":"
            @delimiterStack.push c
            @curObjArr.push c
            @prevChar = c
            if c == "{"
              @isKey = true
          else
            @emit 'error', new Error("input stream not valid json: invalid positioning of '#{c}' at #{@curObjArr.join("")}")
        # closing delimiter
        else if c == "]" or c == "}"
          # can match true, false, null, numbers, or string (ends with quotes)
          prevDelim = @delimiterStack.pop()
          if not @isKey and
             @curVal.join("").match(/(true|false|null|[0-9\.]+|"[^"]*")/)
            # invalid type of closing delimiter
            if prevDelim == "[" and c != "]" or
               prevDelim == "{" and c != "}"
              @emit 'error', new Error("input stream not valid json: invalid type of closing '#{c}' at #{@curObjArr.join("")}")
            # push literal and closing delimiter to current object
            else
              @curObjArr.push @curVal.join("")
              @curObjArr.push c
              @curVal = []
              # delivered a complete object!
              if @delimiterStack.length == 0
                try
                  finalObj = JSON.parse(@curObjArr.join(""))
                  @emit 'object', finalObj
                  @push JSON.stringify(finalObj)
                  @buffer = str.substr(0, i + 1)
                catch err
                  @emit 'error', err
                @curObjArr = []
                @prevChar = ""
              else
                @prevChar = c
          else
            if prevDelim == "{" and c == "}"
              @curObjArr.push c
              # delivered a complete object!
              if @delimiterStack.length == 0
                try
                  finalObj = JSON.parse(@curObjArr.join(""))
                  @emit 'object', finalObj
                  @push JSON.stringify(finalObj)
                catch err
                  @emit 'error', err
                @curObjArr = []
                @prevChar = ""
              else
                @prevChar = c
            else if prevDelim == "[" and c == "]"
              @curObjArr.push @curKey.join("")
              @curObjArr.push c
              @curKey = []
              # delivered a complete object!
              if @delimiterStack.length == 0
                try
                  finalObj = JSON.parse(@curObjArr.join(""))
                  @emit 'object', finalObj
                  @push JSON.stringify(finalObj)
                catch err
                  @emit 'error', err
                @curObjArr = []
                @prevChar = ""
              else
                @prevChar = c
            else
              @emit 'error', new Error("input stream not valid json: invalid positioning of '#{c}' at #{@curObjArr.join("")}")
        # colon
        else if c == ":"
          if @delimiterStack[@delimiterStack.length - 1] == "["
            @emit 'error', new Error("input stream not valid json: ':' within array at #{@curObjArr.join("")}")
          else if @isKey and
                  @prevChar == "\""
            @isKey = false
            @curObjArr.push @curKey.join("")
            @curKey = []
            @curObjArr.push c
            @prevChar = c
          else
            @emit 'error', new Error("input stream not valid json: invalid positioning of ':' at #{@curObjArr.join("")}")
        # comma
        else if c == ","
          if @delimiterStack[@delimiterStack.length - 1] == "[" and
             @curKey.join("").match(/(true|false|null|[0-9\.]+|"[^"]*")/)
            @curObjArr.push @curKey.join("")
            @curKey = []
            @curObjArr.push c
            @prevChar = c
          else if not @isKey and
                  @curVal.join("").match(/(true|false|null|[0-9\.]+|"[^"]*")/)
            @isKey = true
            @curObjArr.push @curVal.join("")
            @curVal = []
            @curObjArr.push c
            @prevChar = c
          else if @prevChar == "]" or @prevChar == "}"
            @curObjArr.push c
            @curVal = []
            @curKey = []
            @isKey = true
            @prevChar = c
          else
            @emit 'error', new Error("input stream not valid json: invalid positioning of ',' at #{@curObjArr.join("")}")
        # quote
        else if c == "\""
          if @prevChar == ":"
            @inString = true
            @curVal.push c
            @prevChar = c
          else if @prevChar == "," or @prevChar == "{" or @prevChar == "["
            @isKey = true
            @inString = true
            @curKey.push c
            @prevChar = c
          else
            @emit 'error', new Error("input stream not valid json: invalid positioning of '\"' at #{@curObjArr.join("")}")
        # true or false literal
        else if c.match(/[truefasnl]/) # true, false, or null
          if not @isKey
            @curVal.push c
            @prevChar = c
          else if @delimiterStack[@delimiterStack.length - 1] == "["
            @curKey.push c
            @prevChar = c
          else
            @emit 'error', new Error("input stream not valid json: invalid positioning of 'true/false' at #{@curObjArr.join("")}")
        # numeric literal
        else if c.match(/[0-9\.]/)
          if not @isKey
            @curVal.push c
            @prevChar = c
          else if @delimiterStack[@delimiterStack.length - 1] == "["
            @curKey.push c
            @prevChar = c
          else
            @emit 'error', new Error("input stream not valid json: invalid positioning of numberic literal at #{@curObjArr.join("")}")
        # whitespace
        else if c.match(/\s/)
          # do nothing
        else
          @emit 'error', new Error("input stream not valid json: invalid char: #{c}")
