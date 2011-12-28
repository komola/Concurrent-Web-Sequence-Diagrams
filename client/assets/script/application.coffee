$ = jQuery

class Application
    limiter = 30;

    constructor: (textarea, canvas) ->
        @rendererManager = new RendererManager(canvas)
        @textArea = $("#"+textarea)

        sharejs.open "websequence", "text", (error, doc) =>
            doc.attach_textarea(document.getElementById(textarea))
            doc.on "change", @changeCallback
            @changeCallback()
            true

        return true

    redraw: =>
        data = @textArea.val();
        #data = "Thomas: Says Hello \n Dennis: Hits him"
        #parseddata = parseUserInput(data);

        tokens = Tokenizer.tokenize(data)
        parseddata = Parser.parse(tokens)

        #parseddata = {
            #actors: ["Mensch", "Hund", "Katze", "Maus", "Fliege"],
            #actions: [{    
                    #tokens: ["Mensch", "->", "Hund", ":", "Hat"]
                #},
                #{    
                    #tokens: ["Hund", "->","Katze", ":", "Jagd"]
                #},
                #{    
                    #tokens: ["Hund", "->","Katze", ":", "Beisst"]
                #},
                #{    
                    #tokens: ["Katze", "->", "Maus", ":", "Beisst"]
                #},
                #{    
                    #tokens: ["Maus", "->", "Fliege", ":", "Isst"]
                #},
                #{    
                    #tokens: ["Fliege", "->", "Mensch", ":", "Nerft"]
                #},
                #{    
                    #tokens: ["Mensch", "->", "Katze", ":", "Hat"]
                #}]
            #};

        @rendererManager.renderData(parseddata);

    changeCallback: =>
        window.clearTimeout(@timer)
        @timer = window.setTimeout @redraw, limiter

$(() ->
  new Application "pad", "canvas"
)
