


class Renderer
    canvas = null;
    ctx = null;
    width = 0;
    height = 0;

    boxwidth = 150;
    boxheight = 50;
    spacing = 10;

    drawBox = (text, x, y) ->
        ctx.strokeRect(
            boxwidth*x + spacing / 2,
            boxheight*y + spacing / 2,
            boxwidth - spacing ,
            boxheight - spacing ,
        )

        textWidth = ctx.measureText(text).width;
        textHeight = 8;

        ctx.fillText(text, 
            boxwidth*x + boxwidth/ 2 - textWidth / 2, 
            boxheight*(y + 0.5) + textHeight / 2,
            width - 2*spacing )

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
        
        # draws the header
        for structure, index in data.structures
            drawBox(structure, index, 0);

        # draws the boxes
        for y of data.tasks
            row = data.tasks[y]
            for x of row
                cell = row[x];
                drawBox(cell, parseInt(x),parseInt(y)+1)

        #ctx.stroke


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
