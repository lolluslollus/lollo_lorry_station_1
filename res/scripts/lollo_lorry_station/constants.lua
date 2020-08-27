local arrayUtils = require('lollo_lorry_station/arrayUtils')

local constants = {
	xMax = 10,
	yMax = 10,
	xMin = -10,
    yMin = -10,
    -- xPrefix = 'x_',
    -- yPrefix = 'y_',
	xTransfFactor = 10,
	yTransfFactor = 10,
	lorryBayXShift = 0, --20,
	lorryBayYShift = 3,
	markTag = 'lollo_mark',
	cargoAreaModelFileName = 'lollo_models/lollo_simple_cargo_area.mdl',
	cargoAreaModuleType = 'lollo_street_terminal_cargo_area',
	cargoAreaSpacing = {2, 2, 2, 2}, -- the smaller, the less the risk of collision. Too small, problems removing the module.
	lorryBayModelFileName = 'lollo_models/lollo_lorry_bay.mdl',
	lorryBayModuleType = 'lollo_street_terminal_lorry_bay',
	lorryBaySpacing = {0.5, 0.5, 0.5, 0.5},
	markModelFileName = 'lollo_models/lollo_mark.mdl',
	constructionFileName = 'station/street/lollo_lorry_station.con',
	idBases = {
		areaSlotIdBase = 130000,
		rightBaySlotIdBase = 120000,
		leftBaySlotIdBase = 110000,
		centreSlotIdBase = 100000,
	},
	idFactorY = 100,
}

local _idBasesSortedDesc = {}
for k, v in pairs(constants.idBases) do
    table.insert(_idBasesSortedDesc, {id = v, name = k})
end
arrayUtils.sort(_idBasesSortedDesc, 'id', false)
constants.idBasesSortedDesc = _idBasesSortedDesc

return constants