local constants = require('lollo_lorry_station.constants')
local logger = require('lollo_lorry_station.logger')
local stringUtils = require('lollo_lorry_station.stringUtils')

local helpers = {
    slotTypes = {
        ['4x4InnerModules'] = 1,
        ['12x4StreetsideModules'] = 2,
        ['12x12InnerModules'] = 3,
        ['4x4LinkModules'] = 4,
    }
}

---@alias slotType integer{1, 2, 3, 4} -- <1 = 4x4 inner modules, 2 = 12x4 streetside modules, 3 = 12x12 inner modules, 4 = 4x4 link modules>
---@alias slotTypeMap table<integer, table<integer, boolean>>
---@alias slotMap table<slotType, slotTypeMap>

local _getIdBase = function(slotId)
    local baseId = 0
    for _, v in pairs(constants.idBasesSortedDesc) do
        if slotId >= v.id then
            baseId = v.id
            break
        end
    end

    return baseId > 0 and baseId or false
end
local _getIsWhatFromModuleTag = function(tag, what)
    if type(tag) ~= 'string' or not(tag:find('__module_')) then return false end
    local slotId = tonumber(tag:gsub('__module_', ''), 10)
    if slotId == nil then return false end
    return _getIdBase(slotId) == what
end
local _getIsAnyCargoArea = function(tag)
    return stringUtils.stringContains(tag, constants.modelWithCargoAreaTag)
end
local _getIsCargoAreaInner4x4 = function(tag)
    return _getIsWhatFromModuleTag(tag, constants.idBases.cargoAreaInner4x4SlotId)
end
local _getIsCargoAreaInner12x12 = function(tag)
    return _getIsWhatFromModuleTag(tag, constants.idBases.cargoAreaInner12x12SlotId)
end
local _getIsCargoAreaStreetside12x4 = function(tag)
    return _getIsWhatFromModuleTag(tag, constants.idBases.cargoAreaStreetside12x4SlotId)
end
local _getIsCargoLink4x4 = function(tag)
    return _getIsWhatFromModuleTag(tag, constants.idBases.cargoLink4x4SlotId)
end
local _getIsLorryBay = function(tag)
    if type(tag) == 'string' and tag:find(constants.lorryBayStreetside12x4ModelTag) then
        return true
    else
        return false
    end
end
-- local _getIsStreetside = function(tag)
--     if type(tag) == 'string' and (
--         _getIsWhatFromModuleTag(tag, _constants.idBases.cargoAreaStreetside12x4SlotId)
--         -- tag:find(_constants.cargoAreaStreetside12x4ModelTag)
--         or tag:find(_constants.lorryBayStreetside12x4ModelTag)
--         or tag:find(_constants.lorryBayStreetsideEntrance12x4ModelTag)
--     ) then
--         return true
--     else
--         return false
--     end
-- end
local _getIsVehicleEdge = function(tag)
    if type(tag) == 'string' and (tag:find(constants.lorryBayVehicleEdgeRightModelTag) or tag:find(constants.lorryBayVehicleEdgeLeftModelTag)) then
        return true
    else
        return false
    end
end

---@param nestedTable slotTypeMap
---@param x integer
---@param y integer
---@return boolean|nil
helpers.getValueFromNestedTable = function(nestedTable, x, y)
    local _xString = tostring(x)
    local _yString = tostring(y)
    if _xString == 'nil' or _yString == 'nil' then return nil end

    if not(nestedTable[_xString]) then return nil end
    return nestedTable[_xString][_yString]
end
---@param nestedTable slotTypeMap
---@param newValue boolean|nil
---@param x integer
---@param y integer
helpers.setValueInNestedTable = function(nestedTable, newValue, x, y)
    local _xString = tostring(x)
    local _yString = tostring(y)
    if _xString == 'nil' or _yString == 'nil' then return end

    if not nestedTable[_xString] then nestedTable[_xString] = {} end
    nestedTable[_xString][_yString] = newValue
end
local function getPoint(inValues, x, y)
    -- print('LOLLO getPoint, x = ', x, ' y = ', y)
    if x > constants.xMax or x < constants.xMin
    or y > constants.yMax or y < constants.yMin
    then return false end
    return helpers.getValueFromNestedTable(inValues, x, y) or false
