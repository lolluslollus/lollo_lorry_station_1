local arrayUtils = require('lollo_lorry_station/arrayUtils')

local constants = {
	xMax = 10,
	yMax = 10,
	xMin = -10,
    yMin = -10,
	xTransfFactor = 5, -- each grid slot has this x size
	yTransfFactor = 5, -- each grid slot has this y size
	anyInnerSpacing = {2, 2, 2, 2}, -- the smaller, the less the risk of collision. Too small, problems removing the module.
	anyInnerXShift = 0,
	anyInnerYShift = -0.5,
	anyStreetsideSpacing = {2, 2, 2, 2},
	anyStreetsideXShift = 0,
	anyStreetsideYShift = 0,
	-- markTag = 'lollo_mark',
	cargoAreaInner15x15ModelFileName = 'lollo_lorry_station/cargo_area_inner_15x15.mdl',
	cargoAreaInner15x15ModelTag = 'cargoAreaInner15x15',
	cargoAreaInner15x15ModuleType = 'cargo_area_inner_15x15',
	cargoAreaInner5x5ModelFileName = 'lollo_lorry_station/cargo_area_inner_5x5.mdl',
	cargoAreaInner5x5ModelTag = 'cargoAreaInner5x5',
	cargoAreaInner5x5ModuleType = 'cargo_area_inner_5x5',
	cargoAreaStreetside15x5ModelFileName = 'lollo_lorry_station/cargo_area_streetside_15x5.mdl',
	cargoAreaStreetside15x5ModelTag = 'cargoAreaStreetside15x5',
	cargoAreaStreetside15x5ModuleType = 'cargo_area_streetside_15x5',
	lorryBayStreetside15x5ModelFileName = 'lollo_lorry_station/lorry_bay_streetside_15x5.mdl',
	lorryBayStreetside15x5ModelTag = 'lorryBayStreetside15x5',
	lorryBayStreetside15x5ModuleType = 'lorry_bay_streetside_15x5',
	lorryBayStreetsideEntrance15x5ModelFileName = 'lollo_lorry_station/lorry_bay_streetside_entrance_15x5.mdl',
	-- markModelFileName = 'lollo_lorry_station/lollo_mark.mdl',
	-- constructionFileName = 'station/street/lollo_lorry_station.con',
	idBases = {
		cargoAreaInner5x5SlotId = 150000,
		cargoAreaStreetside15x5SlotId = 140000,
		cargoAreaInner15x15SlotId = 130000,
		rightLorryBaySlotIdBase = 120000,
		leftLorryBaySlotIdBase = 110000,
		centreSlotIdBase = 100000,
	},
	idRoundingFactor = 100,
}

local _idBasesSortedDesc = {}
for k, v in pairs(constants.idBases) do
    table.insert(_idBasesSortedDesc, {id = v, name = k})
end
arrayUtils.sort(_idBasesSortedDesc, 'id', false)
constants.idBasesSortedDesc = _idBasesSortedDesc

return constants