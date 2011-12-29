
COLUMN_WIDTH = 150;

boxwidth = 150;
boxheight = 50;
spacing = 12;

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
#        context.lineTo(tox - arrowNudge * 2, toy);
        mx = tox - fromx / 2
        cx1 = mx - 20;
        cx2 = mx + 20;
        cy1 = toy - 8;
        cy2 = toy + 5;

        context.bezierCurveTo(
            cx1, cy1,
            cx2, cy2,

            tox - arrowNudge * 2, toy);


        context.bezierCurveTo(
            tox - arrowNudge * 0.5, toy,
            tox - arrowNudge * 1, toy,
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
    radius = 2;
  
  oldFill = ctx.fillStyle;
  
  gradient = ctx.createLinearGradient(0, y, 0, y + height);
  gradient.addColorStop(0.0, "#f5f7f7");
  gradient.addColorStop(.77, "#d9e8ec");
  #gradient.addColorStop(1.0, "#f00");

  ctx.fillStyle = gradient;

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
        return;

    textWidth = ctx.measureText(text).width;
    textHeight = 12;

    width = textWidth + spacing;
    height = textHeight + spacing / 2;
    console.log('rect:', width, height);
    if(rightBound) 
        roundRect(ctx,
            x - width - spacing  ,
            y - height / 2 ,
            width ,
            height ,
            1,
            true,
            true)
        
        ctx.fillText(text, 
            x - width - spacing / 2  , 
            y + height / 2 - textHeight / 2 + 1,
            width - 2*spacing )
    else
        roundRect(ctx,
            x + spacing,
            y - height / 2,
            width   ,
            height , 1, true, true
        )
    
        ctx.fillText(text, 
            x + spacing * 1.5, 
            y + height / 2 - textHeight / 2 + 1,
            width - 2*spacing )


class AbstractRenderer 
    acceptsRow: (row) ->
        console.log("Todo: Implement");
        return false;
    render: (row, renderState, context) -> 
        console.log("Todo: Implement");

class LabelRenderer extends AbstractRenderer
    acceptsRow: (row) ->
        if(row.tokens.length == 1 or (row.tokens.length == 2 and row.tokens[0] == ":"))
            return true;
        return false;
    render: (row, renderState, context) ->
        context.save();
        context.font = "16px Arial";
        context.fillText(row.tokens[0], spacing, renderState.verticalPosition + spacing);

        renderState.verticalPosition += 30;
        context.restore();    

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

        context.save();
        context.beginPath();
        context.shadowColor = "rgba(0,0,0, 0.4)";
        drawArrow(fromActor.x,
            renderState.verticalPosition,
            toActor.x,
            renderState.verticalPosition,
            context);

        context.stroke();
        context.restore();

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
        @renderers = [new ActionRenderer(), new LabelRenderer()]
        @canvas = document.getElementById(elementId);
        if @canvas.getContext
            width = @canvas.width;
            height = @canvas.height;
            
            #@context = handCanvas(@canvas.getContext('2d'));
            @context = @canvas.getContext('2d');


            @context.font = "12px arial"
            @context.lineWidth = 1.5;
            @context.lineCap = 'round';
            @context.lineJoin = 'round';

            @context.shadowColor = "rgba(0,0,0, 0)";
            @context.shadowBlur = 2;
            @context.shadowOffsetX = 0.5;
            @context.shadowOffsetY = 0.5;

            @context.strokeStyle = '#666';
            @context.fillStyle = '#333';

            window.ccctx = @context;
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
        console.log('actorArray', renderState.actorArray )
        for actor in renderState.actorArray 
            # Draw the vertical Line Paths
            drawing = false;
            lastElement = null;
            firstElement = null;
            for element, i in actor.activePath
                if element == null
                    my = lastElement - firstElement / 2
                    cy1 = my - 20;
                    cy2 = my + 20;
                    cx1 = actor.x - 8;
                    cx2 = actor.x + 4;

                    @context.bezierCurveTo(
                        cx1, cy1,
                        cx2, cy2,

                        actor.x  , lastElement);


                    #@context.lineTo(actor.x, lastElement);
                    lastElement = null;
                    drawing = false;
                else 
                    if lastElement == null
                        firstElement = element;
                        an = if(i>0) then arrowNudge else 0
                        @context.moveTo(
                            actor.x, element + an );
                    lastElement = element;

                @context.stroke()
                    
        @context.stroke();

window.RendererManager = RendererManager;



