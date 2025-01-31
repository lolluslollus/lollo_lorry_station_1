local arrayUtils = require('lollo_lorry_station.arrayUtils')

local constants = {
	xMax = 16,
	yMax = 10,
	xMin = -16,
    yMin = -10,
	-- xTransfFactor = 5, -- each grid slot has this x size
	-- yTransfFactor = 5, -- each grid slot has this y size
	xTransfFactor = 4, -- each grid slot has this x size
	yTransfFactor = 4, -- each grid slot has this y size
	innerSpacing4x4 = {2, 2, 2, 2}, -- the smaller, the less the risk of collision. Too small, problems removing the module.
	innerSpacing12x12 = {6, 6, 6, 6},
	anyInnerXShift = 0,
	-- LOLLO NOTE streetside elements have a visible width of 4, the other elements 5 or 15. (4 - 5) / 2 is -0.5 .
	-- The cargo graphics are 4x4 m and many street pavements are 4 m wide,
	-- so 4x4, 12x4, 12x12 would be smarter module sizes.
	-- anyInnerYShift = -0.5,
	anyInnerYShift = 0,
	anyStreetsideSpacing = {6, 6, 2, 2}, -- the smaller, the less the risk of collision. Too small, problems removing the module.
	anyStreetsideXShift = 0,
	anyStreetsideYShift = 0,
	-- markTag = 'lollo_mark',
	ploppableCargoModelId = 'lollo_lorry_station/lollo_ploppable_streetside_cargo.mdl',
	ploppablePassengersModelId = 'lollo_lorry_station/lollo_ploppable_streetside_passengers.mdl',

	cargoAreaInner12x12ModuleType = 'cargo_area_inner_12x12',
	cargoAreaInner4x4ModuleType = 'cargo_area_inner_4x4',
	cargoAreaStreetside12x4ModuleType = 'cargo_area_streetside_12x4',
	cargoLinks4x4ModuleType = 'cargo_links_4x4',
	lorryBayStreetside12x4ModelFileName = 'lollo_lorry_station/lorry_bay_streetside_12x4.mdl',
	lorryBayStreetside12x4ModelTag = 'lorryBayStreetside12x4',
	lorryBayStreetside12x4ModuleType = 'lorry_bay_streetside_12x4',
	lorryBayStreetsideEntrance12x4ModelFileName = 'lollo_lorry_station/lorry_bay_streetside_entrance_12x4.mdl',
	lorryBayStreetsideEntrance12x4ModelTag = 'lorryBayStreetsideEntrance12x4',
	removeAllModuleType = 'lorry_bay_remove_all',
	storeCargoOnPavementModuleType = 'lorry_bay_store_cargo_on_pavement',
	storeCargoOnPavementModuleName = 'station/street/lollo_lorry_station/lollo_store_cargo_on_pavement.module',

	cargoAreaInner15x15ModelFileName = 'lollo_lorry_station/cargo_area_inner_15x15.mdl',
	cargoAreaInner15x15ModuleType = 'cargo_area_inner_15x15',
	cargoAreaInner5x5ModelFileName = 'lollo_lorry_station/cargo_area_inner_5x5.mdl',
	cargoAreaInner5x5ModuleType = 'cargo_area_inner_5x5',
	cargoAreaStreetside15x5ModelFileName = 'lollo_lorry_station/cargo_area_streetside_15x5.mdl',
	cargoAreaStreetside15x5ModuleType = 'cargo_area_streetside_15x5',
	cargoLinks5x5ModelFileName = 'lollo_lorry_station/cargo_links_5x5.mdl',
	cargoLinks5x5ModuleType = 'cargo_links_5x5',
	lorryBayStreetside15x5ModelFileName = 'lollo_lorry_station/lorry_bay_streetside_15x5.mdl',
	lorryBayStreetside15x5ModelTag = 'lorryBayStreetside15x5',
	lorryBayStreetside15x5ModuleType = 'lorry_bay_streetside_15x5',
	lorryBayStreetsideEntrance15x5ModelFileName = 'lollo_lorry_station/lorry_bay_streetside_entrance_15x5.mdl',
	lorryBayStreetsideEntrance15x5ModelTag = 'lorryBayStreetsideEntrance15x5',
	lorryBayVehicleEdgeLeftModelFileName = 'lollo_lorry_station/lorry_bay_vehicle_edge_left.mdl',
	lorryBayVehicleEdgeLeftModelTag = 'lorryBayVehicleEdgeLeft',
	lorryBayVehicleEdgeRightModelFileName = 'lollo_lorry_station/lorry_bay_vehicle_edge_right.mdl',
	lorryBayVehicleEdgeRightModelTag = 'lorryBayVehicleEdgeRight',
	lorryBayVehicleEdge4PloppableModelFileName = 'lollo_lorry_station/lorry_bay_vehicle_edge_4_ploppable.mdl',
	lorryBayVehicleEdge4PloppableModelTag = 'lorryBayVehicleEdge4Ploppable',
	-- constructionFileName = 'station/street/lollo_lorry_station/lollo_lorry_station.con',

	idBases = {
		storeCargoOnPavementSlotId = 310000,
		removeAllSlotId = 300000,
		cargoLink4x4SlotId = 270000,
		cargoAreaStreetside12x4SlotId = 260000,
		cargoAreaInner4x4SlotId = 250000,
		cargoAreaInner12x12SlotId = 240000,
		cargoLink5x5SlotId = 170000,
		cargoAreaStreetside15x5SlotId = 160000,
		cargoAreaInner5x5SlotId = 150000,
		cargoAreaInner15x15SlotId = 140000,
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