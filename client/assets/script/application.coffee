
class Application
    renderer = null;
    
    redraw: () ->
        data = "Thomas: Says Hello \n Dennis: Hits him"
        parseddata = parseUserInput(data);
        renderer.draw(parseddata);

    constructor: () ->
        renderer = new Renderer('canvas')


$(document).ready(() ->
    app = new Application() ;
    app.redraw();
)
