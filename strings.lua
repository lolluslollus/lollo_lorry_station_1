function data()
	return {
		en = {
			["_DESC"] = [[
				A modular lorry station with one single terminal.

				You can combine several of these to make a complex lorry station, with full control on the paths and the capacities.
				
				To place one, make the streets first and leave some empty space for the station. Help yourself with the slicer, you will find it in the street construction menu.
				Streetside cargo areas are designed to overlap with the street side. If you want to alter the underlying road, you must remove them, alter the road and plop them back in, to avoid the collision warning.

				This mod requires the street fine tuning, which provides extra street types, junctions and a slicer tool to avoid destroying too many buildings.
				
				If you want to force something into a station catchment area, use the ultrathin paths.

				At the current state of the game, I could not find a way to make this station entirely non-destructive: if you have buildings around, some will have to go. They should regrow though, let me know.

				WORD OF WARNING: the first iteration of this mod had an awkward grid. If you have already built some of these stations, they will keep working. As soon as you configure them, the old modules will go away and you will have to plop the new ones instead. It is a one-off and a small price to pay for a decidedly better grid.
			]],
			["_NAME"] = "Modular streetside lorry station"
		},
	}
end
