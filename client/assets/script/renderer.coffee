


class Renderer
    canvas = null;
    ctx = null;
    width = 0;
    height = 0;

    draw: (data) ->
        # clear context
        ctx.clearRect(0,0, width, height)
        # todo 
        # draw        
        
    constructor: (elementId) ->
        canvas = document.getElementById(elementId);
        if canvas.getContext
            width = canvas.width;
            height = canvas.height;
            ctx = canvas.getContext('2d');
        else 
            console.log('no canvas, aborting.');
            return;

window.Renderer = Renderer;
