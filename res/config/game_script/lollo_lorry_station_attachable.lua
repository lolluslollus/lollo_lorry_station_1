local arrayUtils = require('lollo_lorry_station/arrayUtils')
local edgeUtils = require('lollo_lorry_station/edgeHelpers')
-- local _modConstants = require('lollo_lorry_station/constants')
local stringUtils = require('lollo_lorry_station/stringUtils')

local state = {
    isShowAllEvents = false
}

local _constants = arrayUtils.addProps({
    constructionFileName = 'station/street/lollo_lorry_station.con',
    stationFileName = 'station/road/lollo_small_cargo.mdl'
})

-- The idea here is, the user plops a streetside lorry station and then selects it.
-- The trouble is, there is no way to tell what I really selected.
local function _getCloneWoutModulesAndSeed(obj)
    return arrayUtils.cloneOmittingFields(obj, {'modules', 'seed'})
end

local function _getTransfFromApiResult(transfStr)
    transfStr = transfStr:gsub('%(%(', '(')
    transfStr = transfStr:gsub('%)%)', ')')
    local results = {}
    for match0 in transfStr:gmatch('%([^(%))]+%)') do
        local noBrackets = match0:gsub('%(', '')
        noBrackets = noBrackets:gsub('%)', '')
        for match1 in noBrackets:gmatch('[%-%.%d]+') do
            results[#results + 1] = match1
        end
    end
    return results
end

local function _myErrorHandler(err)
    print('ERROR: ', err)
end

function data()
    return {
        handleEvent = function(src, id, name, args)
            if src == 'guidesystem.lua' then
                return
            end -- also comes with guide system switched off
            -- if state.isShowAllEvents then
            print('LOLLO handleEvent src =', src, ' id =', id, ' name =', name)
            -- end
            if (id == '__lolloLorryStation2Event__') then
                print('__lolloLorryStation2Event__ caught')
                print('LOLLO src = ', src, ' id = ', id, ' name = ', name, 'param = ')
                debugPrint(args)

                if name == 'built' then
                    -- LOLLO TODO check out args.entity2tn
                    local baseEdge = nil
                    for key, value in args.entity2tn do
                        local entity = game.interface.getEntity(key)
                        if entity.type == 'BASE_EDGE' then
                            -- LOLLO TODO localise the base edge
                            -- that owns the model with the right id,
                            -- this is too simple
                            baseEdge = entity
                        end
                    end
                    if not (baseEdge) then
                        return
                    end

                    local transf0 = _getTransfFromApiResult(args.transfStr)
                    -- LOLLO TODO destroy the newly built streetside station
                    -- and replace it with a construction containing the same, but with the cargo lanes
                    -- Alternatively, try just adding a cargo area like lollo_cargo_area.mdl

                    -- print('LOLLO game.interface.buildConstruction = ')
                    -- debugPrint(game.interface.buildConstruction)

                    -- local allModels = api.res.modelRep.getAll()
                    -- I arrive here from built with a funny transf looking like
                    -- 'transf' = '((0.203505 / -0.979074 / 0 / 0)/(0.979074 / 0.203505 / 0 / 0)/(0 / 0 / 1 / 0)/(569.336 / -3375.41 / 14.1587 / 1))'
                    -- which I stringified coz it is userData

                    -- from here on, I need to reverse the parameters.transf string somehow.
                    -- It looks like:
                    -- 'transf' = '((0.594247 / -0.804282 / 0 / 0)/(0.804282 / 0.594247 / 0 / 0)/(0 / 0 / 1 / 0)/(-3463.13 / 3196.42 / 55.4744 / 1))'
                elseif name == 'select' then
                    -- print('LOLLO game.interface.buildConstruction = ')
                    -- debugPrint(game.interface.buildConstruction)

                    -- local newId = game.interface.upgradeConstruction(
                    --     parameters.id,
                    --     _constants.constructionFileName,
                    --     parameters.params
                    -- )
                end
            end

            state.isShowAllEvents = true

            --[[             package.loaded['lollo_lorry_station/reloaded'] = nil
            local reloaded = require('lollo_lorry_station/reloaded')
            reloaded.tryDebugger()
 ]]

            -- package.loaded['lollo_lorry_station/reloaded'] = nil
            -- local reloaded = require('lollo_lorry_station/reloaded')
            -- reloaded.tryGlobalVariables()

        end,
        guiHandleEvent = function(id, name, param)
            -- LOLLO NOTE when U try to add a streetside bus or lorry stop, the streetBuilder fires this event.
            -- Then, the proposal contains no new objects and no old objects: it's not empty, but it's only filled with objects
            -- that are in turn filled with empty objects.
            -- Once the user has hovered on a suitable spot (ie streetside), the proposal is not empty anymore,
            -- and it is actually rather complex.
            -- package.loaded['lollo_lorry_station/reloaded'] = nil
            -- local reloaded = require('lollo_lorry_station/reloaded')
            -- reloaded.showState(state)
            if name == 'select' then
                -- there is no way to know that I have selected one of my streetside stations
                print('LOLLO lorry station attachable caught gui select, id = ', id, ' name = ', name, ' param = ')
                debugPrint(param)
                -- id = 	mainView	 name = 	select	 param = 25278
                xpcall(function()
                    -- with this event, param is the selected item id
                    local stationGroup = game.interface.getEntity(param)
                    if type(stationGroup) ~= 'table' or stationGroup.type ~= 'STATION_GROUP' or
                        type(stationGroup.position) ~= 'table' then
                        return
                    end

                    local stationId = false
                    local stationPosition = {}
                    local allStations = game.interface.getEntities(
                                            {
                            pos = stationGroup.position,
                            radius = 0
                        }, {
                            type = 'STATION',
                            includeData = true
                        })
                    -- print('LOLLO allStations = ')
                    -- debugPrint(allStations)
                    -- local sampleAllStations = {
                    --   [27353] = {
                    --     cargo = true,
                    --     carriers = { ROAD = true },
                    --     id = 27353,
                    --     name = 'Park Road',
                    --     position = { 569.74090576172, -3373.41796875, 15.128763198853 },
                    --     stationGroup = 27364,
                    --     town = 18738,
                    --     type = 'STATION'
                    --   }
                    -- }

                    -- neither the station nor the edge contain any useful information
                    -- to find out if I am dealing with my own station or not.
                    -- However, I can find out if I am dealing with a lorry road station.

                    -- getConstructionEntity() is not available in the ui thread, sadly.
                    -- LOLLO NOTE this call returns constructions mostly sorted by distance, but not reliably!
                    -- the game distinguishes constructions, stations and station groups.
                    -- Constructions and stations in a station group are not selected, only the station group itself, which does not contain a lot of data.
                    -- This is why we need this loop.
                    for _, staId in pairs(stationGroup.stations) do
                        for _, sta in pairs(allStations) do
                            if staId == sta.id then
                                if not stationId and sta and sta.cargo and sta.carriers and sta.carriers['ROAD'] then
                                    stationId = sta.id
                                    stationPosition = sta.position
                                else
                                    break
                                end
                            end
                        end
                    end

                    if stationId then
                        game.interface.sendScriptEvent('__lolloLorryStation2Event__', 'select', {
                            id = stationId,
                            position = stationPosition,
                            stationGroupId = stationGroup.id
                        })
                    end
                end, _myErrorHandler)
            elseif name == 'builder.apply' then
                -- when U add a streetside station, U don't get any ids. The streetside station is an edge object,
                -- it has no id (for now at least), so the edge id seems more interesting.
                -- U can try to figure it out here, but it's probably easier in the select handler
                -- print('LOLLO gui builder.apply caught, id = ', id, ' name = ', name, ' param = ')
                -- debugPrint(param)
                -- you cannot check the types coz they contain userdata, so use xpcall
                xpcall(function()
                    print('LOLLO id = ')
                    debugPrint(id)
                    print('LOLLO name = ')
                    debugPrint(name)
                    print('LOLLO param = ')
                    debugPrint(param)
                    -- local allModels = api.res.modelRep.getAll()
                    -- print('LOLLO allModels = ')
                    -- debugPrint(allModels)
                    local stationModelId = api.res.modelRep.find(_constants.stationFileName)

                    -- print('LOLLO model instance =')
                    -- debugPrint(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance)
                    -- print('LOLLO transf0 = ')
                    -- debugPrint(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf0)
                    -- print('LOLLO transf = ')
                    -- debugPrint(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf)

                    if not param or not param.proposal or not param.proposal.proposal or
                        not param.proposal.proposal.edgeObjectsToAdd or not param.proposal.proposal.edgeObjectsToAdd[1] or
                        not param.proposal.proposal.edgeObjectsToAdd[1].modelInstance or
                        param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.modelId ~= stationModelId then
                        return
                    end

                    -- local entity = game.interface.getEntity(param.result[1]) -- the newly built station
                    -- if type(entity) ~= 'table' or entity.type ~= 'CONSTRUCTION' or type(entity.position) ~= 'table' then return end
                    print('LOLLO lorry station built!')
                    -- debugPrint(param)
                    -- LOLLO NOTE I could do some complex estimations with param.data.entity2tn
                    -- better would be to use result, but it is empty after plopping a streetside station.
                    -- I have notified UG of this bug.
                    game.interface.sendScriptEvent('__lolloLorryStation2Event__', 'built', {
                        entity2tn = param.data.entity2tn,
                        transfStr = tostring(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf)
                    })
                end, _myErrorHandler)
                -- elseif state.isShowAllEvents then
            else
                -- print('LOLLO guiHandleEvent caught the following:')
                -- print('LOLLO id =', id)
                -- print('LOLLO name =', name)
                -- print('LOLLO param =')
                -- debugPrint(param)
            end

            --[[             xpcall(
                function()
                    print('one')
                    local out = io.popen('find /v '' > con', 'w')
                    print('out = ')
                    debugPrint(out)
                    debugPrint(table.unpack(out))
                    print('two')
                    out:write('three' .. '\r\n') --\r because windows
                    print('four')
                    out:flush()
                    print('five')
                end,
                _myErrorHandler
            ) ]]

            --[[ print('- io = ')
            debugPrint(io)

            print('-- global variables = ')
            for key, value in pairs(_G) do
                print(key, value)
                -- if key ~= 'package' and key ~= '_G' then
                --     debugPrint(value)
                -- else
                --     print('data too long, skipped')
                -- end
            end ]]
            -- print('-- sol = ')
            -- debugPrint(sol)
            -- print('-- ug = ')
            -- debugPrint(ug)

            --[[ xpcall(
                function()
                    print(' -- begin')
                    local one = ug.BaseEdge.new()
                    debugPrint(one)
                    print(' -- end')
                end,
                _myErrorHandler
            ) ]]

            --[[ xpcall(
                function()
                    print(' -- _ =')
                    debugPrint(_G._)
                end,
                _myErrorHandler
            ) ]]

            --[[ xpcall(
                function()
                    print(' -- begin')
                    debugPrint('LOLLO')
                    print(' -- end')
                end,
                _myErrorHandler
            ) ]]

            --[[ xpcall(
                function()
                    print(' -- begin')
                    debugPrint(ug)
                    print(' -- end')
                end,
                _myErrorHandler
            ) ]]

            -- -- print('-- package = ')
            -- -- debugPrint(package) --this hangs
            -- print('-- getmetatable = ')
            -- debugPrint(getmetatable(''))
            -- print('-- io = ')
            -- debugPrint(io)

            -- print('-- game = ')
            -- debugPrint(game)

            -- _G.lollo = true
        end,
        update = function()
        end,
        guiUpdate = function()
        end,
        save = function()
            if not state then
                state = {}
            end
            if not state.isShowAllEvents then
                state.isShowAllEvents = false
            end
            return state
        end,
        load = function(data)
            if data then
                state.isShowAllEvents = data.isShowAllEvents or false
            end
            -- if state ~= nil then
            --     print('LOLLO state = ')
            --     debugPrint(state)
            -- end
            return state
        end
    }
end
