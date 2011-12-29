$ = jQuery

class Application
    limiter = 30;

    constructor: (textarea, canvas) ->
        @rendererManager = new RendererManager(canvas)
        @textArea = $("#"+textarea)

        currentDocument = location.search

        $(".secondary-nav a.target").attr("href", "/?"+@generateID())

        if not currentDocument
          $(".btn.large.center.success").attr("href", "/?" + @generateID())
          $("#editing").hide()
        else
          $("#body").hide()
          $(".alert-message a.target").attr("href", "/"+currentDocument)
          $("#share-modal .address").val(location.href)
          $(".alert-message a.close").click (e) ->
            $(e.target.offsetParent).slideUp()
            e.preventDefault()

        if currentDocument[0] == "?"
          currentDocument = currentDocument.substr(1)
        
        console.log currentDocument

        sharejs.open currentDocument, "text", (error, doc) =>
            doc.attach_textarea(document.getElementById(textarea))
            doc.on "change", @changeCallback

            if @textArea.val() == ""
              @textArea.val("This is an easy way to create nice sequence diagrams\n
in a very collaborative way with your friends and colleagues\n
.\n\n

User -> Browser: Clicks on action\n
Browser -> Server: Send request\n
Server -> Browser: Send response\n
Browser -> User: Render it\n
User -> Browser: Laugh at result\n
User -> Browser: Click")

            @changeCallback()
            true
        #call for first draw;
        @changeCallback();

        return true

    generateID: ->
      text = ""
      possible = "abcdefghijklmnopqrstuvwxyz0123456789"

      for i in [0...8]
        text += possible.charAt(Math.floor(Math.random() * possible.length))

      text

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
