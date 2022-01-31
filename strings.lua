function data()
	return {
		en = {
			["_DESC"] = [[
				A modular lorry station with one single terminal, available from 1925.

				You can combine several of these to make a complex lorry station, with full control on the paths and the capacities. You can also combine them with the stock streetside stations, using them as unload-only points for your hub.
				
				To place one, make the streets first and leave a gap for the station, which comes with its own piece of road attached.
				Best: install the street fine tuning, draw your street, slice it in two points, bulldoze the segment between and replace it with this station.
                
				You can use the pavement to store cargo or leave it clear.

				Cargo links connect separate areas into a single loading bay, even across obstacles.

				TIPS AND TRICKS
				Use <o> and <p> to adjust the pitch.
				
				Placing two stations close to each other can be a pain, because the game tries to snap things together, fails and raises pointless error messages. Add some extra length to get past this, or leave a broader gap between your stations, or change the "snap to neighbours" property.

				Install the street fine tuning to have useful building tools and more roads. Use the categories in the street menu so you don't go bananas selecting road types.

				If you want to force something into a station catchment area, use the ultrathin paths or the cargo links.

				You can use modded street types, as long as they have one of the following categories: country, highway, one-way, urban, mining.

				If you attempt to configure your station and see collision warnings, make sure the right street type is selected in the configuration menu. It is a dynamic selection and it can do that, it's a game limit.
				
				If you are not happy with a street mod, remove or reconfigure the modular lorry stations that use it, remove or replace all the modded streets, quit the game and reload it without the offending mod.

				WORD OF WARNING
				The first iteration of this mod had an awkward grid. If you have already built some of these stations, they will keep working. As soon as you configure them, the old modules will go away and you will have to plop the new ones instead. It is a one-off and a small price to pay for a decidedly better grid.
				There was another breaking change in Seeptember 2021. Your old stations will keep working, but you will need to bulldoze and rebuild them if you want to edit them.
			]],
			["_NAME"] = "Modular streetside lorry station",
			["GAIN"] = "Sound Effects",
			["ON"] = "On",
			["OFF"] = "Off",
			["BUS_STOP_NAME"] = "Modular bus load/unload stop",
			["BUS_STOP_DESC"] = "Bus stop to be placed on the pavement. Plop it, select it and configure it like the other modular constructions. Remove it with its own module to preserve the roads.",
			["LORRY_STOP_NAME"] = "Modular lorry load/unload station",
			["LORRY_STOP_DESC"] = "Modular lorry station. Plop it, select it and configure it like the other modular constructions. Remove it with its own module to preserve the roads.",
			["LORRY_STOP_PLOPPABLE_NAME"] = "Ploppable modular lorry load/unload station",
			["LORRY_STOP_PLOPPABLE_DESC"] = "Modular lorry station to be placed on the pavement. Plop it, select it and configure it like the other modular constructions. Remove it with its own module to preserve the roads.",
			["removeAllName"] = "Remove All",
			["removeAllDesc"] = "Remove all rebuilding the road",
			["NewStationName"] = "New Station",
			["snapNodesName"] = "Snap to neighbours while placing",
			["snapNodesDesc"] = "\"No snap\" can be easier to place. It will be ignored once the station is built.",
			["directionName"] = "Direction",
			["directionDesc"] = "Place the station right or left, you cannot have both.",
			["extraLengthName"] = "Extra Length",
			["extraLengthDesc"] = "Helps placing parallel stations that tend to snap together.",
			["isStoreCargoOnPavementName"] = "Store cargo on the pavement",
			["isStoreCargoOnPavementDesc"] = "Store some of the cargo on the pavement.",
			["No"] = "No",
			["Left"] = "End A",
			["Right"] = "End B",
			["Both"] = "Both Ends",
		},
	}
end