end
local function addPointThenNeighbours(inValues, outValues, visitedXYs, x, y)
    if x > constants.xMax or x < constants.xMin
    or y > constants.yMax or y < constants.yMin
    then return end

    if (helpers.getValueFromNestedTable(visitedXYs, x, y) or false) then return end

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
        if _getIsCargoAreaInner12x12(model.tag)
        or _getIsCargoAreaInner4x4(model.tag)
        or _getIsCargoAreaStreetside12x4(model.tag)
        or _getIsAnyCargoArea(model.tag)
        then
            results[#results+1] = base0ModelIndex
        end
        base0ModelIndex = base0ModelIndex + 1
    end
    return results
end

helpers.getCargoLinksModelIndexesBase0Simple = function(models)
    local results = {}
    local base0ModelIndex = 0
    for _, model in pairs(models) do
        if _getIsCargoLink4x4(model.tag) then
            results[#results+1] = base0ModelIndex
        end
        base0ModelIndex = base0ModelIndex + 1
    end
    return results
end

helpers.getLorryBayModelIndexesBase0 = function(models)
    local results = {}
    local base0ModelIndex = 0
    for _, model in pairs(models) do
        if _getIsLorryBay(model.tag) then
            -- results[#results+1] = {
            --         x = (model.transf[13]  - _constants.anyStreetsideXShift) / _constants.xTransfFactor,
            --         y = (model.transf[14]  - _constants.anyStreetsideYShift) / _constants.yTransfFactor,
            --         z = model.transf[15],
            --         base0ModelIndex = base0ModelIndex
            --     }
            results[#results+1] = base0ModelIndex
        end
        base0ModelIndex = base0ModelIndex + 1
    end
    return results
end
-- helpers.getStreetsideModelIndexesBase0 = function(models)
--     local results = {}
--     local base0ModelIndex = 0
--     for _, model in pairs(models) do
--         if _getIsStreetside(model.tag) then
--             results[#results+1] = base0ModelIndex
--         end
--         base0ModelIndex = base0ModelIndex + 1
--     end
--     return results
-- end

helpers.getVehicleEdgeModelIndexesBase0 = function(models)
    local results = {}
    local base0ModelIndex = 0
    for _, model in pairs(models) do
        if _getIsVehicleEdge(model.tag) then
            -- results[#results+1] = {
            --         x = (model.transf[13]  - _constants.anyStreetsideXShift) / _constants.xTransfFactor,
            --         y = (model.transf[14]  - _constants.anyStreetsideYShift) / _constants.yTransfFactor,
            --         z = model.transf[15],
            --         base0ModelIndex = base0ModelIndex
            --     }
            results[#results+1] = base0ModelIndex
        end
        base0ModelIndex = base0ModelIndex + 1
    end
    return results
end

helpers.demangleId = function(slotId)
    local baseId = _getIdBase(slotId)
    if not baseId then return false, false, false end

    local y = math.floor((slotId - baseId) / constants.idRoundingFactor)
    local x = math.floor((slotId - baseId - y * constants.idRoundingFactor))

    return x + constants.xMin, y + constants.yMin, baseId
end

helpers.mangleId = function(x, y, baseId)
    return baseId + constants.idRoundingFactor * (y  - constants.yMin) + (x  - constants.xMin)
end

---@param slotType slotType
---@param x integer
---@param y integer
---@param tab slotMap
helpers.setSlotBarred = function(slotType, x, y, tab)
    helpers.setValueInNestedTable(tab[slotType], false, x, y)
    -- logger.print('setSlotBarred ended; slotType, x y tab =') logger.debugPrint(slotType) logger.debugPrint(x) logger.debugPrint(y) logger.debugPrint(tab[slotType])
end
---@param slotType slotType
---@param x integer
---@param y integer
---@param tab slotMap
helpers.trySetSlotOpen = function(slotType, x, y, tab)
    if helpers.getValueFromNestedTable(tab[slotType], x, y) == false then return end
    if x < constants.xMin or x > constants.xMax or y < constants.yMin or y > constants.yMax then return end
    helpers.setValueInNestedTable(tab[slotType], true, x, y)
    -- logger.print('trySetSlotOpen ended; slotType, x y tab =') logger.debugPrint(slotType) logger.debugPrint(x) logger.debugPrint(y) logger.debugPrint(tab[slotType])
end
---@param slotType slotType
---@param x integer
---@param y integer
---@param tab slotMap
---@return boolean
helpers.isSlotOpen = function(slotType, x, y, tab)
    -- logger.print('isSlotOpen firing; slotType, x y tab =') logger.debugPrint(slotType) logger.debugPrint(x) logger.debugPrint(y) logger.debugPrint(tab[slotType])
    return helpers.getValueFromNestedTable(tab[slotType], x, y) == true
end
---@return slotMap
helpers.getEmptySlotMap = function()
    return { -- default slot locations
        {}, -- slots for 4x4 inner modules
        {}, -- slots for 12x4 streetside modules
        {}, -- slots for 12x12 inner modules
        {}, -- slots for 4x4 link modules
    }
end
---@param slotMap slotMap
---@return table<slotTypeMap>
helpers.getFlatSlotMap = function(slotMap)
    local _getFlatTable = function(nestedTable)
        local results = {}
        if type(nestedTable) ~= 'table' then return results end

        for kx, vx in pairs(nestedTable) do
            if type(vx) == 'table' then
                for ky, vy in pairs(vx) do
                    results[#results+1] = {x = kx, y = ky, value = vy}
                end
            end
        end
        return results
    end

    return {
        _getFlatTable(slotMap[1]),
        _getFlatTable(slotMap[2]),
        _getFlatTable(slotMap[3]),
        _getFlatTable(slotMap[4]),
    }
end
---comment
---@param slotId integer
---@param result any
helpers.updateSlotIdsWithModule = function(slotId, result)
    -- sadly, result.slots is not indexed
    for _, slotData in pairs(result.slots) do
        if slotData.id == slotId then
            -- logger.print('slotId found, it is ' .. tostring(slotId))
            -- slotData.lolloBuiltIt = true -- this would work but it is not indexed
            result.moduleIds_ActuallyThere[slotId] = true
            break
        end
    end
end
return helpers