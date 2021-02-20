local arrayUtils = require('lollo_lorry_station.arrayUtils')
local edgeUtils = require('lollo_lorry_station.edgeUtils')
local moduleHelpers = require('lollo_lorry_station.moduleHelpers')
local streetUtils = require('lollo_lorry_station.streetUtils')
local stringUtils = require('lollo_lorry_station.stringUtils')
local transfUtils = require('lollo_lorry_station.transfUtils')

-- LOLLO TODO try and get rid of all game. dependencies
local _eventId = '__lolloLorryStationEvent__'

local function _isBuildingConstructionWithFileName(param, fileName)
    local toAdd =
        type(param) == 'table' and type(param.proposal) == 'userdata' and type(param.proposal.toAdd) == 'userdata' and
        param.proposal.toAdd

    if toAdd and #toAdd > 0 then
        for i = 1, #toAdd do
            if toAdd[i].fileName == fileName then
                return true
            else
                print('toAdd[i].fileName =') debugPrint(toAdd[i].fileName) -- LOLLO TODO remove after testing
            end
        end
    end

    return false
end

local function _isBuildingLorryBayWithEdges(param)
    return _isBuildingConstructionWithFileName(param, 'station/street/lollo_lorry_bay_with_edges.con')
end

local function _isBuildingSimpleLorryBay(param)
    return _isBuildingConstructionWithFileName(param, 'station/road/lollo_small_cargo.mdl')
end

local function _myErrorHandler(err)
    print('lollo lorry station ERROR: ', err)
end

