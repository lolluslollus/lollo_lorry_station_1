local _constants = require('lollo_lorry_station/constants')
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
    -- print('LOLLO getPoint, x = ', x, ' y = ', y)
    if x > _constants.xMax or x < _constants.xMin
    or y > _constants.yMax or y < _constants.yMin
    then return false end
    return helpers.getValueFromNestedTable(inValues, x, y)
end
local function addPointThenNeighbours(inValues, outValues, visitedXYs, x, y)
    if x > _constants.xMax or x < _constants.xMin
    or y > _constants.yMax or y < _constants.yMin
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
    for _, model in pairs(models) do
        if helpers.getCargoAreaSlotId(model.tag) then
            local x = tostring((model.transf[13]) / _constants.xTransfFactor)
            local y = tostring((model.transf[14]) / _constants.yTransfFactor)
            helpers.setValueInNestedTable(results, base0ModelIndex, x, y)
            -- if cargoAreas[x] == nil then cargoAreas[x] = {} end
            -- cargoAreas[x][y] = base0ModelIndex
            -- cargoAreas[#cargoAreas+1] = {
            -- 	x = v.transf[13] / _constants.xTransfFactor,
            -- 	y = v.transf[14] / _constants.yTransfFactor,
            -- 	z = v.transf[15],
            -- }
        elseif helpers.getStreetsideCargoAreaSlotId(model.tag) then
            local x = tostring((model.transf[13]  - _constants.lorryBayXShift) / _constants.xTransfFactor)
            local y = tostring((model.transf[14]  - _constants.lorryBayYShift) / _constants.yTransfFactor)
            helpers.setValueInNestedTable(results, base0ModelIndex, x, y)
        end
        base0ModelIndex = base0ModelIndex + 1
    end
    return results
end

helpers.getLorryBayModelIndexesBase0 = function(models)
    local results = {}
    local base0ModelIndex = 0
    for _, model in pairs(models) do
        if helpers.getLorryBaySlotId(model.tag) then
            -- local x = tostring(v.transf[13] / _constants.xTransfFactor)
            -- local y = tostring(v.transf[14] / _constants.yTransfFactor)
            -- if lorryBays[x] == nil then lorryBays[x] = {} end
            -- lorryBays[x][y] = base0ModelIndex

            results[#results+1] = {
                    x = (model.transf[13]  - _constants.lorryBayXShift) / _constants.xTransfFactor,
                    y = (model.transf[14]  - _constants.lorryBayYShift) / _constants.yTransfFactor,
                    z = model.transf[15],
                    base0ModelIndex = base0ModelIndex
                }
        end
        base0ModelIndex = base0ModelIndex + 1
    end
    return results
end

helpers.getCargoAreaModelTag = function(slotId)
    return 'cargoArea_slotId_' .. slotId
end

helpers.getCargoAreaSlotId = function(tag)
    if tag:find('cargoArea_slotId_') then
        return tag:sub(('cargoArea_slotId_'):len() + 1) or false
    else
        return false
    end
end

helpers.getStreetsideCargoAreaModelTag = function(slotId)
    return 'streetsideCargoArea_slotId_' .. slotId
end

helpers.getStreetsideCargoAreaSlotId = function(tag)
    if tag:find('streetsideCargoArea_slotId_') then
        return tag:sub(('streetsideCargoArea_slotId_'):len() + 1) or false
    else
        return false
    end
end

helpers.getLorryBayModelTag = function(slotId)
    return 'lorryBay_slotId_' .. slotId
end

helpers.getLorryBaySlotId = function(tag)
    if tag:find('lorryBay_slotId_') then
        return tag:sub(('lorryBay_slotId_'):len() + 1) or false
    else
        return false
    end
end

helpers.demangleId = function(slotId)
    local function _getIdBase(slotId)
        local baseId = 0
        for _, v in pairs(_constants.idBasesSortedDesc) do
            if slotId >= v.id then
                baseId = v.id
                break
            end
        end

        return baseId > 0 and baseId or false
    end

    local baseId = _getIdBase(slotId)
    if not baseId then return false, false, false end

    local y = math.floor((slotId - baseId) / _constants.idRoundingFactor)
    local x = math.floor((slotId - baseId - y * _constants.idRoundingFactor))

    return x + _constants.xMin, y + _constants.yMin, baseId
end

helpers.mangleId = function(x, y, baseId)
    return baseId + _constants.idRoundingFactor * (y  - _constants.yMin) + (x  - _constants.xMin)
end

return helpers