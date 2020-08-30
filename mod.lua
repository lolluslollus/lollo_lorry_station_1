local arrayUtils = require('lollo_lorry_station.arrayUtils')
local fileUtils = require('lollo_lorry_station.lolloFileUtils')
local streetUtils = require('lollo_lorry_station.lolloStreetUtils')
local _constants = require('lollo_lorry_station.constants')

function data()
    local function _getUiTypeNumber(uiTypeStr)
        if uiTypeStr == 'BUTTON' then return 0
        elseif uiTypeStr == 'SLIDER' then return 1
        elseif uiTypeStr == 'COMBOBOX' then return 2
        elseif uiTypeStr == 'ICON_BUTTON' then return 3 -- double-check this
        elseif uiTypeStr == 'CHECKBOX' then return 4 -- double-check this
        else return 0
        end
    end

    local function _addAvailableConstruction(oldFileName, newFileName, scriptFileName, availability, params, streetData)
        local staticCon = api.res.constructionRep.get(api.res.constructionRep.find(oldFileName))
        local newCon = api.type.ConstructionDesc.new()
        newCon.fileName = newFileName
        newCon.type = staticCon.type
        newCon.description = staticCon.description
        -- newCon.availability = { yearFrom = 1925, yearTo = 0 } -- this dumps, the api wants it different
        newCon.availability.yearFrom = availability.yearFrom
        newCon.availability.yearTo = availability.yearTo
        newCon.buildMode = staticCon.buildMode
        newCon.categories = staticCon.categories
        newCon.order = staticCon.order
        newCon.skipCollision = staticCon.skipCollision
        newCon.autoRemovable = staticCon.autoRemovable
        for _, par in pairs(params) do
            local newConParam = api.type.ScriptParam.new()
            newConParam.key = par.key
            newConParam.name = par.name
            newConParam.tooltip = par.tooltip or ''
            newConParam.values = par.values
            newConParam.defaultIndex = par.defaultIndex or 0
            newConParam.uiType = _getUiTypeNumber(par.uiType)
            if par.yearFrom ~= nil then newConParam.yearFrom = par.yearFrom end
            if par.yearTo ~= nil then newConParam.yearTo = par.yearTo end
            newCon.params[#newCon.params + 1] = newConParam -- the api wants it this way, all the table at once dumps
        end
        newCon.updateScript.fileName = scriptFileName .. '.updateFn'
        newCon.updateScript.params = {
            globalStreetData = streetData
        }
        newCon.preProcessScript.fileName = scriptFileName .. '.preProcessFn'
        newCon.upgradeScript.fileName = scriptFileName .. '.upgradeFn'
        newCon.createTemplateScript.fileName = scriptFileName .. '.createTemplateFn'

        print('LOLLO newCon = ')
        debugPrint(newCon)
        api.res.constructionRep.add(newCon.fileName, newCon, true) -- fileName, resource, visible
    end
    return {
        info = {
            minorVersion = 0,
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
                }
            }
        },
        -- Unlike runFn, postRunFn runs after all resources have been loaded.
        -- It is the only place where we can define a dynamic construction,
        -- which is the only way we can define dynamic parameters.
        -- Here, the dynamic parameters are the street types.
        postRunFn = function(settings, params)
            local currentDir = fileUtils.getParentDirFromPath(fileUtils.getCurrentPath())
            -- print('LOLLO currentDir in postRunFn =')
            -- debugPrint(currentDir)

            local streetData = streetUtils.getGlobalStreetData() or {}
            -- print('LOLLO streetData in postRunFn =')
            -- debugPrint(streetData)
            -- print('LOLLO about to save')
            fileUtils.saveTable(streetData, currentDir .. _constants.streetDataFileName)

            if true then return end
            -- LOLLO NOTE the following works with non-modular constructions, but this one is modular.
            -- Waiting for a fix or documentation.

            local defaultStreetTypeIndex = arrayUtils.findIndex(streetData, 'fileName', 'lollo_medium_1_way_1_lane_street.lua') - 1
            if defaultStreetTypeIndex < 0 then
                defaultStreetTypeIndex = arrayUtils.findIndex(streetData, 'fileName', 'standard/country_small_one_way_new.lua') - 1
            end

            _addAvailableConstruction(
                'station/street/lollo_lorry_bay_with_edges.con',
                'station/street/lollo_lorry_bay_with_edges_2.con',
                'construction/station/street/lollo_lorry_bay_with_edges',
                {yearFrom = 1925, yearTo = 0},
                {
                    {
                        key = 'streetType_',
                        name = _('Street type'),
                        values = arrayUtils.map(
                            streetData,
                            function(str)
                                return str.name
                            end
                        ),
                        uiType = 'COMBOBOX',
                        defaultIndex = defaultStreetTypeIndex
                        -- yearFrom = 1925,
                        -- yearTo = 0
                    },
                    {
                        key = 'isStoreCargoOnPavement',
                        name = _('Store cargo on the pavement'),
                        tooltip = _('Store some of the cargo on the pavement'),
                        values = {
                            _('No'),
                            _('Yes')
                        },
                        defaultIndex = 1
                    },
                },
                streetData
            )
        end
    }
end
