local arrayUtils = require('lollo_lorry_station.arrayUtils')
local moduleHelpers = require('lollo_lorry_station.moduleHelpers')
local streetUtils = require('lollo_lorry_station.streetUtils')

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
        newCon.description.name = 'Lollo roadside lorry bay with postRunFn'
        -- newCon.availability = { yearFrom = 1925, yearTo = 0 } -- this dumps, the api wants it different
        newCon.availability.yearFrom = availability.yearFrom
        newCon.availability.yearTo = availability.yearTo
        newCon.buildMode = staticCon.buildMode
        newCon.categories = staticCon.categories
        newCon.order = staticCon.order
        newCon.skipCollision = staticCon.skipCollision
        newCon.autoRemovable = staticCon.autoRemovable
        newCon.soundConfig = staticCon.soundConfig
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
            minorVersion = 5,
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
        postRunFnBAK = function(settings, params)
            -- local currentDir = fileUtils.getParentDirFromPath(fileUtils.getCurrentPath())
            -- print('LOLLO currentDir in postRunFn =')
            -- debugPrint(currentDir)

            local allStreetData = streetUtils.getGlobalStreetData()
            -- print('LOLLO streetData in postRunFn =')
            -- debugPrint(streetData)
            -- print('LOLLO about to save')
            -- local saveResult = fileUtils.saveTable(streetData or {}, currentDir .. _constants.streetDataFileName)
            -- print('LOLLO saveResult =')
            -- debugPrint(saveResult)

            -- if true then return end
            -- LOLLO NOTE the following works with non-modular constructions, but this one is modular.
            -- Waiting for a fix or documentation.
            -- The program dumps when plopping a module:
            -- "key not found: name"
            -- In the meantime, we write to a file here and read it in the .con
            -- The trouble is, first .con is called twice, then postRunFn, then again .con twice.
            -- If the file does not exist, even if it written correctly here, the .con will dump
            -- Solution: ship __streetData with the mod.
            -- The first time you run this mod, only its data will take effect;
            -- The next game start will read the correct data.

            local defaultStreetTypeIndex = arrayUtils.findIndex(allStreetData, 'fileName', 'lollo_medium_1_way_1_lane_street.lua') - 1
            if defaultStreetTypeIndex < 0 then
                defaultStreetTypeIndex = arrayUtils.findIndex(allStreetData, 'fileName', 'standard/country_small_one_way_new.lua') - 1
            end

            _addAvailableConstruction(
                'station/street/lollo_lorry_bay_with_edges.con',
                'station/street/lollo_lorry_bay_with_edges_2.con',
                'construction/station/street/lollo_lorry_bay_with_edges',
                {yearFrom = 1925, yearTo = 0},
                moduleHelpers.getParams(allStreetData, defaultStreetTypeIndex),
                allStreetData
            )
        end
    }
end
