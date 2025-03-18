local constants = require('lollo_lorry_station.constants')
local logger = require('lollo_lorry_station.logger')
local pitchHelpers = require('lollo_lorry_station.pitchHelper')
local stringUtils = require('lollo_lorry_station.stringUtils')
local transfUtilsUG = require 'transf'
local vec3UG = require 'vec3'

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

-- helpers.getCargoAreaModelIndexesBase0 = function(models)
--     local results = {}
--     local base0ModelIndex = 0
--     for _, model in pairs(models) do
--         if _getIsCargoAreaInner12x12(model.tag) then
--             local x = tostring((model.transf[13]  - _constants.anyInnerXShift) / _constants.xTransfFactor)
--             local y = tostring((model.transf[14]  - _constants.anyInnerYShift) / _constants.yTransfFactor)
--             helpers.setValueInNestedTable(results, base0ModelIndex, x, y)
--         elseif _getIsCargoAreaInner4x4(model.tag) then
--             local x = tostring((model.transf[13]  - _constants.anyInnerXShift) / _constants.xTransfFactor)
--             local y = tostring((model.transf[14]  - _constants.anyInnerYShift) / _constants.yTransfFactor)
--             helpers.setValueInNestedTable(results, base0ModelIndex, x, y)
--         elseif _getIsCargoAreaStreetside12x4(model.tag) then
--             local x = tostring((model.transf[13]  - _constants.anyStreetsideXShift) / _constants.xTransfFactor)
--             local y = tostring((model.transf[14]  - _constants.anyStreetsideYShift) / _constants.yTransfFactor)
--             helpers.setValueInNestedTable(results, base0ModelIndex, x, y)
--         end
--         base0ModelIndex = base0ModelIndex + 1
--     end
--     return results
-- end

