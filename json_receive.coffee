delimiterStack = []

objArr = []

curObjArr = []

prevChar = ""

inString = false

# just strings
curKey = []
# true, false, null, numbers, or string
curVal = []
isKey = false                   # true -> in key, false -> in value field

process.stdin.on 'data', (chunk) ->
  # TODO: convert to just buffer for efficiency
  str = chunk.toString()
  for c in str
    if inString
      if isKey
        curKey.push c
      else
        curVal.push c
      if c == "\"" and prevChar != "\\"
        # if isKey
        #   curObjArr.push curKey.join("")
        #   curKey = []
        # else
        #   curObjArr.push curVal.join("")
        #   curVal = []
        inString = false
      prevChar = c
    else
      # opening delimiter
      if c == "{" or c == "["
        # valid places for opening
        if prevChar == "" or prevChar == ":"
          delimiterStack.push c
          curObjArr.push c
          prevChar = c
          if c == "{"
            isKey = true
        else
          console.warn "prevChar: #{prevChar}"
          console.warn "c: #{c}"
          console.warn "curObj: #{curObjArr.join("")}"
          throw "input stream not valid json: invalid positioning of '#{c}' at #{curObjArr.join("")}"
      # closing delimiter
      else if c == "]" or c == "}"
        # can match true, false, null, numbers, or string (ends with quotes)
        prevDelim = delimiterStack.pop()
        # if curVal != []
        #   console.warn "\\" + curVal.join("") + "\\"
        #   console.warn isKey
        #   console.warn c
        if not isKey and
           curVal.join("").match(/(true|false|null|[0-9\.]+|"[^"]*")/)
          # invalid type of closing delimiter
          if prevDelim == "[" and c != "]" or
             prevDelim == "{" and c != "}"
            console.warn "c: #{c}"
            console.warn "curObj: #{curObjArr.join("")}"
            throw "input stream not valid json: invalid type of closing '#{c}' at #{curObjArr.join("")}"
          # push literal and closing delimiter to current object
          else
            curObjArr.push curVal.join("")
            curObjArr.push c
            curVal = []
            # delivered a complete object!
            if delimiterStack.length == 0
              console.log JSON.stringify(JSON.parse(curObjArr.join("")))
              curObjArr = []
              prevChar = ""
            else
              prevChar = c
        else
          if prevDelim == "{" and c == "}"
            curObjArr.push c
            # delivered a complete object!
            if delimiterStack.length == 0
              console.log JSON.stringify(JSON.parse(curObjArr.join("")))
              curObjArr = []
              prevChar = ""
            else
              prevChar = c
          else if prevDelim == "[" and c == "]"
            curObjArr.push curKey.join("")
            curObjArr.push c
            curKey = []
            # delivered a complete object!
            if delimiterStack.length == 0
              console.log JSON.stringify(JSON.parse(curObjArr.join("")))
              curObjArr = []
              prevChar = ""
            else
              prevChar = c
          else
            if curVal != []
              console.warn "ASF"
            if prevChar != "}"
              console.warn "ADA"
            console.warn "prevDelim: #{prevDelim}"
            console.warn "prevChar: #{prevChar}"
            console.warn "isKey: #{isKey}"
            console.warn "curVal: #{curVal.join("")}"
            console.warn "c: #{c}"
            console.warn "curObj: #{curObjArr.join("")}"
            throw "input stream not valid json: invalid positioning of '#{c}' at #{curObjArr.join("")}"
      # colon
      else if c == ":"
        if delimiterStack[delimiterStack.length - 1] == "["
          throw "input stream not valid json: ':' within array at #{curObjArr.join("")}"
        else if isKey and
           prevChar == "\""
          isKey = false
          curObjArr.push curKey.join("")
          curKey = []
          curObjArr.push c
          prevChar = c
        else
          console.warn "c: #{c}"
          console.warn "curObj: #{curObjArr.join("")}"
          throw "input stream not valid json: invalid positioning of ':' at #{curObjArr.join("")}"
      # comma
      else if c == ","
        if delimiterStack[delimiterStack.length - 1] == "[" and
           curKey.join("").match(/(true|false|null|[0-9\.]+|"[^"]*")/)
          curObjArr.push curKey.join("")
          curKey = []
          curObjArr.push c
          prevChar = c
        else if not isKey and
           curVal.join("").match(/(true|false|null|[0-9\.]+|"[^"]*")/)
          isKey = true
          curObjArr.push curVal.join("")
          curVal = []
          curObjArr.push c
          prevChar = c
        else if prevChar == "]" or prevChar == "}"
          curObjArr.push c
          curVal = []
          curKey = []
          isKey = true
          prevChar = c
        else
          console.warn "isKey: #{isKey}"
          console.warn "prevChar: #{prevChar}"
          console.warn "curVal: #{curVal.join("")}"
          console.warn "c: #{c}"
          console.warn "curObj: #{curObjArr.join("")}"
          throw "input stream not valid json: invalid positioning of ',' at #{curObjArr.join("")}"
      # quote
      else if c == "\""
        if prevChar == ":"
          inString = true
          curVal.push c
          prevChar = c
        else if prevChar == "," or prevChar == "{" or prevChar == "["
          isKey = true
          inString = true
          curKey.push c
          prevChar = c
        else
          console.warn "c: #{c}"
          console.warn "curObj: #{curObjArr.join("")}"
          throw "input stream not valid json: invalid positioning of '\"' at #{curObjArr.join("")}"
      # true or false literal
      else if c.match(/[truefasnl]/) # true, false, or null
        if not isKey
          curVal.push c
          prevChar = c
        else if delimiterStack[delimiterStack.length - 1] == "["
          curKey.push c
          prevChar = c
        else
          console.warn "c: #{c}"
          console.warn "curObj: #{curObjArr.join("")}"
          throw "input stream not valid json: invalid positioning of 'true/false' at #{curObjArr.join("")}"
      # numeric literal
      else if c.match(/[0-9\.]/)
        if not isKey
          curVal.push c
          prevChar = c
        else if delimiterStack[delimiterStack.length - 1] == "["
          curKey.push c
          prevChar = c
        else
          console.warn "c: #{c}"
          console.warn "curObj: #{curObjArr.join("")}"
          throw "input stream not valid json: invalid positioning of numberic literal at #{curObjArr.join("")}"
      # whitespace
      else if c.match(/\s/)
        # do nothing
      else
        console.warn "c: #{c}"
        console.warn "curObj: #{curObjArr.join("")}"
        throw "input stream not valid json: invalid char: #{c}"
