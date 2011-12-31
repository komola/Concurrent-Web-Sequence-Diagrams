$ = jQuery


DEFALUT_TEXT = "This is an easy way to create nice sequence diagrams\n
in a very collaborative way with your friends and colleagues\n
''\n\n

User -> Browser: Clicks on action\n
Browser -> Server: Send request\n
Server -> Browser: Send response\n
Browser -> User: Render it\n
User -> Browser: Laugh at result\n
User -> Browser: Click"

class Application
    limiter = 30;

    constructor: (textareaid, canvasid) ->
        @rendererManager = new RendererManager(canvasid)
        @textArea = $("#"+textareaid)

        #  load the document id if it exists
        currentDocument = if (location.search[0] == "?") then location.search.substr(1) else null

        # if we have a document, edit it, otherwise show welcome screen
        if not currentDocument
            setActivePane "welcome"
        else
            setActivePane "editing"

            #Set share url into text field
            $("#share-modal .address").val(location.href)
        
            # The collaboration functionality  
            sharejs.open currentDocument, "text", (error, doc) =>
                doc.attach_textarea(document.getElementById(textareaid))
                doc.on "change", @changeCallback

                if @textArea.val() == ""
                  @textArea.val(DEFALUT_TEXT)

                @changeCallback()
                true

            #call for first draw;
            @changeCallback();

        #bind events
        bindEvents();

        return true
    
    bindEvents = () ->
        $(".alert-message a.close").click (e) ->
            $(e.target.offsetParent).slideUp()
            e.preventDefault()
        
        #clip board
        ZeroClipboard.setMoviePath( '/lib/ZeroClipboard.swf' );
        @clip = new ZeroClipboard.Client();
        @clip.setText('test');
        @clip.glue('share-copy', 'share-modal' );
        

    panes = ["editing", "welcome"]
    setActivePane = (activePane) ->
        for pane in panes 
            $('#' + pane).toggle(pane == activePane)

        $('a.share').toggle(activePane == 'editing')

    generateId = ->
      text = ""
      possible = "abcdefghijklmnopqrstuvwxyz0123456789"

      for i in [0...8]
        text += possible.charAt(Math.floor(Math.random() * possible.length))

      text

    redraw: =>
        # get the text
        textdata = @textArea.val();
        # tokenize
        tokens = Tokenizer.tokenize(textdata)
        # parse
        parseddata = Parser.parse(tokens)
        #render
        @rendererManager.renderData(parseddata);

    changeCallback: =>
        window.clearTimeout(@timer)
        @timer = window.setTimeout @redraw, limiter

$(() ->
  new Application "pad", "canvas"
)