helpers.getCargoAreaModelIndexesBase0Simple = function(models)
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
---updates tab in place
---@param params any
---@param moduleIds table<integer>
---@param tab slotMap
helpers.refreshSlotConfig = function(params, moduleIds, tab)
    logger.print('refreshSlotConfig starting')
    local _isStoreCargoOnPavement = (params.isStoreCargoOnPavement == 1)
    for moduleId, _ in pairs(moduleIds) do
    -- for _, moduleId in pairs(moduleIds) do
        -- logger.print('moduleId = ' .. tostring(moduleId))
        local moduleX, moduleY, moduleBaseId = helpers.demangleId(moduleId)
        if moduleX and moduleY and moduleBaseId then
            if moduleBaseId == constants.idBases.cargoAreaInner4x4SlotId then
                -- add slots for more cargoAreaInner4x4SlotId
                helpers.trySetSlotOpen(1, moduleX - 1, moduleY, tab)
                helpers.trySetSlotOpen(1, moduleX + 1, moduleY, tab)
                helpers.trySetSlotOpen(1, moduleX, moduleY - 1, tab)
                helpers.trySetSlotOpen(1, moduleX, moduleY + 1, tab)
                -- add slots for more cargoAreaInner12x12SlotId
                -- left and right
                helpers.trySetSlotOpen(3, moduleX - 2, moduleY - 1, tab)
                helpers.trySetSlotOpen(3, moduleX - 2, moduleY, tab)
                helpers.trySetSlotOpen(3, moduleX - 2, moduleY + 1, tab)
                helpers.trySetSlotOpen(3, moduleX + 2, moduleY - 1, tab)
                helpers.trySetSlotOpen(3, moduleX + 2, moduleY, tab)
                helpers.trySetSlotOpen(3, moduleX + 2, moduleY + 1, tab)
                -- above and below
                helpers.trySetSlotOpen(3, moduleX - 1, moduleY - 2, tab)
                helpers.trySetSlotOpen(3, moduleX, moduleY - 2, tab)
                helpers.trySetSlotOpen(3, moduleX + 1, moduleY - 2, tab)
                helpers.trySetSlotOpen(3, moduleX - 1, moduleY + 2, tab)
                helpers.trySetSlotOpen(3, moduleX, moduleY + 2, tab)
                helpers.trySetSlotOpen(3, moduleX + 1, moduleY + 2, tab)
                -- add slots for more cargoLink4x4SlotId
                helpers.trySetSlotOpen(4, moduleX - 1, moduleY, tab)
                helpers.trySetSlotOpen(4, moduleX + 1, moduleY, tab)
                helpers.trySetSlotOpen(4, moduleX, moduleY - 1, tab)
                helpers.trySetSlotOpen(4, moduleX, moduleY + 1, tab)
                -- bar slots for self on station
                -- for x = -1, 1 do
                --     helpers.setSlotBarred(1, x, 0, tab)
                -- end
                -- bar slots for cargoAreaStreetside12x4SlotId
                for x = -1, 1 do
                    -- if x ~= 0 then
                        helpers.setSlotBarred(2, moduleX + x, moduleY, tab)
                    -- end
                end
                -- bar slots for cargoAreaInner12x12SlotId
                for x = -1, 1 do
                    for y = -1, 1 do
                        -- if x ~= 0 or y ~= 0 then
                            helpers.setSlotBarred(3, moduleX + x, moduleY + y, tab)
                        -- end
                    end
                end
            elseif moduleBaseId == constants.idBases.cargoAreaStreetside12x4SlotId then
                if _isStoreCargoOnPavement then
                    -- add slots for more cargoAreaInner4x4SlotId
                    helpers.trySetSlotOpen(1, moduleX - 2, moduleY, tab)
                    helpers.trySetSlotOpen(1, moduleX - 1, moduleY + 1, tab)
                    helpers.trySetSlotOpen(1, moduleX, moduleY + 1, tab)
                    helpers.trySetSlotOpen(1, moduleX + 1, moduleY + 1, tab)
                    helpers.trySetSlotOpen(1, moduleX + 2, moduleY, tab)
                    -- add slots for more cargoAreaStreetside12x4SlotId
                    helpers.trySetSlotOpen(2, moduleX - 3, moduleY, tab)
                    helpers.trySetSlotOpen(2, moduleX + 3, moduleY, tab)
                    -- add slots for more cargoAreaInner12x12SlotId
                    for x = -2, 2, 1 do
                        helpers.trySetSlotOpen(3, moduleX + x, moduleY + 2, tab)
                    end
                    -- add slots for more cargoLink4x4SlotId
                    helpers.trySetSlotOpen(4, moduleX - 2, moduleY, tab)
                    helpers.trySetSlotOpen(4, moduleX - 1, moduleY - 1, tab)
                    helpers.trySetSlotOpen(4, moduleX - 1, moduleY + 1, tab)
                    helpers.trySetSlotOpen(4, moduleX, moduleY - 1, tab)
                    helpers.trySetSlotOpen(4, moduleX, moduleY + 1, tab)
                    helpers.trySetSlotOpen(4, moduleX + 1, moduleY - 1, tab)
                    helpers.trySetSlotOpen(4, moduleX + 1, moduleY + 1, tab)
                    helpers.trySetSlotOpen(4, moduleX + 2, moduleY, tab)
                    -- bar slots for self on station
                    -- for x = -2, 2 do
                    --     helpers.setSlotBarred(2, x, 0, tab)
                    -- end
                    -- bar slots for cargoAreaInner4x4SlotId
                    for x = -1, 1 do
                        -- if x ~= 0 then
                            helpers.setSlotBarred(1, moduleX + x, moduleY, tab)
                        -- end
                    end
                    -- bar slots for cargoAreaStreetside12x4SlotId
                    for x = -2, 2 do
                        if x ~= 0 then -- do not bar the current module
                            helpers.setSlotBarred(2, moduleX + x, moduleY, tab)
                        end
                    end
                    -- bar slots for cargoAreaInner12x12SlotId
                    for x = -2, 2 do
                        for y = -1, 1 do
                            -- if x ~= 0 or y ~= 0 then
                                helpers.setSlotBarred(3, moduleX + x, moduleY + y, tab)
                            -- end
                        end
                    end
                    -- bar slots for cargoLink4x4SlotId
                    for x = -1, 1 do
                        -- if x ~= 0 then
                            helpers.setSlotBarred(4, moduleX + x, moduleY, tab)
                        -- end
                    end
                else
                    helpers.setSlotBarred(2, moduleX, moduleY, tab) -- bar the current module
                end
            elseif moduleBaseId == constants.idBases.cargoAreaInner12x12SlotId then
                -- logger.print('LOLLO result.slotXYsNested before reading module 12x12 =') logger.debugPrint(result.slotXYsNested)
                -- add slots for more cargoAreaInner4x4SlotId
                -- left and right
                helpers.trySetSlotOpen(1, moduleX - 2, moduleY - 1, tab)
                helpers.trySetSlotOpen(1, moduleX - 2, moduleY, tab)
                helpers.trySetSlotOpen(1, moduleX - 2, moduleY + 1, tab)
                helpers.trySetSlotOpen(1, moduleX + 2, moduleY - 1, tab)
                helpers.trySetSlotOpen(1, moduleX + 2, moduleY, tab)
                helpers.trySetSlotOpen(1, moduleX + 2, moduleY + 1, tab)
                -- above and below
                helpers.trySetSlotOpen(1, moduleX - 1, moduleY + 2, tab)
                helpers.trySetSlotOpen(1, moduleX, moduleY + 2, tab)
                helpers.trySetSlotOpen(1, moduleX + 1, moduleY + 2, tab)
                helpers.trySetSlotOpen(1, moduleX - 1, moduleY - 2, tab)
                helpers.trySetSlotOpen(1, moduleX, moduleY - 2, tab)
                helpers.trySetSlotOpen(1, moduleX + 1, moduleY - 2, tab)
                -- add slots for more cargoAreaInner12x12SlotId
                for xy = -2, 2 do
                    helpers.trySetSlotOpen(3, moduleX - 3, moduleY + xy, tab)
                    helpers.trySetSlotOpen(3, moduleX + 3, moduleY + xy, tab)
                    helpers.trySetSlotOpen(3, moduleX + xy, moduleY - 3, tab)
                    helpers.trySetSlotOpen(3, moduleX + xy, moduleY + 3, tab)
                end
                -- add slots for more cargoLink4x4SlotId
                helpers.trySetSlotOpen(4, moduleX - 2, moduleY - 1, tab)
                helpers.trySetSlotOpen(4, moduleX - 2, moduleY, tab)
                helpers.trySetSlotOpen(4, moduleX - 2, moduleY + 1, tab)
                helpers.trySetSlotOpen(4, moduleX + 2, moduleY - 1, tab)
                helpers.trySetSlotOpen(4, moduleX + 2, moduleY, tab)
                helpers.trySetSlotOpen(4, moduleX + 2, moduleY + 1, tab)
                helpers.trySetSlotOpen(4, moduleX - 1, moduleY - 2, tab)
                helpers.trySetSlotOpen(4, moduleX, moduleY - 2, tab)
                helpers.trySetSlotOpen(4, moduleX + 1, moduleY - 2, tab)
                helpers.trySetSlotOpen(4, moduleX - 1, moduleY + 2, tab)
                helpers.trySetSlotOpen(4, moduleX, moduleY + 2, tab)
                helpers.trySetSlotOpen(4, moduleX + 1, moduleY + 2, tab)
                -- bar slots for cargoAreaInner4x4SlotId
                for x = -1, 1 do
                    for y = -1, 1 do
                        -- if x ~= 0 or y ~= 0 then
                            helpers.setSlotBarred(1, moduleX + x, moduleY + y, tab)
                        -- end
                    end
                end
                -- bar slots for cargoAreaStreetside12x4SlotId
                for x = -2, 2 do
                    for y = -1, 1 do
                        -- if x ~= 0 or y ~= 0 then
                            helpers.setSlotBarred(2, moduleX + x, moduleY + y, tab)
                        -- end
                    end
                end
                -- bar slots for cargoAreaInner12x12SlotId
                for x = -2, 2 do
                    for y = -2, 2 do
                        if x ~= 0 or y ~= 0 then -- do not bar the current module
                            helpers.setSlotBarred(3, moduleX + x, moduleY + y, tab)
                        end
                    end
                end
                -- bar slots for self on station
                -- for x = -2, 2 do
                --     for y = -1, 1 do
                --         helpers.setSlotBarred(3, x, y, tab)
                --     end
                -- end
                -- logger.print('LOLLO result.slotXYsNested after reading module 12x12 =') logger.debugPrint(result.slotXYsNested)
            elseif moduleBaseId == constants.idBases.cargoLink4x4SlotId then
                -- add slots for more cargoAreaInner4x4SlotId
                helpers.trySetSlotOpen(1, moduleX - 1, moduleY, tab)
                helpers.trySetSlotOpen(1, moduleX + 1, moduleY, tab)
                helpers.trySetSlotOpen(1, moduleX, moduleY - 1, tab)
                helpers.trySetSlotOpen(1, moduleX, moduleY + 1, tab)
                -- add slots for more cargoAreaInner12x12SlotId
                -- left and right
                helpers.trySetSlotOpen(3, moduleX - 2, moduleY - 1, tab)
                helpers.trySetSlotOpen(3, moduleX - 2, moduleY, tab)
                helpers.trySetSlotOpen(3, moduleX - 2, moduleY + 1, tab)
                helpers.trySetSlotOpen(3, moduleX + 2, moduleY - 1, tab)
                helpers.trySetSlotOpen(3, moduleX + 2, moduleY, tab)
                helpers.trySetSlotOpen(3, moduleX + 2, moduleY + 1, tab)
                -- above and below
                helpers.trySetSlotOpen(3, moduleX - 1, moduleY + 2, tab)
                helpers.trySetSlotOpen(3, moduleX, moduleY + 2, tab)
                helpers.trySetSlotOpen(3, moduleX + 1, moduleY + 2, tab)
                helpers.trySetSlotOpen(3, moduleX - 1, moduleY - 2, tab)
                helpers.trySetSlotOpen(3, moduleX, moduleY - 2, tab)
                helpers.trySetSlotOpen(3, moduleX + 1, moduleY - 2, tab)
                -- add slots for more cargoLink4x4SlotId
                helpers.trySetSlotOpen(4, moduleX - 1, moduleY, tab)
                helpers.trySetSlotOpen(4, moduleX + 1, moduleY, tab)
                helpers.trySetSlotOpen(4, moduleX, moduleY - 1, tab)
                helpers.trySetSlotOpen(4, moduleX, moduleY + 1, tab)
                -- bar slots for self on station
                -- for x = -1, 1 do
                --     helpers.setSlotBarred(4, x, 0, tab)
                -- end
                -- bar slots for cargoAreaStreetside12x4SlotId
                for x = -1, 1 do
                    -- if x ~= 0 then
                        helpers.setSlotBarred(2, moduleX + x, moduleY, tab)
                    -- end
                end
                -- bar slots for cargoAreaInner12x12SlotId
                for x = -1, 1 do
                    for y = -1, 1 do
                        -- if x ~= 0 or y ~= 0 then
                            helpers.setSlotBarred(3, moduleX + x, moduleY + y, tab)
                        -- end
                    end
                end
            end
        end
    end
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
helpers.getFlatTable = function(nestedTable)
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
---@param slotMap slotMap
---@return table
local _getFlatSlotMap = function(slotMap)
    return {
        helpers.getFlatTable(slotMap[1]),
        helpers.getFlatTable(slotMap[2]),
        helpers.getFlatTable(slotMap[3]),
        helpers.getFlatTable(slotMap[4]),
    }
