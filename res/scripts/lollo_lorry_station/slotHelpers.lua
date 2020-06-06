local _modConstants = require('lollo_lorry_station/constants')
local helpers = {}

helpers.getValueFromNestedTable = function(nestedTable, x, y)
    return nestedTable[tostring(x)] and (nestedTable[tostring(x)][tostring(y)] or false) or false
end
helpers.setValueInNestedTable = function(nestedTable, newValue, x, y)
    if not nestedTable[tostring(x)] then nestedTable[tostring(x)] = {} end
    nestedTable[tostring(x)][tostring(y)] = newValue
end
local function getPoint(inValues, x, y)
    print('LOLLO getPoint, x = ', x, ' y = ', y)
    if x > _modConstants.xMax or x < _modConstants.xMin
    or y > _modConstants.yMax or y < _modConstants.yMin
    then return false end
    return helpers.getValueFromNestedTable(inValues, x, y)
end
local function addPointThenNeighbours(inValues, outValues, visitedXYs, x, y)
    if x > _modConstants.xMax or x < _modConstants.xMin
    or y > _modConstants.yMax or y < _modConstants.yMin
    then return end

    if helpers.getValueFromNestedTable(visitedXYs, x, y) then return end

    helpers.setValueInNestedTable(visitedXYs, true, x, y)

    local valueAtXY = getPoint(inValues, x, y)
    if not valueAtXY then return end

    outValues[#outValues+1] = valueAtXY

    addPointThenNeighbours(inValues, outValues, visitedXYs, x, y + 1)
    addPointThenNeighbours(inValues, outValues, visitedXYs, x + 1, y)
    addPointThenNeighbours(inValues, outValues, visitedXYs, x, y - 1)
    addPointThenNeighbours(inValues, outValues, visitedXYs, x - 1, y)
end
helpers.getAdjacentValues = function(inValues, x, y)
    local results = {}
    local visitedXYs = {}
    helpers.setValueInNestedTable(visitedXYs, true, x, y)

    addPointThenNeighbours(inValues, results, visitedXYs, x, y + 1)
    addPointThenNeighbours(inValues, results, visitedXYs, x + 1, y)
    addPointThenNeighbours(inValues, results, visitedXYs, x, y - 1)
    addPointThenNeighbours(inValues, results, visitedXYs, x - 1, y)

    return results
end

return helpers