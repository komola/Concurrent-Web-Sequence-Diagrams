
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

drawArrow = (fromx, fromy, tox, toy, context) ->
    headlen = 10; #length of head in pixels
    angle = Math.atan2(toy-fromy,tox-fromx);
    
    context.moveTo(fromx, fromy);
    context.lineTo(tox, toy);
    context.lineTo(tox-headlen*Math.cos(angle-Math.PI/6),toy-headlen*Math.sin(angle-Math.PI/6));
    context.moveTo(tox, toy);
    context.lineTo(tox-headlen*Math.cos(angle+Math.PI/6),toy-headlen*Math.sin(angle+Math.PI/6));



class AbstractRenderer 
    acceptsRow: (row) ->
        console.log("Todo: Implement");
        return false;
    render: (row, renderState, context) -> 
        console.log("Todo: Implement");
        
class ActionRenderer extends AbstractRenderer
    lastFromActor = null;

    acceptsRow: (row) ->
        if (row.tokens.length == 3 and row.tokens[1] == "->") or (row.tokens.length == 5 and row.tokens[1] == "->" and row.tokens[3] == ":")
            return true;
        return false;
    render: (row, renderState, context) -> 
        fromActor = renderState.getActor(row.tokens[0]);

        if(fromActor == lastFromActor)
            fromActor.activePath.pop()
        else
            lastFromActor = fromActor

        fromActor.activePath.push(renderState.verticalPosition);
        fromActor.activePath.push(null);

        toActor = renderState.getActor(row.tokens[2]);
        toActor.activePath.push(renderState.verticalPosition);

        context.beginPath();
        drawArrow(fromActor.x,
            renderState.verticalPosition,
            toActor.x,
            renderState.verticalPosition,
            context);
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
                activePath: [],
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

        # call the individual renderers
        for row in data.actions
            for renderer in @renderers
                if renderer.acceptsRow(row)
                    renderer.render(row, renderState, @context)
            renderState.rowIndex += 1;

        # draw the vertical lines 
        for actor in renderState.actorArray 
            drawing = false;
            lastElement = null;
            console.log('actor: ', actor.name, ' active Path', actor.activePath);
            for element in actor.activePath
                if element == null
                    @context.lineTo(actor.x, lastElement);
                    console.log('  to: ', actor.x, lastElement);
                    lastElement = null;
                    drawing = false;
                else 
                    if lastElement == null
                        console.log('from: ', actor.x, element);
                        @context.moveTo(actor.x, element)
                    lastElement = element;
                    
        @context.stroke();

window.RendererManager = RendererManager;



