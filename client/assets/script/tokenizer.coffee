class Tokenizer

  constructor: ->
    @operators = [ "->", ":", "\n" ]

  tokenize: (text) ->
    buffer = ""
    tokens = []
    quotationMode = null
    commandMode = false

    for index, a of text.split("")
      commandMode = false


      # Begin quoation mode
      if not quotationMode and (a is "'" or a is '"') and buffer is ""
        quotationMode = a

      # Add content of quotation
      else if quotationMode and quotationMode != a
        buffer += a;

      # End of quotation reached
      else if quotationMode and quotationMode == a
        quotationMode = null
        tokens.push buffer.trim()
        buffer = ""
        # end of quotation mode
        
      else
        buffer += a

        commandMode = false
        for operator in @operators
          if buffer.indexOf(operator) > -1
            beginningText = buffer.substring(0, buffer.length - operator.length).trim()
            if beginningText.length > 0
              tokens.push beginningText

            # Check if the last token is an operator
            if tokens[tokens.length - 1] == "->" or tokens[tokens.length - 1] == ":"
              commandMode = true

            if commandMode
              buffer = ""
              continue

            tokens.push operator
            buffer = ""

    tokens.push buffer.trim()
    tokens

module?.exports = new Tokenizer
window?.Tokenizer = new Tokenizer
