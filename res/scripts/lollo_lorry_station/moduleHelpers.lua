local arrayUtils = require('lollo_lorry_station.arrayUtils')
local slotUtils = require('lollo_lorry_station.slotHelpers')
local transfUtilsUG = require 'transf'

local helpers = {}

local function _getDummyValues(howMany)
    if not(howMany) then howMany = 100 end

    local results = {}
    for i = 1, howMany do
        results[#results+1] = 'dummy' .. i
    end

    return results
end

helpers.getGroundFace = function(face, key)
    return {
        face = face, -- LOLLO NOTE Z is ignored here
        loop = true,
        modes = {
            {
                type = 'FILL',
                key = key
            }
        }
    }
end

helpers.getTerrainAlignmentList = function(face)
    local _raiseBy = 0.28 -- a lil bit less than 0.3 to avoid bits of construction being covered by earth
    local raisedFace = {}
    for i = 1, #face do
        raisedFace[i] = face[i]
        raisedFace[i][3] = raisedFace[i][3] + _raiseBy
    end
    -- print('LOLLO raisedFaces =')
    -- debugPrint(raisedFace)
    return {
        faces = {raisedFace},
        optional = true,
        slopeHigh = 9,
        slopeLow = 0.3,
        type = 'EQUAL',
    }
end

helpers.getVariant = function(params, slotId)
    local variant = 0
    if type(params) == 'table'
    and type(params.modules) == 'table'
    and type(params.modules[slotId]) == 'table'
    and type(params.modules[slotId].variant) == 'number' then
        variant = params.modules[slotId].variant
    end
    return variant
end

local _lengthMultiplier = 10
local _lengths = {}
for i = 0, 12 do -- watch out, the parameters have base 0
    table.insert(_lengths, i * _lengthMultiplier)
end

helpers.getLengthMultiplier = function()
    return _lengthMultiplier
end

helpers.getLengths = function()
    return _lengths
end

-- LOLLO NOTE adding colliders with this seems correct,
-- but calling it from con.updateFn or from a module.updateFn or terminateConstructionHook
-- will result in no colliders at all being active,
-- except for the edge colliders
helpers.getCollider = function(sidewalkWidth, model)
	local result = nil
	if sidewalkWidth < 3.8 then
		if slotUtils.getIsStreetside(model.tag) then
			local transfRes = transfUtilsUG.mul(
				model.transf,
				{ 1, 0, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, sidewalkWidth * 0.5, 0, 1 }
			)
			-- print('LOLLO transfRes =')
			-- debugPrint(transfRes)
			result = {
				params = {
					halfExtents = { 5.9, 1.9 - sidewalkWidth * 0.5, 1.0 },
				},
				transf = transfRes,
				type = 'BOX',
			}
		end

		-- print('LOLLO model =')
		-- debugPrint(model)
		-- print('LOLLO collider =')
		-- debugPrint(result)
	end

	return result
end

helpers.getParams = function(allStreetData, defaultStreetTypeIndex)
    return {
        -- {
        --     key = 'streetType_',
        --     name = _('Street type'),
        --     values = arrayUtils.map(
        --         allStreetData,
        --         function(str)
        --             return str.name
        --         end
        --     ),
        --     uiType = 'COMBOBOX',
        --     defaultIndex = defaultStreetTypeIndex
        --     -- yearFrom = 1925,
        --     -- yearTo = 0
        -- },
        {
            key = 'streetType_',
            name = _('Street type'),
            -- will be replaced at postRunFn
            values = {
                'dummy1',
                'dummy2'
            },
            -- will be replaced at postRunFn
            uiType = 'BUTTON',
            -- will be replaced at postRunFn
            defaultIndex = 0
        },
        -- {
        --     key = 'isStoreCargoOnPavement',
        --     name = _('isStoreCargoOnPavementName'),
        --     tooltip = _('isStoreCargoOnPavementDesc'),
        --     values = {
        --         _('No'),
        --         _('Yes')
        --     },
        --     defaultIndex = 1
        -- },
        {
            key = 'direction',
            name = _('directionName'),
            tooltip = _('directionDesc'),
            values = {
                _('↑'),
                _('↓')
            },
            defaultIndex = 0
        },
        {
            key = 'snapNodes',
            name = _('snapNodesName'),
            tooltip = _('snapNodesDesc'),
            values = {
                _('No'),
                _('Yes')
            },
            defaultIndex = 1
        },
        {
            key = 'tramTrack',
            name = _('Tram track'),
            values = {
                -- must be in this sequence
                _('NO'),
                _('YES'),
                _('ELECTRIC')
            },
            defaultIndex = 0
        },
        {
            key = 'extraLength',
            name = _('extraLengthName'),
            tooltip = _('extraLengthDesc'),
            -- values = {_('0m'), _('1m'), _('2m'), _('3m'), _('4m')},
            values = arrayUtils.map(
                helpers.getLengths(),
                function(length)
                    return tostring(length) .. 'm'
                end
            ),
            defaultIndex = 0
        },
    }
end

helpers.getDefaultStreetTypeIndex = function(allStreetData)
    if type(allStreetData) ~= 'table' then return 0 end

    local result = arrayUtils.findIndex(allStreetData, 'fileName', 'lollo_medium_1_way_1_lane_street_narrow_sidewalk.lua') - 1
    if result < 0 then
        result = arrayUtils.findIndex(allStreetData, 'fileName', 'standard/country_small_one_way_new.lua') - 1
    end

    return result > 0 and result or 0
end

helpers.updateParamValues_streetType_ = function(params, allStreetData)
    for _, param in pairs(params) do
        if param.key == 'streetType_' then
            param.values = arrayUtils.map(
                allStreetData,
                function(str)
                    return str.name
                end
            )
            param.defaultIndex = helpers.getDefaultStreetTypeIndex(allStreetData)
            param.uiType = 2 -- 'COMBOBOX'
            -- print('streetType_ param =')
            -- debugPrint(param)
        end
    end
end

return helpers
