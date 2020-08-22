local arrayUtils = require('lollo_lorry_station/arrayUtils')
local edgeUtils = require('lollo_lorry_station/edgeHelper')
-- local _modConstants = require('lollo_lorry_station/constants')
local stringUtils = require('lollo_lorry_station/stringUtils')

local state = {
    isShowAllEvents = false
}

local _constants = arrayUtils.addProps({
    approxToDeclareSamePosition = 0.1,
    constructionFileName = 'station/street/lollo_lorry_station.con',
    stationFileName = 'station/road/lollo_small_cargo.mdl'
})

local function _buildStation(transf, position, vehicleNodeOffset, edgeEntity)
    local proposal = api.type.SimpleProposal.new()

    print('LOLLO transf =')
    debugPrint(transf)
    print('LOLLO position =')
    debugPrint(position)

    local newConstruction = api.type.SimpleProposal.ConstructionEntity.new()
    newConstruction.fileName = 'station/street/lollo_simple_lorry_bay.con'
    newConstruction.params = {
        edgeEntity = edgeEntity,
        seed = 123e4, -- we need this to avoid dumps
        vehicleNodeOffset = vehicleNodeOffset
    }
    -- print('LOLLO transf =')
    -- debugPrint(transf)
    local transfMatrix = api.type.Mat4f.new(
        api.type.Vec4f.new(transf[1], transf[2], transf[3], transf[4]),
        api.type.Vec4f.new(transf[5], transf[6], transf[7], transf[8]),
        api.type.Vec4f.new(transf[9], transf[10], transf[11], transf[12]),
        api.type.Vec4f.new(transf[13], transf[14], transf[15], transf[16])
        -- api.type.Vec4f.new(position[1], position[2], position[3], transf[16])
    )
    newConstruction.transf = transfMatrix
    newConstruction.name = 'LOLLO simple lorry bay'
    newConstruction.playerEntity = game.interface.getPlayer()
    print('LOLLO game.interface.getPlayer() =')
    debugPrint(game.interface.getPlayer())
    newConstruction.playerEntity = api.engine.util.getPlayer()
    print('LOLLO api.engine.util.getPlayer() =')
    debugPrint(api.engine.util.getPlayer())

    proposal.constructionsToAdd[1] = newConstruction
    print('LOLLO proposal.constructionsToAdd =')
    debugPrint(proposal.constructionsToAdd)

    local callback = function(res, success)
        -- print('LOLLO _buildStation res = ')
		-- debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print('LOLLO _buildStation success = ')
		debugPrint(success)
	end

    local context = api.type.Context:new()
    context.checkTerrainAlignment = true -- true gives smoother z, default is false
    context.cleanupStreetGraph = true -- default is false
    context.gatherBuildings = false -- default is false
    context.gatherFields = true -- default is true
    context.player = api.engine.util.getPlayer()

	local cmd = api.cmd.make.buildProposal(proposal, nil, true)
	api.cmd.sendCommand(cmd, callback)
end

local function _getCloneWoutModulesAndSeed(obj)
    return arrayUtils.cloneOmittingFields(obj, {'modules', 'seed'})
end