end
---adds slots to result.slots, basing on slotMap
---@param slotMap slotMap
---@param params any
---@param result any
helpers.addSlots = function(slotMap, params, result)
    local _pitchAngle = pitchHelpers.getPitchAngle(params)
    local _pitchTransf = pitchHelpers.getIdTransfPitched(_pitchAngle)
    local _flatSlotMap = _getFlatSlotMap(slotMap)
    for _, v in pairs(_flatSlotMap[2]) do
        -- logger.print('### LOLLO v.y =', v.y, 'its type =', type(v.y))
        if helpers.isSlotOpen(2, v.x, v.y, slotMap) then
            table.insert(result.slots, {
                -- height = 1,
                id = helpers.mangleId(v.x, v.y, constants.idBases.cargoAreaStreetside12x4SlotId),
                -- shape 0 1 2 3
                spacing = constants.anyStreetsideSpacing,
                transf = transfUtilsUG.mul(_pitchTransf, transfUtilsUG.transl(vec3UG.new(v.x * constants.xTransfFactor, v.y * constants.yTransfFactor + constants.anyStreetsideYShift, 0.0))),
                type = constants.cargoAreaStreetside12x4ModuleType,
            })
        end
    end

    -- add 12x12 inner cargo area slots
    for _, v in pairs(_flatSlotMap[3]) do
        if helpers.isSlotOpen(3, v.x, v.y, slotMap) then
            table.insert(result.slots, {
                -- height = 1,
                id = helpers.mangleId(v.x, v.y, constants.idBases.cargoAreaInner12x12SlotId),
                -- shape 0 1 2 3
                spacing = constants.innerSpacing12x12,
                transf = transfUtilsUG.mul(_pitchTransf, transfUtilsUG.transl(vec3UG.new(v.x * constants.xTransfFactor, v.y * constants.yTransfFactor + constants.anyInnerYShift, 0.0))),
                type = constants.cargoAreaInner12x12ModuleType,
            })
        end
    end

    -- add 4x4 inner cargo area slots
    for _, v in pairs(_flatSlotMap[1]) do
        -- logger.print('### LOLLO v.y =', v.y, 'its type =', type(v.y))
        if helpers.isSlotOpen(1, v.x, v.y, slotMap) then
            table.insert(result.slots, {
                -- height = 1,
                id = helpers.mangleId(v.x, v.y, constants.idBases.cargoAreaInner4x4SlotId),
                -- shape 0 1 2 3
                spacing = constants.innerSpacing4x4,
                transf = transfUtilsUG.mul(_pitchTransf, transfUtilsUG.transl(vec3UG.new(v.x * constants.xTransfFactor, v.y * constants.yTransfFactor + constants.anyInnerYShift, 0.0))),
                type = constants.cargoAreaInner4x4ModuleType,
            })
        end
    end

    -- add 4x4 link slots
    for _, v in pairs(_flatSlotMap[4]) do
        if helpers.isSlotOpen(4, v.x, v.y, slotMap) then
            table.insert(result.slots, {
                -- height = 1,
                id = helpers.mangleId(v.x, v.y, constants.idBases.cargoLink4x4SlotId),
                -- shape 0 1 2 3
                spacing = constants.innerSpacing4x4,
                transf = transfUtilsUG.mul(_pitchTransf, transfUtilsUG.transl(vec3UG.new(v.x * constants.xTransfFactor, v.y * constants.yTransfFactor + constants.anyInnerYShift, 0.0))),
                type = constants.cargoLinks4x4ModuleType,
            })
        end
    end
end

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