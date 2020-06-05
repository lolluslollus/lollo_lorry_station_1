package.path = package.path .. ';res/scripts/?.lua'

local luadump = require('lollo_lorry_station/luadump')
local arrayUtils = require('lollo_lorry_station/arrayUtils')
local stringUtils = require('lollo_lorry_station/stringUtils')

local _modConstants = require('lollo_lorry_station/constants')

local _constants = arrayUtils.addProps(
	{
		cargoAreaSpacing = {0.0, 0.0, 0.0, 0.0}, -- {5, 5, 5, 5},
		-- the smaller these guys, the closer to the road I can fill a slot without it turning red.
		-- negative values don't matter, the api takes up the abs value
		-- lorryBaySpacing = {0.1, 0.1, 0.1, 0.1},
		lorryBaySpacing = {0.0, 0.0, 0.0, 0.0},
		idBases = { -- LOLLO NOTE keep this sorted descending
			areaSlotIdBase = 120000,
            pathSlotIdBase = 110000,
            lollo = 1333,
            lalla = 999999999999
		},
		idFactorY = 100
	},
	_modConstants
)
local _idBasesSortedDesc = {}
for k, v in pairs(_constants.idBases) do
    table.insert(_idBasesSortedDesc, {id = v, name = k})
end
arrayUtils.sort(_idBasesSortedDesc, 'id', false)

local MangleId = function(x, y, baseId)
	return baseId + _constants.idFactorY * (y  - _constants.yMin) + (x  - _constants.xMin)
end

-- result.DemangleId = function(slotId)
-- 	local rem = slotId % 100
-- 	local variant = rem
-- 	slotId = (slotId - rem) / 100
-- 	rem = slotId % 2000
-- 	local coordI = rem - 100
-- 	slotId = (slotId - rem) / 2000
-- 	return coordI, slotId - 100, variant
-- end

local DemangleId = function(slotId)
	-- debugger()
	local function _getIdBase(slotId)
		local baseId = 0
		for _, v in pairs(_idBasesSortedDesc) do
			if slotId >= v.id then
				baseId = v.id
				break
			end
		end

		return baseId > 0 and baseId or false
	end

	local baseId = _getIdBase(slotId)
	if not baseId then return false, false, false end

	local y = math.floor((slotId - baseId) / _constants.idFactorY)
	local x = math.floor((slotId - baseId - y * _constants.idFactorY))

	return x + _constants.xMin, y + _constants.yMin, baseId
end

local mangledIds = {}
for x = _constants.xMin, _constants.xMax do
	for y = _constants.yMin, _constants.yMax do
		mangledIds[#mangledIds + 1] = MangleId(x, y, _constants.idBases.areaSlotIdBase)
	end
end

local demangledIds = {}
for i = 1, #mangledIds do
	local x, y, baseId = DemangleId(mangledIds[i])
	demangledIds[#demangledIds + 1] = {x, y, baseId}
end

local par = { lollo = true }
