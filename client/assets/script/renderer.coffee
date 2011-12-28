
COLUMN_WIDTH = 150;

boxwidth = 150;
boxheight = 50;
spacing = 10;

arrowNudge = 20;

drawBox = (text, x, y, ctx) ->
    if text == ""
        return;

    ctx.strokeRect(
        x + spacing / 2,
        y + spacing / 2,
        boxwidth - spacing ,
        boxheight - spacing ,
    )

    textWidth = ctx.measureText(text).width;
    textHeight = 8;

    ctx.fillText(text, 
        x + boxwidth/ 2 - textWidth / 2, 
        boxheight*(y + 0.5) + textHeight / 2,
        boxwidth - 2*spacing )

drawArrow = (fromx, fromy, tox, toy, context) ->
    headlen = 10; #length of head in pixels
    angle = Math.atan2(toy-fromy,tox-fromx);
    
    if angle < Math.PI / 2
        angle += Math.PI / 180 * 45;
        # main line
        context.moveTo(fromx, fromy);
        #context.lineTo(tox, toy);
        context.bezierCurveTo(
            tox - arrowNudge, toy,
            tox - arrowNudge, toy,
            tox, toy + arrowNudge
        )

        # arrow head
        context.lineTo(tox-headlen*Math.cos(angle-Math.PI/6),toy+ arrowNudge-headlen*Math.sin(angle-Math.PI/6));
        context.moveTo(tox, toy+ arrowNudge);
        context.lineTo(tox-headlen*Math.cos(angle+Math.PI/6),toy+ arrowNudge-headlen*Math.sin(angle+Math.PI/6));
    else 
        angle -= Math.PI / 180 * 45;
        # main line
        context.moveTo(fromx, fromy);
        #context.lineTo(tox, toy);
        context.bezierCurveTo(
            tox + arrowNudge, toy,
            tox + arrowNudge, toy,
            tox, toy + arrowNudge
        )

        # arrow head
        context.lineTo(tox-headlen*Math.cos(angle-Math.PI/6),toy+ arrowNudge-headlen*Math.sin(angle-Math.PI/6));
        context.moveTo(tox, toy+ arrowNudge);
        context.lineTo(tox-headlen*Math.cos(angle+Math.PI/6),toy+ arrowNudge-headlen*Math.sin(angle+Math.PI/6));
    

roundRect = (ctx, x, y, width, height, radius, fill, stroke) ->
  if (not stroke? ) 
    stroke = true;
  
  if (not radius?) 
    radius = 5;
  
  oldFill = ctx.fillStyle;
  ctx.fillStyle = "white";

  ctx.beginPath();
  ctx.moveTo(x + radius, y);
  ctx.lineTo(x + width - radius, y);
  ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
  ctx.lineTo(x + width, y + height - radius);
  ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
  ctx.lineTo(x + radius, y + height);
  ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
  ctx.lineTo(x, y + radius);
  ctx.quadraticCurveTo(x, y, x + radius, y);
  ctx.closePath();
  if stroke
      ctx.stroke();
  if (fill) 
    ctx.fill();
  ctx.fillStyle = oldFill;
  
      
drawLabel = (text, x, y, rightBound, ctx) ->
    if text == ""
        debugger;
        return;

    textWidth = ctx.measureText(text).width;
    textHeight = 8;

    width = textWidth + spacing;
    height = textHeight + spacing / 2;
    console.log('rect:', width, height);
    if(rightBound) 
        roundRect(ctx,
            x - width   ,
            y - height / 2 ,
            width ,
            height ,
            5,
            true,
            true
        )
        

        ctx.fillText(text, 
            x - width + spacing / 2  , 
            y + height / 2 - textHeight / 2,
            width - 2*spacing )
    else
        roundRect(ctx,
            x + spacing / 2,
            y - height / 2,
            width   ,
            height , 5, true, true
        )
    
        ctx.fillText(text, 
            x + spacing , 
            y + height / 2 - textHeight / 2,
            width - 2*spacing )


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

        if (row.tokens[3] == ":")
            rightBound = toActor.x < fromActor.x;
            drawLabel(row.tokens[4], fromActor.x, renderState.verticalPosition, rightBound, context);

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
                x: @actorArray.length * COLUMN_WIDTH + COLUMN_WIDTH / 2
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
        #clear rect
        @context.clearRect(0,0, @canvas.width, @canvas.height);

        renderState = new RenderState();

        renderState.verticalPosition = boxheight + 2 * spacing ; # leave space for header

        # call the individual renderers
        for row in data.actions
            for renderer in @renderers
                if renderer.acceptsRow(row)
                    renderer.render(row, renderState, @context)
            renderState.rowIndex += 1;

        # draw the header boxes
        for actor in renderState.actorArray 
            # Draw the labels
            drawBox(actor.name, actor.x - COLUMN_WIDTH / 2, 0, @context);

        # draw the vertical lines 
        @context.beginPath();
        for actor in renderState.actorArray 
            # Draw the vertical Line Paths
            drawing = false;
            lastElement = null;
            for element in actor.activePath
                if element == null
                    @context.lineTo(actor.x, lastElement);
                    lastElement = null;
                    drawing = false;
                else 
                    if lastElement == null
                        @context.moveTo(actor.x, element + arrowNudge)
                    lastElement = element;
                    
        @context.stroke();

window.RendererManager = RendererManager;