local function _getLastBuiltEdge(entity2tn)
    local nodeIds = {}
    for k, _ in pairs(entity2tn) do
        local entity = game.interface.getEntity(k)
        if entity.type == 'BASE_NODE' then nodeIds[#nodeIds+1] = entity.id end
    end
    if #nodeIds ~= 2 then return nil end

    for k, _ in pairs(entity2tn) do
        local entity = game.interface.getEntity(k)
        if entity.type == 'BASE_EDGE'
        and ((entity.node0 == nodeIds[1] and entity.node1 == nodeIds[2])
        or (entity.node0 == nodeIds[2] and entity.node1 == nodeIds[1])) then
            local extraEdgeData = api.engine.getComponent(entity.id, api.type.ComponentType.BASE_EDGE)
            return {
                id = entity.id,
                objects = extraEdgeData.objects
            }
        end
    end

    return nil
end

local function _getTransfFromApiResult(transfStr)
    transfStr = transfStr:gsub('%(%(', '(')
    transfStr = transfStr:gsub('%)%)', ')')
    local results = {}
    for match0 in transfStr:gmatch('%([^(%))]+%)') do
        local noBrackets = match0:gsub('%(', '')
        noBrackets = noBrackets:gsub('%)', '')
        for match1 in noBrackets:gmatch('[%-%.%d]+') do
            results[#results + 1] = tonumber(match1 or '0')
        end
    end
    return results
end

local function _getVehicleNodeOffset(edgeId)
    if not(edgeId) then return 0 end

    local edgeEntity = game.interface.getEntity(edgeId)
    if edgeEntity and edgeEntity.type == 'BASE_EDGE' and not(stringUtils.isNullOrEmptyString(edgeEntity.streetType)) then
        local streetTypeId = api.res.streetTypeRep.find(edgeEntity.streetType)
        if streetTypeId then
            local streetTypeData = api.res.streetTypeRep.get(streetTypeId)
            if streetTypeData then
                if streetTypeData.laneConfigs and #(streetTypeData.laneConfigs) > 1 then
                    return streetTypeData.laneConfigs[1].width * 0.5
                    + streetTypeData.laneConfigs[2].width * 0.5
                end
            end
        end
    end

    return 0
end

local function _myErrorHandler(err)
    print('ERROR: ', err)
end

local function _replaceEdgeRemovingObject(oldEdgeId, objectToRemoveId, isAddNewObject)
    if not(oldEdgeId) then return end

    if isAddNewObject ~= false then isAddNewObject = true end
    -- make a copy of the edge that owns the station
    local baseEdge = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE)
    local baseEdgeStreet = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
	local newEdge = api.type.SegmentAndEntity.new()
	newEdge.entity = -1
	newEdge.type = 0
    newEdge.comp = baseEdge
    newEdge.playerOwned = {player = api.engine.util.getPlayer()}
    newEdge.streetEdge = baseEdgeStreet

    -- take care of the new edge objects
    local newEdgeCompObjects = api.type.SegmentAndEntity.new().comp.objects
    -- add the new edge object
    if isAddNewObject then
        for i = 1, #newEdge.comp.objects do
            local edgeObject = newEdge.comp.objects[i]
            if edgeObject[1] == objectToRemoveId then
                newEdgeCompObjects[#newEdgeCompObjects + 1] = { -1, edgeObject[2] }
            end
        end
    end
    -- add the old edge objects, except for the one to be replaced
    for i = 1, #newEdge.comp.objects do
        local edgeObject = newEdge.comp.objects[i]
        if edgeObject[1] ~= objectToRemoveId then
            newEdgeCompObjects[#newEdgeCompObjects + 1] = edgeObject
        end
    end
    newEdge.comp.objects = newEdgeCompObjects

    -- make the new object
    local newObject = api.type.SimpleStreetProposal.EdgeObject.new()
    newObject.left = true
    newObject.model = 'street/signal_waypoint.mdl'
    -- I could plop a streetside station, but it would need
    -- streetTerminal = {
    --     cargo = true,
    -- },
    -- and that would automatically delete the cargo paths
    -- newObject.model = 'lollo_models/dsd_road_station3_cargo.mdl'
    newObject.playerEntity = game.interface.getPlayer()
    newObject.oneWay = true
    newObject.param = 0.5
    newObject.edgeEntity = -1
    newObject.name = 'MY Beautiful Signal'

    -- make the proposal
    local proposal = api.type.SimpleProposal.new()
    proposal.streetProposal.edgesToAdd[1] = newEdge
    proposal.streetProposal.edgesToRemove[1] = oldEdgeId
    if isAddNewObject then
        proposal.streetProposal.edgeObjectsToAdd[1] = newObject
    end
    proposal.streetProposal.edgeObjectsToRemove[1] = objectToRemoveId

    local callback = function(res, success)
        -- print('LOLLO _replaceEdgeRemovingObject res = ')
		-- debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print('LOLLO _replaceEdgeRemovingObject success = ')
        debugPrint(success) -- boolean
	end

    local cmd = api.cmd.make.buildProposal(proposal, nil, false)
    api.cmd.sendCommand(cmd, callback)
end


function data()
    return {
        handleEvent = function(src, id, name, args)
            if src == 'guidesystem.lua' then
                return
            end -- also comes with guide system switched off
            -- if state.isShowAllEvents then
            print('LOLLO handleEvent src =', src, ' id =', id, ' name =', name)
            state.isShowAllEvents = true
            -- end
            if (id == '__lolloLorryStation2Event__') then
                print('__lolloLorryStation2Event__ caught')
                print('LOLLO src = ', src, ' id = ', id, ' name = ', name, 'param = ')
                debugPrint(args)

                if name == 'built' then
                    if args and args.edgeId and args.stationId and args.transf then
                        print('LOLLO stationTransf =')
                        debugPrint(args.transf)

                        print('LOLLO stationId =')
                        debugPrint(args.stationId)

                        print('LOLLO edgeId =')
                        debugPrint(args.edgeId)

                        -- destroy the newly built streetside station
                        -- and replace it with a construction containing the same, but with the cargo lanes
                        -- Alternatively, try just adding a cargo area like lollo_cargo_area.mdl.
                        -- Tried, it does not store any cargo.

                        local vehicleNodeOffset = _getVehicleNodeOffset(args.edgeId)
                        -- local edgeEntity = game.interface.getEntity(args.edgeId)

                        -- game.interface.bulldoze(stationId) -- dumps
                        _replaceEdgeRemovingObject(args.edgeId, args.stationId)

                        if vehicleNodeOffset > 0 then
                            -- LOLLO TODO vehicles can never reach the vehicle node in the model,
                            -- the station won't be connected to the road network.
                            -- I tried the splitter too, to no avail.
                            -- _buildStation(args.transf, lastPloppedStation.position, vehicleNodeOffset, edgeEntity)
                        end

                        -- print('LOLLO game.interface.buildConstruction = ')
                        -- debugPrint(game.interface.buildConstruction)
                    end
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
                    -- print('LOLLO id = ')
                    -- debugPrint(id)
                    -- print('LOLLO name = ')
                    -- debugPrint(name)
                    -- print('LOLLO param = ')
                    -- debugPrint(param)
                    local myStationModelId = api.res.modelRep.find(_constants.stationFileName)

                    if not param or not param.proposal or not param.proposal.proposal or
                        not param.proposal.proposal.edgeObjectsToAdd or not param.proposal.proposal.edgeObjectsToAdd[1] or
                        not param.proposal.proposal.edgeObjectsToAdd[1].modelInstance or
                        param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.modelId ~= myStationModelId then
                        return
                    end

                    print('LOLLO lorry station built!')
                    -- LOLLO NOTE I could do some complex estimations with param.data.entity2tn
                    -- better would be to use result, but it is empty after plopping a streetside station.
                    -- I have notified UG of this bug.
                    -- cannot pass entity2tn as it is, pass its useful part only, and no userdata
                    -- print('LOLLO type of param.data.entity2tn = ', type(param.data.entity2tn)) -- userdata
                    local lastBuiltEdge = _getLastBuiltEdge(param.data.entity2tn)
                    if not(lastBuiltEdge) then return end

                    local stationId = nil
                    for i = 1, #lastBuiltEdge.objects do
                        -- debugPrint(game.interface.getEntity(lastBuiltEdge.objects[i][1]))
                        local modelInstanceList = api.engine.getComponent(lastBuiltEdge.objects[i][1], api.type.ComponentType.MODEL_INSTANCE_LIST)
                        -- print('LOLLO model instance list =')
                        -- debugPrint(modelInstanceList)
                        if modelInstanceList
                        and modelInstanceList.fatInstances
                        and modelInstanceList.fatInstances[1]
                        and modelInstanceList.fatInstances[1].modelId == myStationModelId then
                            stationId = lastBuiltEdge.objects[i][1]
                        end
                    end
                    if not(stationId) then return end

                    -- the following all fail coz they expect numers but receive a string
                    -- debugPrint(api.type.Mat4f:col(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf, 1))
                    -- debugPrint(api.type.Mat4f.col(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf, 1))
                    -- debugPrint(api.type.Mat4f:col(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf))
                    -- debugPrint(api.type.Mat4f.col(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf))
                    -- debugPrint(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf:col(1))
                    -- debugPrint(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf:col())
                    -- debugPrint(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf.col(1))
                    -- debugPrint(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf:col())
                    game.interface.sendScriptEvent('__lolloLorryStation2Event__', 'built', {
                        edgeId = lastBuiltEdge.id,
                        stationId = stationId,
                        transf = _getTransfFromApiResult(tostring(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf))
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
