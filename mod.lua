local moduleHelpers = require('lollo_lorry_station.moduleHelpers')
local streetUtils = require('lollo_lorry_station.streetUtils')

function data()
    return {
        info = {
            minorVersion = 15,
            severityAdd = 'NONE',
            severityRemove = 'WARNING',
            name = _('_NAME'),
            description = _('_DESC'),
            tags = {
                'Street Station, Truck Station'
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
            }
        },
        -- Unlike runFn, postRunFn runs after all resources have been loaded.
        -- It is the only place where we can define a dynamic construction,
        -- which is the only way we can define dynamic parameters.
        -- Here, the dynamic parameters are the street types.
        postRunFn = function(settings, params)
            local allStreetData = streetUtils.getGlobalStreetData(
                streetUtils.getStreetDataFilters().STOCK
            )

            local staticCon = api.res.constructionRep.get(
                api.res.constructionRep.find(
                    'station/street/lollo_lorry_station/lollo_lorry_bay_with_edges.con'
                )
            )
            staticCon.updateScript.fileName = 'construction/station/street/lollo_lorry_station/lollo_lorry_bay_with_edges.updateFn'
            staticCon.updateScript.params = {
                globalStreetData = allStreetData
            }
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
