class DrawingHelpers
    COLUMN_WIDTH = 150;

    boxwidth = 150;
    boxheight = 50;
    spacing = 12;

    arrowNudge = 20;    

    drawVerticalLine: (fromx, fromy) ->


    drawBox: (text, x, y, ctx) ->
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

    drawArrow: (context, fromx, fromy, tox, toy, arrowNudge) ->
        headlen = 10; #length of head in pixels
        angle = Math.atan2(toy-fromy,tox-fromx);
        
        #move to starting position
        context.moveTo(fromx, fromy);

        #calculate the control points for the bezier of the main arrow
        mx = (tox + fromx) / 2
        cx1 = mx - 20;
        cx2 = mx + 20;
        cy1 = toy - 8;
        cy2 = toy + 5;


        if angle < Math.PI / 2
            angle += Math.PI / 180 * 45;
            # main line, replaced with bezier curve
            #context.lineTo(tox - arrowNudge * 2, toy);
            context.bezierCurveTo(
                cx1, cy1,
                cx2, cy2,
                tox - arrowNudge * 2, toy);
            
            #the nudge part of the line
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
            #context.lineTo(tox, toy);
            context.bezierCurveTo(
                cx1, cy1,
                cx2, cy2,
                tox + arrowNudge * 2, toy);

            #the nudge part of the line
            context.bezierCurveTo(
                tox + arrowNudge * 0.5, toy,
                tox + arrowNudge * 1, toy,
                tox, toy + arrowNudge
            )

            # arrow head
            context.lineTo(tox-headlen*Math.cos(angle-Math.PI/6),toy+ arrowNudge-headlen*Math.sin(angle-Math.PI/6));
            context.moveTo(tox, toy+ arrowNudge);
            context.lineTo(tox-headlen*Math.cos(angle+Math.PI/6),toy+ arrowNudge-headlen*Math.sin(angle+Math.PI/6));

        

    roundRect: (ctx, x, y, width, height, radius, fill, stroke) ->
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
      
          
    drawLabel: (text, x, y, rightBound, ctx) ->
        if text == ""
            return;

        textWidth = ctx.measureText(text).width;
        textHeight = 12;

        width = textWidth + spacing;
        height = textHeight + spacing / 2;
        console.log('rect:', width, height);
        if(rightBound) 
            @roundRect(ctx,
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
            @roundRect(ctx,
                x + spacing,
                y - height / 2,
                width   ,
                height , 1, true, true
            )
        
            ctx.fillText(text, 
                x + spacing * 1.5, 
                y + height / 2 - textHeight / 2 + 1,
                width - 2*spacing )





window.drawingHelpers = new DrawingHelpers();