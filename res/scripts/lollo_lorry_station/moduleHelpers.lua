local arrayUtils = require('lollo_lorry_station.arrayUtils')
local slotUtils = require('lollo_lorry_station.slotHelpers')
local transf = require 'transf'

local helpers = {}

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
        slopeHigh = 99,
        slopeLow = 0.1,
        type = 'EQUAL',
    }
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
			local transfRes = transf.mul(
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

helpers.getColliders = function(sidewalkWidth, models)
	local result = {}
	for _, model in pairs(models) do
		table.insert(result, helpers.getCollider(sidewalkWidth, model))
	end
	return result
end

helpers.getParams = function(allStreetData, defaultStreetTypeIndex)
    return {
        {
            key = 'streetType_',
            name = _('Street type'),
            values = arrayUtils.map(
                allStreetData,
                function(str)
                    return str.name
                end
            ),
            uiType = 'COMBOBOX',
            defaultIndex = defaultStreetTypeIndex
            -- yearFrom = 1925,
            -- yearTo = 0
        },
        {
            key = 'isStoreCargoOnPavement',
            name = _('Store cargo on the pavement'),
            tooltip = _('Store some of the cargo on the pavement or leave it clear for pedestrians'),
            values = {
                _('No'),
                _('Yes')
            },
            defaultIndex = 1
        },
        {
            key = 'direction',
            name = _('Direction'),
            tooltip = _('Place the station right or left. You cannot have both'),
            values = {
                _('↑'),
                _('↓')
            },
            defaultIndex = 0
        },
        {
            key = 'snapNodes',
            name = _('Snap to neighbours'),
            tooltip = _('No snap can cause collisions when configuring but it is easier to place'),
            values = {
                _('No'),
                _('Yes')
            },
            defaultIndex = 1
        },
        {
            key = 'tramTrack',
            name = _('Tram track type'),
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
            name = _('Extra Length'),
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

return helpers
