
class Application
	renderer = null;
	
	redraw: () ->
		data = parseUserInput;
        renderer.draw(data);

	constructor: () ->
		renderer = new Renderer('canvas')


$(document).ready(() ->
    app = new Application() ;
    app.redraw();
)
