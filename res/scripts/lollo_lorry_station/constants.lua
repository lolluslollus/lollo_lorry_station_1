local arrayUtils = require('lollo_lorry_station.arrayUtils')

local constants = {
	idTransf = {1, 0, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1},

	xMax = 16,
	yMax = 10,
	xMin = -16,
    yMin = -10,
	-- xTransfFactor = 5, -- each grid slot has this x size
	-- yTransfFactor = 5, -- each grid slot has this y size
	xTransfFactor = 4, -- each grid slot has this x size
	yTransfFactor = 4, -- each grid slot has this y size
	innerSpacing4x4 = {1.5, 1.5, 1.5, 1.5}, -- the smaller, the less the risk of collision. Too small, problems removing the module.
	innerSpacing12x12 = {5.5, 5.5, 5.5, 5.5},
	anyInnerXShift = 0,
	-- LOLLO NOTE streetside elements have a visible width of 4, the other elements 5 or 15. (4 - 5) / 2 is -0.5 .
	-- The cargo graphics are 4x4 m and many street pavements are 4 m wide,
	-- so 4x4, 12x4, 12x12 would be smarter module sizes.
	-- anyInnerYShift = -0.5,
	anyInnerYShift = 0,
	anyStreetsideSpacing = {5.5, 5.5, 1.5, 1.5}, -- the smaller, the less the risk of collision. Too small, problems removing the module.
	anyStreetsideXShift = 0,
	anyStreetsideYShift = 0,
	removerSpacing = {2, 2, 2, 0},

	cargoAreaInner12x12ModuleType = 'cargo_area_inner_12x12',
	cargoAreaInner4x4ModuleType = 'cargo_area_inner_4x4',
	cargoAreaStreetside12x4ModuleType = 'cargo_area_streetside_12x4',
	cargoLinks4x4ModuleType = 'cargo_links_4x4',
	dummyModuleType = 'dummy',
	lorryBayStreetside12x4ModelTag = 'lorryBayStreetside12x4',
	lorryBayStreetside12x4ModuleType = 'lorry_bay_streetside_12x4',
	lorryBayStreetsideEntrance12x4ModelTag = 'lorryBayStreetsideEntrance12x4',
	removeAllModuleType = 'lorry_bay_remove_all',
	removeModulesModuleType = 'lorry_bay_remove_modules',
	storeCargoOnPavementModuleType = 'lorry_bay_store_cargo_on_pavement',
	storeCargoOnPavementModuleName = 'station/street/lollo_lorry_station/lollo_store_cargo_on_pavement.module',

	lorryBayVehicleEdgeLeftModelTag = 'lorryBayVehicleEdgeLeft',
	lorryBayVehicleEdgeRightModelTag = 'lorryBayVehicleEdgeRight',

	modelWithCargoAreaTag = 'modelWithCargoAreaTag',
	-- constructionFileName = 'station/street/lollo_lorry_station/lollo_lorry_station.con',

	idBases = {
		dummySlotId = 400000,
		removeModulesSlotId = 320000,
		storeCargoOnPavementSlotId = 310000,
		removeAllSlotId = 300000,
		cargoLink4x4SlotId = 270000,
		cargoAreaStreetside12x4SlotId = 260000,
		cargoAreaInner4x4SlotId = 250000,
		cargoAreaInner12x12SlotId = 240000,
		-- cargoLink5x5SlotId = 170000,
		-- cargoAreaStreetside15x5SlotId = 160000,
		-- cargoAreaInner5x5SlotId = 150000,
		-- cargoAreaInner15x15SlotId = 140000,
		-- rightLorryBaySlotIdBase = 130000,
		-- leftLorryBaySlotIdBase = 120000,
		-- rightVehicleEdgeSlotIdBase = 110000,
		-- leftVehicleEdgeSlotIdBase = 100000,
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
