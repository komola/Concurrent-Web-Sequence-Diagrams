
COLUMN_WIDTH = 150;

boxwidth = 150;
boxheight = 50;
spacing = 10;
drawBox = (text, x, y, ctx) ->
    if text == ""
        return;

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



class AbstractRenderer 
    acceptsRow: (row) ->
        console.log("Todo: Implement");
        return false;
    render: (row, renderState, context) -> 
        console.log("Todo: Implement");
        
class ActionRenderer extends AbstractRenderer
    acceptsRow: (row) ->
        if (row.tokens.length == 3 and row.tokens[1] == "->") or (row.tokens.length == 5 and row.tokens[1] == "->" and row.tokens[3] == ":")
            return true;
        return false;
    render: (row, renderState, context) -> 
        fromActor = renderState.getActor(row.tokens[0]);
        toActor = renderState.getActor(row.tokens[2]);

        context.beginPath();
        context.moveTo(
            fromActor.x,
            renderState.verticalPosition);
        context.lineTo(
            toActor.x,
            renderState.verticalPosition);
        context.stroke();

        renderState.verticalPosition += 50;


class RenderState 
    constructor: () ->
        @actors = {}
        @actorArray = []
        @verticalPosition = spacing
        @rowIndex = 0

    getActor: (name) ->
        if(@actors[name]?) 
            return @actors[name]
        else
            newActor = {
                name: name,
                width: COLUMN_WIDTH,
                x: @actorArray.length * COLUMN_WIDTH
            };
            @actors[name] = newActor;
            @actorArray.push(newActor);
            return newActor;


class RendererManager
    constructor: (elementId) ->
        @renderers = [new ActionRenderer()]
        @canvas = document.getElementById(elementId);
        if @canvas.getContext
            width = @canvas.width;
            height = @canvas.height;
            @context = @canvas.getContext('2d');
        else 
            console.log('no canvas support, aborting.');
            return;


    registerRenderer: (renderer) ->
        @renderers.push(renderer);

    renderData: (data) ->
        renderState = new RenderState();

        for row in data.actions
            for renderer in @renderers
                if renderer.acceptsRow(row)
                    renderer.render(row, renderState, @context)
            renderState.rowIndex += 1;

window.RendererManager = RendererManager;

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


