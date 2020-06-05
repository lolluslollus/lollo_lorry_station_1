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
		-- cargoPathSpacing = {0.1, 0.1, 0.1, 0.1},
		cargoPathSpacing = {0.0, 0.0, 0.0, 0.0},
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

local idBasesSorted = {}
for k, v in pairs(_constants.idBases) do
    table.insert(idBasesSorted, {id = v, name = k})
end
arrayUtils.sort(idBasesSorted, 'id', false)
for k, v in pairs(idBasesSorted) do
    local vvv = v
    local kkk = k
end
local par = { lollo = true }