local function _replaceStationWithCon(oldEdgeId, waypointId)
    -- print('oldConstructionId =', oldConstructionId)
    print('_replaceStationWithCon starting, oldConstructionId =', oldEdgeId or 'NIL', 'waypointId =', waypointId or 'NIL')
    if not(edgeUtils.isValidAndExistingId(oldEdgeId)) or not(edgeUtils.isValidAndExistingId(waypointId)) then return end

    local baseEdge = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE)
    local baseEdgeStreet = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
    if not(baseEdge) or not(baseEdgeStreet) then return end

    local node0 = api.engine.getComponent(baseEdge.node0, api.type.ComponentType.BASE_NODE)
    local node1 = api.engine.getComponent(baseEdge.node1, api.type.ComponentType.BASE_NODE)
    if not(node0) or not(node1) then return end

    print('baseEdge =') debugPrint(baseEdge)
    print('baseEdgeStreet =') debugPrint(baseEdgeStreet)
    print('node0 =') debugPrint(node0)
    print('node1 =') debugPrint(node1)

    local waypointTransf = edgeUtils.getObjectTransf(waypointId)
    print('waypointTransf =') debugPrint(waypointTransf)

    local newConstruction = api.type.SimpleProposal.ConstructionEntity.new()
    newConstruction.fileName = 'station/street/lollo_lorry_bay_with_edges.con'
    -- cannot clone this userdata dynamically, coz it won't take pairs and ipairs
    -- local defaultParams = moduleHelpers.getParams()
    local allStreetData = streetUtils.getGlobalStreetData(
        streetUtils.getStreetDataFilters().STOCK_AND_MODS
    )
    local _getStreetTypeInMyList = function()
        local streetTypeInMyList = baseEdgeStreet.streetType -- initialise
        local oldEdgeFileName = api.res.streetTypeRep.getFileName(baseEdgeStreet.streetType)
        print('oldEdgeFileName =', oldEdgeFileName or 'NIL')
        if not(stringUtils.isNullOrEmptyString(oldEdgeFileName)) then
            local count = 0
            for _, value in pairs(allStreetData) do
                count = count + 1
                -- if value.fileName == oldEdgeFileName then
                if stringUtils.stringEndsWith(oldEdgeFileName, value.fileName) then
                    streetTypeInMyList = count
                    print('found street type =', count, 'fileName =', oldEdgeFileName)
                    break
                end
            end
        end

        return streetTypeInMyList
    end
    -- print('allStreetData =') debugPrint(allStreetData)
    newConstruction.params = {
        -- extra params, not accessible to the user
        baseEdge = {
            node0 = baseEdge.node0,
            node1 = baseEdge.node1,
            position0 = {
                x = node0.position.x,
                y = node0.position.y,
                z = node0.position.z,
            },
            position1 = {
                x = node1.position.x,
                y = node1.position.y,
                z = node1.position.z,
            },
            tangent0 = {
                x = baseEdge.tangent0.x,
                y = baseEdge.tangent0.y,
                z = baseEdge.tangent0.z,
            },
            tangent1 = {
                x = baseEdge.tangent1.x,
                y = baseEdge.tangent1.y,
                z = baseEdge.tangent1.z,
            },
            type = baseEdge.type,
            typeIndex = baseEdge.typeIndex,
        },
        -- busLane = baseEdgeStreet.hasBus, -- useless
        inverseMainTransf = transfUtils.getInverseTransf(waypointTransf),
        mainTransf = waypointTransf,
        midPoint = edgeUtils.getNodeBetweenByPercentageShift(oldEdgeId),
        seed = 123,
        -- normal params, accessible to the user
        direction = 0,
        isStoreCargoOnPavement = 1,
        streetType_ = _getStreetTypeInMyList(),
        tramTrack = baseEdgeStreet.tramTrackType, -- 0,
    }
    -- LOLLO TODO you can simply duplicate the waypoint transf as userdata, this is merely to illustrate how to handle this.
    newConstruction.transf = api.type.Mat4f.new(
        api.type.Vec4f.new(waypointTransf[1], waypointTransf[2], waypointTransf[3], waypointTransf[4]),
        api.type.Vec4f.new(waypointTransf[5], waypointTransf[6], waypointTransf[7], waypointTransf[8]),
        api.type.Vec4f.new(waypointTransf[9], waypointTransf[10], waypointTransf[11], waypointTransf[12]),
        api.type.Vec4f.new(waypointTransf[13], waypointTransf[14], waypointTransf[15], waypointTransf[16])
    )
    newConstruction.name = 'LOLLO snapping lorry bay'
    newConstruction.playerEntity = api.engine.util.getPlayer()

    local proposal = api.type.SimpleProposal.new()
    proposal.constructionsToAdd[1] = newConstruction
    -- LOLLO NOTE different tables are handled differently.
    -- This one requires this system, UG says they will document it or amend it.
    proposal.streetProposal.edgesToRemove[#proposal.streetProposal.edgesToRemove+1] = oldEdgeId
    -- remove edge objects
    if baseEdge.objects then
        for eo = 1, #baseEdge.objects do
            proposal.streetProposal.edgeObjectsToRemove[#proposal.streetProposal.edgeObjectsToRemove+1] = baseEdge.objects[eo][1]
        end
    end
    -- remove edge nodes if they are not connected to anything else
    if #edgeUtils.getConnectedEdgeIds({baseEdge.node0}) < 2 then
        proposal.streetProposal.nodesToRemove[#proposal.streetProposal.nodesToRemove+1] = baseEdge.node0
    end
    if #edgeUtils.getConnectedEdgeIds({baseEdge.node1}) < 2 then
        proposal.streetProposal.nodesToRemove[#proposal.streetProposal.nodesToRemove+1] = baseEdge.node1
    end

    print('proposal =') debugPrint(proposal)

    local context = api.type.Context:new()
    -- context.checkTerrainAlignment = false -- true gives smoother z, default is false
    -- context.cleanupStreetGraph = false -- default is false
    -- context.gatherBuildings = false -- default is false
    -- context.gatherFields = true -- default is true
    context.player = api.engine.util.getPlayer()

	api.cmd.sendCommand(
        api.cmd.make.buildProposal(proposal, context, false), -- the 3rd param is "ignore errors"
        function(result, success)
            print('command callback firing for _replaceStationWithCon, success =', success)
	    end
    )
end

-- local function _replaceStationWithSnappyCopy(oldConstructionId)
--     -- print('oldConstructionId =', oldConstructionId)
--     if type(oldConstructionId) ~= 'number' or oldConstructionId < 0 then return end

--     local oldConstruction = api.engine.getComponent(oldConstructionId, api.type.ComponentType.CONSTRUCTION)
--     -- print('oldConstruction =')
--     -- debugPrint(oldConstruction)
--     if not(oldConstruction)
--     or not(oldConstruction.params)
--     or oldConstruction.params.snapNodes == 1
--     or oldConstruction.fileName ~= 'station/street/lollo_lorry_bay_with_edges.con' then return end

--     local newConstruction = api.type.SimpleProposal.ConstructionEntity.new()
--     newConstruction.fileName = oldConstruction.fileName
--     -- cannot clone this userdata dynamically, coz it won't take pairs and ipairs
--     newConstruction.params = {
--         streetType_ = oldConstruction.params.streetType_,
--         isStoreCargoOnPavement = oldConstruction.params.isStoreCargoOnPavement,
--         direction = oldConstruction.params.direction,
--         snapNodes = 1,
--         tramTrack = oldConstruction.params.tramTrack,
--         extraLength = oldConstruction.params.extraLength,
--         seed = oldConstruction.params.seed + 1,
--     }
--     newConstruction.transf = oldConstruction.transf
--     -- some dummy name, it will be overwritten if I bulldoze before building anew
--     newConstruction.name = 'LOLLO snapping lorry bay'
--     newConstruction.playerEntity = api.engine.util.getPlayer()

--     local proposal = api.type.SimpleProposal.new()
--     proposal.constructionsToAdd[1] = newConstruction
--     -- LOLLO NOTE different tables are handled differently.
--     -- This one requires this system, UG says they will document it or amend it.
--     proposal.constructionsToRemove = { oldConstructionId }
--     -- proposal.constructionsToRemove[1] = oldConstructionId -- fails to add
--     -- proposal.constructionsToRemove:add(oldConstructionId) -- fails to add
--     -- proposal.old2new = { -- expected number, received table
--     --     { oldConstructionId, 1 }
--     -- }
--     -- proposal.old2new = {
--     --     oldConstructionId, 1
--     -- }
--     -- proposal.old2new = {
--     --     oldConstructionId,
--     -- }

--     -- if I bulldoze here, the station will inherit the old name
--     -- game.interface.bulldoze(oldConstructionId)

--     local callback = function(res, success)
--         -- print('LOLLO _buildStation res = ')
-- 		-- debugPrint(res)
--         --for _, v in pairs(res.entities) do print(v) end
--         -- print('LOLLO _buildStation success = ')
--         -- debugPrint(success)
--         -- if success then
--             -- if I bulldoze here, the station will get the new name
--         -- end
-- 	end

--     local context = api.type.Context:new()
--     context.checkTerrainAlignment = false -- true gives smoother z, default is false
--     context.cleanupStreetGraph = false -- default is false
--     context.gatherBuildings = false -- default is false
--     context.gatherFields = true -- default is true
--     context.player = api.engine.util.getPlayer()

-- 	local cmd = api.cmd.make.buildProposal(proposal, context, true) -- the 3rd param is "ignore errors"
-- 	api.cmd.sendCommand(cmd, callback)
-- end

--[[ local function _replaceStationWithStreetType_(oldConstructionId)
    -- print('oldConstructionId =', oldConstructionId)
    if type(oldConstructionId) ~= 'number' or oldConstructionId < 0 then return end

    local oldConstruction = api.engine.getComponent(oldConstructionId, api.type.ComponentType.CONSTRUCTION)
    -- print('oldConstruction =')
    -- debugPrint(oldConstruction)
    if not(oldConstruction)
    or not(oldConstruction.params)
    or oldConstruction.params.snapNodes == 1
    or oldConstruction.fileName ~= 'station/street/lollo_lorry_bay_with_edges.con' then return end

    local newConstruction = api.type.SimpleProposal.ConstructionEntity.new()
    newConstruction.fileName = oldConstruction.fileName
    -- cannot clone this userdata dynamically, coz it won't take pairs and ipairs
    local newStreetTypeIndex = moduleHelpers.getDefaultStreetTypeIndex(
        streetUtils.getGlobalStreetData(streetUtils.getStreetDataFilters().STOCK_AND_MODS)
    )
    print('newStreetTypeIndex =')
    debugPrint(newStreetTypeIndex)
    newConstruction.params = {
        streetType_ = newStreetTypeIndex,
        isStoreCargoOnPavement = oldConstruction.params.isStoreCargoOnPavement,
        direction = oldConstruction.params.direction,
        snapNodes = 1,
        tramTrack = oldConstruction.params.tramTrack,
        extraLength = oldConstruction.params.extraLength,
        seed = oldConstruction.params.seed + 1,
    }
    newConstruction.transf = oldConstruction.transf
    -- some dummy name, it will be overwritten if I bulldoze before building anew
    newConstruction.name = 'LOLLO snapping lorry bay'
    newConstruction.playerEntity = api.engine.util.getPlayer()

    local proposal = api.type.SimpleProposal.new()
    proposal.constructionsToAdd[1] = newConstruction
    -- LOLLO NOTE different tables are handled differently.
    -- This one requires this system, UG says they will document it or amend it.
    proposal.constructionsToRemove = { oldConstructionId }

    local callback = function(res, success)
	end

    local context = api.type.Context:new()
    context.checkTerrainAlignment = false -- true gives smoother z, default is false
    context.cleanupStreetGraph = false -- default is false
    context.gatherBuildings = false -- default is false
    context.gatherFields = true -- default is true
    context.player = api.engine.util.getPlayer()

	local cmd = api.cmd.make.buildProposal(proposal, context, true) -- the 3rd param is "ignore errors"
	api.cmd.sendCommand(cmd, callback)
end ]]

function data()
    return {
        ini = function()
        end,
        handleEvent = function(src, id, name, args)
            if (id ~= '__lolloLorryStationEvent__') then return end

            -- xpcall(
            --     function()
                    print('handleEvent firing, id =', id or 'NIL', 'name =', name or 'NIL', 'param =') debugPrint(args)
                    -- if type(args) ~= 'table' or type(args.constructionEntityId) ~= 'number' or args.constructionEntityId < 0 then return end
                    if type(args) ~= 'table' then return end

                    -- print('param.constructionEntityId =', param.constructionEntityId or 'NIL')
                    -- if name == 'lorryStationBuilt' then
                        -- _replaceStationWithSnappyCopy(args.constructionEntityId)
                    -- elseif name == 'lorryStationSelected' then
                    --     _replaceStationWithStreetType_(param.constructionEntityId)
                    if name == 'lorrySideStationBuilt' then
                        _replaceStationWithCon(args.edgeId, args.waypointId)
                    end
            --     end,
            --     _myErrorHandler
            -- )
        end,
        guiHandleEvent = function(id, name, args)
            -- LOLLO NOTE param can have different types, even boolean, depending on the event id and name
            -- if id == 'constructionBuilder' and name == 'builder.apply' then
            --     xpcall(
            --         function()
            --             if not args.result or not args.result[1] then
            --                 return
            --             end

            --             if _isBuildingLorryBayWithEdges(args) then
            --                 api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
            --                     string.sub(debug.getinfo(1, 'S').source, 1),
            --                     _eventId,
            --                     'lorryStationBuilt',
            --                     {
            --                         constructionEntityId = args.result[1]
            --                     }
            --                 ))
            --             end
            --         end,
            --         _myErrorHandler
            --     )
            --[[ elseif name == 'select' then
                print('guiHandleEvent firing, id =', id, 'name =', name, 'param =')
                debugPrint(param)

                if type(param) == 'number' then
                    local entity = game.interface.getEntity(param)

                    if (entity and entity.type == "STATION_GROUP") then
                        local allLorryStationConstructions = game.interface.getEntities(
                            {pos = entity.position, radius = 999},
                            {type = "CONSTRUCTION", includeData = true, fileName = "station/street/lollo_lorry_bay_with_edges.con"}
                        )
                        print('allLorryStationConstructions =')
                        debugPrint(allLorryStationConstructions)

                        -- the game distinguishes constructions, stations and station groups.
                        -- Constructions and stations in a station group are not selected, only the station group itself,
                        -- which does not contain a lot of data: this is why we need this loop.
                        -- The API here does not help, the old game.interface is better.

                        -- LOLLO NOTE try this api instead:
                        -- api.engine.system.streetConnectorSystem.getConstructionEntityForStation(stations)
                        for _, staId in ipairs(entity.stations) do
                            for _, con in pairs(allLorryStationConstructions) do
                                if arrayUtils.arrayHasValue(con.stations, staId) then
                                    print('found con =')
                                    debugPrint(con)
                                    if con.id and con.params and con.params.streetType_ then
                                        local allStreetData = streetUtils.getGlobalStreetData(streetUtils.getStreetDataFilters().STOCK_AND_MODS)

                                        print('#allStreetData =', #allStreetData)
                                        if con.params.streetType_ > #allStreetData then
                                            game.interface.sendScriptEvent(
                                                "__lolloLorryStationEvent__",
                                                "lorryStationSelected",
                                                {
                                                    constructionEntityId = con.id,
                                                    constructionParams = con.params
                                                }
                                            )
                                        end
                                    end
                                end
                            end
                        end
                    end
                end ]]
            if id == 'streetTerminalBuilder' and name == 'builder.apply' then
                print('gui handler caught event id =', id or 'NIL', 'name =', name or 'NIL', 'param =') -- debugPrint(args)
                local lastBuiltEdgeId = edgeUtils.getLastBuiltEdgeId(args.data.entity2tn, args.proposal.proposal.addedSegments[1])
                if not(edgeUtils.isValidAndExistingId(lastBuiltEdgeId)) then print('ERROR with lastBuiltEdgeId') return end

                local lastBuiltBaseEdge = api.engine.getComponent(
                    lastBuiltEdgeId,
                    api.type.ComponentType.BASE_EDGE
                )
                if not(lastBuiltBaseEdge) then return end

                -- local _waypointModelId = api.res.modelRep.find('station/road/lollo_small_cargo.mdl')
                local newWaypointId = arrayUtils.getLast(edgeUtils.getEdgeObjectsIdsWithModelId(
                    lastBuiltBaseEdge.objects,
                    api.res.modelRep.find('station/road/lollo_small_cargo.mdl'))
                )
                if not(newWaypointId) then return end

                api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
                    string.sub(debug.getinfo(1, 'S').source, 1),
                    _eventId,
                    'lorrySideStationBuilt',
                    {
                        edgeId = lastBuiltEdgeId,
                        waypointId = newWaypointId,
                    }
                ))
            end
        end,
        update = function()
        end,
        guiUpdate = function()
        end,
        -- save = function()
        --     return allState
        -- end,
        -- load = function(allState)
        -- end
    }
end
