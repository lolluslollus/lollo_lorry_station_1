function data()
    local modSettings = require('lollo_lorry_station.settings')
    local moduleHelpers = require('lollo_lorry_station.moduleHelpers')
    local streetUtils = require('lollo_lorry_station.streetUtils')

    return {
        info = {
            minorVersion = 22,
            severityAdd = 'NONE',
            severityRemove = 'WARNING',
            name = _('_NAME'),
            description = _('_DESC'),
            tags = {
                'Street Station', 'Truck Station'
            },
            authors = {
                {
                    name = 'Lollus',
                    role = 'CREATOR'
                },
                {
                    name = 'Bauer33333',
                    role = '3d models'
                }
            },
            params = {
				{
					key = 'gain',
					name = _('GAIN'),
					values = { 'OFF', 'ON' },
					-- defaultIndex = modSettings.paramValues.gain.defaultValueIndexBase0, -- LOLLO NOTE base 0 and base 1
                    defaultIndex = 1, -- LOLLO NOTE set this directly to avoid crashes; keep modSettings up to date if you alter this
				},
            },
        },
        runFn = function (settings, modParams)
            modSettings.setModParamsFromRunFn(modParams)
        end,
        -- Unlike runFn, postRunFn runs after all resources have been loaded.
        -- It is the only place where we can define a dynamic construction,
        -- which is the only way we can define dynamic parameters.
        -- Here, the dynamic parameters are the street types.
        postRunFn = function(settings, modParams)
            local allStreetData = streetUtils.getGlobalStreetData()

            local staticCon = api.res.constructionRep.get(
                api.res.constructionRep.find(
                    'station/street/lollo_lorry_station/lollo_lorry_bay_with_edges.con'
                )
            )
            -- UG TODO it would be nice to alter the soundSet here, but there is no suitable type
            staticCon.updateScript.fileName = 'construction/station/street/lollo_lorry_station/lollo_lorry_bay_with_edges.updateFn'
            staticCon.updateScript.params = {
                globalStreetData = allStreetData
            }
            -- this is useless
            -- staticCon.upgradeScript.fileName = 'construction/station/street/lollo_lorry_station/lollo_lorry_bay_with_edges.upgradeFn'
            moduleHelpers.updateParamValues_streetType_(staticCon.params, allStreetData)

            -- local ploppableConId = api.res.constructionRep.find(
            --     'station/street/lollo_lorry_station/lollo_lorry_bay_with_edges_ploppable.con'
            -- )
            -- local staticConPloppable = api.res.constructionRep.get(ploppableConId)
            -- staticConPloppable.updateScript.fileName = 'construction/station/street/lollo_lorry_station/lollo_lorry_bay_with_edges_ploppable.updateFn'
            -- staticConPloppable.updateScript.params = {
            --     globalStreetData = allStreetData
            -- }
            -- moduleHelpers.updateParamValues_streetType_(staticConPloppable.params, allStreetData)
            -- staticConPloppable.upgradeScript.fileName = 'construction/station/street/lollo_lorry_station/lollo_lorry_bay_with_edges_ploppable.upgradeFn'
            -- -- LOLLO NOTE when preProcessFn fires, the game throws "key not found: name"
            -- -- when it fires from con, it's fine instead.
            -- -- staticConPloppable.preProcessScript.fileName = 'construction/station/street/lollo_lorry_station/lollo_lorry_bay_with_edges_ploppable.preProcessFn'
            -- api.res.constructionRep.setVisible(ploppableConId, false)
        end,
    }
end
