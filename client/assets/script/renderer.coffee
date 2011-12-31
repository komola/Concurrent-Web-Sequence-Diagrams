
COLUMN_WIDTH = 150;

boxwidth = 150;
boxheight = 50;
spacing = 12;

arrowNudge = 20;


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
        fontSize = 12;
        while(row.tokens[0] == ":")
            fontSize += 2;
            row.tokens.shift()


        context.save();
        context.font = '' + fontSize + "px Arial";
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
        drawingHelpers.drawArrow(
            context,
            fromActor.x,
            renderState.verticalPosition,
            toActor.x,
            renderState.verticalPosition,
            arrowNudge);

        context.stroke();
        context.restore();

        if (row.tokens[3] == ":")
            rightBound = toActor.x < fromActor.x;
            drawingHelpers.drawLabel(row.tokens[4], fromActor.x, renderState.verticalPosition, rightBound, context);

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

        #render a simple grid
        @context.save()
        for act, i in data.actors 
            @context.moveTo(COLUMN_WIDTH * (0.5 + i), 50);
            @context.lineTo(COLUMN_WIDTH * (0.5 + i), @canvas.height);
        @context.lineWidth = 10;
        @context.strokeStyle = "rgba(0,0,0,0.05)";
        @context.stroke();
        @context.restore();

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
            drawingHelpers.drawBox(actor.name, actor.x - COLUMN_WIDTH / 2, 0, @context);

        # draw the vertical lines 
        #@context.beginPath();
        console.log('actorArray', renderState.actorArray )
        for actor, a in renderState.actorArray 
            @context.beginPath();
            # Draw the vertical Line Paths
            drawing = false;
            lastElement = null;
            firstElement = null;
            console.log actor.activePath.join(",") 
            for element, i in actor.activePath
                if element == null and firstElement isnt lastElement
                    console.log actor.name, firstElement, lastElement
                    my = (lastElement + firstElement) / 2;
                    cy1 = cy2 = my;
                    cy1 = my - 20;
                    cy2 = my + 20;
                    cx1 = actor.x - 8;
                    cx2 = actor.x + 4;

                    @context.bezierCurveTo(
                        cx1, cy1,
                        cx2, cy2,
                        actor.x, lastElement);

                    #@context.lineTo(actor.x, lastElement);
                    lastElement = null;
                    drawing = false;
                else 
                    if lastElement == null
                        firstElement = element
                        an = if(a>0 or i > 0) then arrowNudge else 0
                        console.log "Current i", i, actor.name, element + an
                        @context.moveTo actor.x, element + an 
                    lastElement = element

                @context.stroke()
                    
        @context.stroke();

window.RendererManager = RendererManager;



