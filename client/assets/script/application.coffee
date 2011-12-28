$ = jQuery

class Application
  renderer = null
  elm = null

  constructor: (textarea, canvas) ->
    @renderer = new Renderer(canvas)
    @elm = $("#"+textarea)

    console.log @elm

    sharejs.open "websequence", "text", (error, doc) =>
      doc.attach_textarea(document.getElementById(textarea))
      doc.on "change", @changeCallback
      true

    return true
	
  redraw: =>
    data = parseUserInput(@elm.val())
    console.log data
    @renderer.draw(data);

  changeCallback: =>
    console.log "test"
    window.clearTimeout(@timer)
    @timer = window.setTimeout @redraw, 500

$ ->
  new Application "pad", "canvas"
