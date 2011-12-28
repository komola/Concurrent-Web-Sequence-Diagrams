elementInformation = []

dependencyList = []

array_flip = (object) ->
    obj = {}

    for a, b of object
        obj[b] = a
    
    return obj

parseUserInput = (lines, structureElements) ->
    structureMap = array_flip(structureElements)

    taskMap = {}
    #// 1 => To the right,
    #// -1 => To the left
    direction = 1
    row = 0
    lastKey = -1
    for currentLine in lines
        [structure, task] = currentLine.split(":")
        
        task = task.trim()

        console.log task

        if not structureMap[structure]?
            throw "Unknown structure structure!"

        key = structureMap[structure]

        if key > lastKey && direction == -1 || key < lastKey && direction == 1
            direction *= -1
            row++
        

        if key == lastKey
            direction *= -1
            row++

        if not taskMap[row]?
         console.log "Creating new entry", row
         taskMap[row] = {}

        console.log key

        taskMap[row][key] = task

        lastKey = key

        dependencyList.push( [row+1, key] )
    

    # Fill empty fields in our map
    for key, value of taskMap
        for i in [0 ... structureElements.length]
            if not taskMap[key][i]?
                taskMap[key][i] = ""

    #for i in [0... taskMap.length]
    #    ksort(taskMap[i])

    window.console.log('task Map', taskMap)
    return taskMap

userLines = [ "User: Test", "Server: Foo"]

sections = ["User", "Server"]

window.console.log(parseUserInput)
parseUserInput(userLines, sections)

###
elementMap = array_merge(array(structureElements), parseUserInput(flowchart, structureElements))

function drawRow(array textArray, border = false)
{
    global pdf, elementInformation
    static row = 0
    static page = 1

    margin = 10

    baseHeight = pdf->getY()
    boxMargin = (count(textArray) + 1) * margin
    width = round((pdf->CurPageSize[1] - boxMargin) / count(textArray))

    if(!border)
    {
        pdf->setFont("Arial", "B", 16)
    }
    else
    {
        pdf->setFont("Arial", "", 12)
    }

    foreach(textArray as value)
    {
        elementInformation['height'][row][] = pdf->MultiCellHeight(width, 10, value, border, "C", false)
    }

    maxHeight = max(elementInformation['height'][row])

    foreach(textArray as key => value)
    {
        posY = baseHeight + (maxHeight - round(elementInformation['height'][row][key] / 2))
        if(posY > pdf->CurPageSize[0])
            page++

        posY %= pdf->CurPageSize[0]
        posX = (width + margin) * key + margin

        pdf->setY(posY)
        pdf->setX(posX)

        elementInformation['width'][row][key] = width
        elementInformation['x'][row][key] = posX
        elementInformation['y'][row][key] = posY
        elementInformation['page'][row][key] = page

        if(value == "") continue

        pdf->MultiCell(width, 10, value, border, "C", border)
    }

    pdf->setY(baseHeight + maxHeight + 10)

    row++
}

function drawFlowChart(array data)
{
    global pdf

    foreach(data as key => value)
    {
        drawRow(value, key > 0)
    }
}

function drawArrows(dependencyList, elementInformation)
{
    global pdf

    foreach(dependencyList as key => current)
    {
        if(!isset(dependencyList[key + 1]))
        {
            break
        }

        next = dependencyList[key + 1]
        isVertical = isHorizontal = false

        startX = elementInformation['x'][current[0]][current[1]]
        startY = elementInformation['y'][current[0]][current[1]]

        endX = elementInformation['x'][next[0]][next[1]]
        endY = elementInformation['y'][next[0]][next[1]]

        // Next row?
        if(next[0] > current[0])
        {
            // Draw vertical!
            isVertical = true

            vStartX = startX + elementInformation['width'][current[0]][current[1]] / 2
            vStartY = startY + elementInformation['height'][current[0]][current[1]]

            vEndY = endY + elementInformation['height'][next[0]][next[1]] / 2
        }

        // Not the same column
        if(next[1] != current[1])
        {
            isHorizontal = true

            hStartX = startX
            hEndX = endX + elementInformation['width'][next[0]][next[1]]

            if(next[1] > current[1])
            {
                hStartX = startX + elementInformation['width'][current[0]][current[1]]
                hEndX = endX
            }

            hStartY = startY + elementInformation['height'][current[0]][current[1]] / 2


            if(isVertical && next[1] < current[1])
            {
                hStartX = startX + elementInformation['width'][current[0]][current[1]] / 2
                hEndX = endX + elementInformation['width'][next[0]][next[1]]
                hStartY = endY + elementInformation['height'][next[0]][next[1]] / 2
            }
            elseif(isVertical && next[1] > current[1])
            {
                hStartX = startX + elementInformation['width'][current[0]][current[1]] / 2
                hEndX = endX
                hStartY = endY + elementInformation['height'][next[0]][next[1]] / 2
            }
        }
        elseif(isVertical)
        {
            vEndY = endY
        }

        if(isVertical)
        {
            pdf->Line(vStartX, vStartY, vStartX, vEndY)
        }

        if(isHorizontal)
        {
            pdf->Line(hStartX, hStartY, hEndX, hStartY)
        }

        // Draw the actual arrows
        arrowWidth = 2
        if(isVertical && !isHorizontal)
        {
            arrowTopX = endX + elementInformation['width'][next[0]][next[1]] / 2
            vEndY -= .2
            pdf->Line(arrowTopX, vEndY, arrowTopX + arrowWidth / 1.5, vEndY - arrowWidth)
            pdf->Line(arrowTopX, vEndY, arrowTopX - arrowWidth / 1.5, vEndY - arrowWidth)
        }

        if(isHorizontal)
        {

            // Direction is to the right.
            if(next[1] < current[1])
            {
                arrowWidth *= -1
                hEndX += .2
            }
            else
            {
                hEndX -= .2
            }


            hEndY = endY + elementInformation['height'][next[0]][next[1]] / 2

            pdf->Line(hEndX, hEndY, hEndX - arrowWidth, hEndY - arrowWidth / 1.5)
            pdf->Line(hEndX, hEndY, hEndX - arrowWidth, hEndY + arrowWidth / 1.5)
        }
    }
}

###

#drawFlowChart(elementMap)

#drawArrows(dependencyList, elementInformation)
###
#
