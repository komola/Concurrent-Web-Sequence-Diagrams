


class Renderer
    canvas = null;
    ctx = null;
    width = 0;
    height = 0;

    draw: (data) ->
        # clear context
        ctx.clearRect(0,0, width, height)
        # todo 
        ctx.lineTo(width, height);
        ctx.stroke();
        
        ### bject
        dependencies: Array[2]
            0: Object
                col: 0
                row: 0
            __proto__: Object
            1: Object
        structures: Array[2]
            0: "User"
            1: " Thomas"
        tasks: Object
            0: Object
        ###
        
        width = 300;
        padding = 10;

        for structure in data.structures
            ctx.strokeText(structure, padding, padding, width - 2*padding )

        ctx.stroke


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
