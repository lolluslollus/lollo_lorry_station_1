local _modConstants = require('lollo_lorry_station/constants')
local helpers = {}

helpers.getFlatTable = function(nestedTable)
    local results = {}
    if type(nestedTable) == 'table' then
        for kx, vx in pairs(nestedTable) do
            if type(vx) == 'table' then
                for ky, vy in pairs(vx) do
                    results[#results+1] = {x = kx, y = ky, value = vy}
                end
            end
        end
    end
    return results
end
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
helpers.getAdjacentValues = function(inValuesNested, x, y)
    local results = {}
    local visitedXYs = {}
    helpers.setValueInNestedTable(visitedXYs, true, x, y)

    addPointThenNeighbours(inValuesNested, results, visitedXYs, x, y + 1)
    addPointThenNeighbours(inValuesNested, results, visitedXYs, x + 1, y)
    addPointThenNeighbours(inValuesNested, results, visitedXYs, x, y - 1)
    addPointThenNeighbours(inValuesNested, results, visitedXYs, x - 1, y)

    return results
end

helpers.getCargoAreaModelIndexesBase0 = function(models)
    local results = {}
    local base0ModelIndex = 0
    for _, v in pairs(models) do
        if type(v.tag) == 'table' and v.tag.cargoArea then
            local x = tostring(v.transf[13] / _modConstants.xTransfFactor)
            local y = tostring(v.transf[14] / _modConstants.yTransfFactor)
            helpers.setValueInNestedTable(results, base0ModelIndex, x, y)
            -- if cargoAreas[x] == nil then cargoAreas[x] = {} end
            -- cargoAreas[x][y] = base0ModelIndex
            -- cargoAreas[#cargoAreas+1] = {
            -- 	x = v.transf[13] / _modConstants.xTransfFactor,
            -- 	y = v.transf[14] / _modConstants.yTransfFactor,
            -- 	z = v.transf[15],
            -- }
        end
        base0ModelIndex = base0ModelIndex + 1
    end
    return results
end

helpers.getLorryBayModelIndexesBase0 = function(models)
    local results = {}
    local base0ModelIndex = 0
    for _, v in pairs(models) do
        if type(v.tag) == 'table' and v.tag.lorryBay then
            -- local x = tostring(v.transf[13] / _modConstants.xTransfFactor)
            -- local y = tostring(v.transf[14] / _modConstants.yTransfFactor)
            -- if lorryBays[x] == nil then lorryBays[x] = {} end
            -- lorryBays[x][y] = base0ModelIndex

            results[#results+1] = {
                    x = v.transf[13] / _modConstants.xTransfFactor,
                    y = v.transf[14] / _modConstants.yTransfFactor,
                    z = v.transf[15],
                    base0ModelIndex = base0ModelIndex
                }
        end
        base0ModelIndex = base0ModelIndex + 1
    end
    return results
end

return helpers