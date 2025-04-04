local _constants = require('lollo_lorry_station.constants')
local arrayUtils = require('lollo_lorry_station.arrayUtils')
local comparisonUtils = require('lollo_lorry_station.comparisonUtils')
local edgeUtils = require('lollo_lorry_station.edgeUtils')
local logger = require('lollo_lorry_station.logger')
local slotHelpers = require('lollo_lorry_station.slotHelpers')
local transfUtils = require('lollo_lorry_station.transfUtils')


local _eventId = '__lolloLorryStationEvent__'
local _eventProperties = {
    lorryStationBuilt = { conName = 'station/street/lollo_lorry_station/lollo_lorry_bay_with_edges.con', eventName = 'lorryStationBuilt' },
    ploppableModularCargoStationBuilt = { conName = 'station/street/lollo_lorry_station/lollo_lorry_bay_with_edges_ploppable.con', eventName = 'ploppableModularCargoStationBuilt' },
    ploppableStreetsideCargoStationBuilt = { conName = nil, eventName = 'ploppableStreetsideCargoStationBuilt' },
    ploppableStreetsidePassengerStationBuilt = { conName = nil, eventName = 'ploppableStreetsidePassengerStationBuilt' },
}

local _guiConstants = {
    _ploppableCargoModelId = false,
    _ploppablePassengersModelId = false,
}

local function _isBuildingConstructionWithFileName(param, fileName)
    local toAdd =
        type(param) == 'table' and type(param.proposal) == 'userdata' and type(param.proposal.toAdd) == 'userdata' and
        param.proposal.toAdd

    if toAdd and #toAdd > 0 then
        for i = 1, #toAdd do
            if toAdd[i].fileName == fileName then
                return true
            end
        end
    end

    return false
end

local function _isBuildingLorryBayWithEdges(param)
    return _isBuildingConstructionWithFileName(param, _eventProperties.lorryStationBuilt.conName)
end

local function _myErrorHandler(err)
    print('lollo lorry station ERROR: ', err)
end

local utils = {
    getEdgeListsFromProposal_UNUSED = function(proposal)
        if not(proposal) or not(proposal.streetProposal)
        or not(proposal.streetProposal.nodesToAdd)
        or #proposal.streetProposal.nodesToAdd ~= 1
        or not(proposal.streetProposal.nodesToAdd[1].comp)
        or not(proposal.streetProposal.edgesToAdd)
        or #proposal.streetProposal.edgesToAdd ~= 2
        then return nil end

        local splitPosXYZ = proposal.streetProposal.nodesToAdd[1].comp.position

        local _getEdgeType = function(baseEdgeType)
            return baseEdgeType == 1 and 'BRIDGE' or (baseEdgeType == 2 and 'TUNNEL' or nil)
        end
        local _getEdgeTypeName = function(baseEdgeType, baseEdgeTypeIndex)
            if baseEdgeType == 1 then -- bridge
                return api.res.bridgeTypeRep.getName(baseEdgeTypeIndex)
            elseif baseEdgeType == 2 then -- tunnel
                return api.res.tunnelTypeRep.getName(baseEdgeTypeIndex)
            else
                return nil
            end
        end
        local _getPosTan = function(edgeIndexBase1, nodeFieldName, tanFieldName)
            local posTan = {{}, {}}
            local nodeId = proposal.streetProposal.edgesToAdd[edgeIndexBase1].comp[nodeFieldName]
            if nodeId < 0 then
                posTan[1] = {splitPosXYZ.x, splitPosXYZ.y, splitPosXYZ.z}
            else
                local node = api.engine.getComponent(nodeId, api.type.ComponentType.BASE_NODE)
                posTan[1] = {node.position.x, node.position.y, node.position.z}
            end

            local tanXYZ = proposal.streetProposal.edgesToAdd[edgeIndexBase1].comp[tanFieldName]
            posTan[2] = {tanXYZ.x, tanXYZ.y, tanXYZ.z}
            return posTan
        end
        local _getHasBus = function (hasBus)
            return hasBus and (({false, true})[hasBus + 1]) or false
        end
        local _getTramTrackType = function(tramTrack)
            return tramTrack and (({'NO', 'YES', 'ELECTRIC'})[tramTrack + 1]) or 'NO'
        end
        local _getStreetType = function(typeIndex)
            return api.res.streetTypeRep.getName(typeIndex)
        end

        local edgeLists = {}

        local _addEdges = function(edgeIndexBase1)
            local edgeToAdd = proposal.streetProposal.edgesToAdd[edgeIndexBase1]
            edgeLists[#edgeLists+1] = {
                alignTerrain = edgeToAdd.comp.type == 0 or edgeToAdd.comp.type == 2, -- only align on ground and in tunnels
                edges = {
                    _getPosTan(edgeIndexBase1, 'node0', 'tangent0'),
                    _getPosTan(edgeIndexBase1, 'node1', 'tangent1'),
                },
                edgeType = _getEdgeType(edgeToAdd.comp.type),
                edgeTypeName = _getEdgeTypeName(edgeToAdd.comp.type, edgeToAdd.comp.typeIndex),
                freeNodes = {edgeIndexBase1 == 1 and 0 or 1},
                -- freeNodes = {0, 1}, -- this crashes and it makes no sense anyway
                params = {
                    hasBus = _getHasBus(edgeToAdd.params.hasBus),
                    -- skipCollision = true, -- LOLLO TODO do we need this?
                    tramTrackType = _getTramTrackType(edgeToAdd.params.tramTrackType),
                    type = _getStreetType(edgeToAdd.params.streetType),
                },
                snapNodes = {edgeIndexBase1 == 1 and 0 or 1}, -- we need this
                -- snapNodes = {}, -- with this, the ugly intersections cannot be fixed with an upgrade
                -- tag2nodes = {},
                type = 'STREET'
            }
        end
        _addEdges(1)
        _addEdges(2)

        return edgeLists
    end,

    getEdgeObjectsFromProposal = function(proposal)
        -- LOLLO TODO check this: for now, we don't use this: it crashes the game,
        -- and it makes no sense to have waypoints or streetside stations inside another station.
        if not(proposal) or not(proposal.streetProposal)
        or not(proposal.streetProposal.nodesToAdd)
        or #proposal.streetProposal.nodesToAdd ~= 1
        or not(proposal.streetProposal.nodesToAdd[1].comp)
        or not(proposal.streetProposal.edgesToAdd)
        or #proposal.streetProposal.edgesToAdd ~= 2
        then return nil end

        local edgeObjects = {}

        local _addObjects = function(edgeIndexBase1)
            local edgeToAdd = proposal.streetProposal.edgesToAdd[edgeIndexBase1]
            local nObjects = #edgeToAdd.comp.objects
            for i = 1, nObjects, 1 do
                local objId = edgeToAdd.comp.objects[i][1]
                local zeroRightOneLeft = edgeToAdd.comp.objects[i][2]
                edgeObjects[#edgeObjects+1] = {
                    edge = edgeIndexBase1 == 1 and 0 or 1,
                    param = 0.5,
                    left = zeroRightOneLeft == 1,
                    model = api.res.modelRep.getName(edgeUtils.getEdgeObjectModelId(objId))
                }
            end
        end
        _addObjects(1)
        _addObjects(2)

        return edgeObjects
    end,

    getWhichEdgeGetsEdgeObjectAfterSplit = function(edgeObjPosition, node0pos, node1pos, nodeBetween)
        local result = {
            assignToSide = nil,
        }
        -- logger.print('LOLLO attempting to place edge object with position =')
        -- logger.debugPrint(edgeObjPosition)
        -- print('wholeEdge.node0pos =')
        -- debugPrint(node0pos)
        -- print('nodeBetween.position =')
        -- debugPrint(nodeBetween.position)
        -- print('nodeBetween.tangent =')
        -- debugPrint(nodeBetween.tangent)
        -- print('wholeEdge.node1pos =')
        -- debugPrint(node1pos)

        local edgeObjPosition_assignTo = nil
        local node0_assignTo = nil
        local node1_assignTo = nil
        -- at nodeBetween, I can draw the normal to the road:
        -- y = a + bx
        -- the angle is alpha = atan2(nodeBetween.tangent.y, nodeBetween.tangent.x) + PI / 2
        -- so b = math.tan(alpha)
        -- a = y - bx
        -- so a = nodeBetween.position.y - b * nodeBetween.position.x
        -- points under this line will go one way, the others the other way
        local alpha = math.atan2(nodeBetween.tangent.y, nodeBetween.tangent.x) + math.pi * 0.5
        local b = math.tan(alpha)
        if math.abs(b) < 1e+06 then
            local a = nodeBetween.position.y - b * nodeBetween.position.x
            if a + b * edgeObjPosition[1] > edgeObjPosition[2] then -- edgeObj is below the line
                edgeObjPosition_assignTo = 0
            else
                edgeObjPosition_assignTo = 1
            end
            if a + b * node0pos[1] > node0pos[2] then -- wholeEdge.node0pos is below the line
                node0_assignTo = 0
            else
                node0_assignTo = 1
            end
            if a + b * node1pos[1] > node1pos[2] then -- wholeEdge.node1pos is below the line
                node1_assignTo = 0
            else
                node1_assignTo = 1
            end
        -- if b grows too much, I lose precision, so I approximate it with the y axis
        else
            -- print('alpha =', alpha, 'b =', b)
            if edgeObjPosition[1] > nodeBetween.position.x then
                edgeObjPosition_assignTo = 0
            else
                edgeObjPosition_assignTo = 1
            end
            if node0pos[1] > nodeBetween.position.x then
                node0_assignTo = 0
            else
                node0_assignTo = 1
            end
            if node1pos[1] > nodeBetween.position.x then
                node1_assignTo = 0
            else
                node1_assignTo = 1
            end
        end

        if edgeObjPosition_assignTo == node0_assignTo then
            result.assignToSide = 0
        elseif edgeObjPosition_assignTo == node1_assignTo then
            result.assignToSide = 1
        end

        -- print('LOLLO assignment =')
        -- debugPrint(result)
        return result
    end,

    getPosTanX2Reversed = function(posTanX2)
        if type(posTanX2) ~= 'table' then return posTanX2 end

        local swap = posTanX2[1]
        posTanX2[1] = posTanX2[2]
        posTanX2[2] = swap
        for ii = 1, 2 do
            for iii = 1, 3 do
                posTanX2[ii][2][iii] = -posTanX2[ii][2][iii]
            end
        end

        return posTanX2
    end
}

local actions = {
    buildStation_UNUSED = function(oldProposal, stationTransf)
        if not(oldProposal) or not(stationTransf) then return end

        local edgeLists = utils.getEdgeListsFromProposal_UNUSED(oldProposal) or {}
        -- local edgeObjects = utils.getEdgeObjectsFromProposal(oldProposal)
        logger.print('edgeLists before transf =') logger.debugPrint(edgeLists)

        -- local reversedEdgeLists = {edgeLists[2], edgeLists[1]}
        -- for _, edgeList in pairs(reversedEdgeLists) do
        --     edgeList.edges = utils.getPosTanX2Reversed(edgeList.edges)
        --     if edgeList.freeNodes[1] == 0 then edgeList.freeNodes[1] = 1
        --     elseif edgeList.freeNodes[1] == 1 then edgeList.freeNodes[1] = 0
        --     end
        --     if edgeList.snapNodes[1] == 0 then edgeList.snapNodes[1] = 1
        --     elseif edgeList.snapNodes[1] == 1 then edgeList.snapNodes[1] = 0
        --     end
        -- end
        -- logger.print('reversedEdgeLists =') logger.debugPrint(reversedEdgeLists)
        -- edgeLists = reversedEdgeLists

        local newCon = api.type.SimpleProposal.ConstructionEntity.new()
        newCon.fileName = _eventProperties.ploppableModularCargoStationBuilt.conName

        local _mainTransf = arrayUtils.cloneDeepOmittingFields(stationTransf)
        local _inverseMainTransf = transfUtils.getInverseTransf(_mainTransf)

        for _, edgeList in pairs(edgeLists) do
            edgeList.edges = transfUtils.getPosTanX2Transformed(edgeList.edges, _inverseMainTransf)
        end
        logger.print('edgeLists after transf =') logger.debugPrint(edgeLists)

        local newConParams = {
            -- it is not too correct to pass two parameters, one of which can be inferred from the other. However, performance matters more.
            edgeLists = edgeLists,
            -- edgeObjects = edgeObjects,
            inverseMainTransf = _inverseMainTransf,
            isStoreCargoOnPavement = 1,
            mainTransf = _mainTransf,
            modules = {
                [slotHelpers.mangleId(0, 0, _constants.idBases.storeCargoOnPavementSlotId)] = {
                    metadata = {
                      cargo = true,
                    },
                    name = _constants.storeCargoOnPavementModuleName,
                    updateScript = {
                      fileName = "",
                      params = { },
                    },
                    variant = 0,
                  }
            },
            -- seed = 123,
            seed = math.abs(math.ceil(stationTransf[13] * 1000)),
        }
        -- clone these params before assigning them to newCon.params, there is magic going on
        local paramsBak = arrayUtils.cloneDeepOmittingFields(newConParams, {'seed'})
        newCon.params = newConParams

        newCon.transf = api.type.Mat4f.new(
            api.type.Vec4f.new(stationTransf[1], stationTransf[2], stationTransf[3], stationTransf[4]),
            api.type.Vec4f.new(stationTransf[5], stationTransf[6], stationTransf[7], stationTransf[8]),
            api.type.Vec4f.new(stationTransf[9], stationTransf[10], stationTransf[11], stationTransf[12]),
            api.type.Vec4f.new(stationTransf[13], stationTransf[14], stationTransf[15], stationTransf[16])
        )
        newCon.name = _('NewStationName') -- LOLLO TODO see if the name can be assigned automatically, as it should
        newCon.playerEntity = api.engine.util.getPlayer()

        local newProposal = api.type.SimpleProposal.new()
        newProposal.constructionsToAdd[1] = newCon
        newProposal.streetProposal.edgeObjectsToRemove = oldProposal.streetProposal.edgeObjectsToRemove
        newProposal.streetProposal.edgesToRemove = oldProposal.streetProposal.edgesToRemove
        -- also remove those nodes, which have remained alone
        local baseEdge = api.engine.getComponent(oldProposal.streetProposal.edgesToRemove[1], api.type.ComponentType.BASE_EDGE)
        local map = api.engine.system.streetSystem.getNode2StreetEdgeMap()
        for _, fieldName in pairs({'node0', 'node1'}) do
            if #map[baseEdge[fieldName]] < 2 then
                newProposal.streetProposal.nodesToRemove[#newProposal.streetProposal.nodesToRemove+1] = baseEdge[fieldName]
            end
        end

        local context = api.type.Context:new()
        -- context.checkTerrainAlignment = true
        -- context.cleanupStreetGraph = true -- default is false, useless
        -- context.gatherBuildings = false -- default is false
        -- context.gatherFields = true -- default is true
        context.player = api.engine.util.getPlayer()

        api.cmd.sendCommand(
            api.cmd.make.buildProposal(newProposal, context, true), -- the 3rd param is "ignore errors"; wrong proposals will be discarded anyway
            function(result, success)
                logger.print('buildStation callback, success =', success, ' and result =')
                -- logger.debugPrint(result)
                if success then
                    -- logger.print('station proposal data = ', result.resultProposalData) -- userdata
                    -- logger.print('station entities = ', result.resultEntities) -- userdata
                    local stationId = result.resultEntities[1]
                    logger.print('buildStation succeeded, stationConstructionId = ', stationId)
                    -- LOLLO NOTE this is an ugly bodge because it uses the old game.interface.
                    -- Without this, we get ugly intersections, never mind how I arrange freeNodes and snapNodes.
                    -- Upgrading the edge attached to the construction fixes them, and we don't want to do it by hand.
                    -- Note that, by hand or not, the upgrade will screw up the looks of smooth bends.
                    -- LOLLO TODO test this: if we use this bodge and place several stations quickly in adjoining edges,
                    -- there can be a weird crash. It only happened once.
                    -- To avoid this, you could try destroying and rebuilding once again, with the same parameters.
                    if result.resultEntities[1] and game.interface.upgradeConstruction then
                        collectgarbage() -- LOLLO TODO this is a stab in the dark to try and avoid crashes in the following
                        game.interface.upgradeConstruction(
                            stationId,
                            _eventProperties.ploppableModularCargoStationBuilt.conName,
                            paramsBak
                        )
                    end
                end
            end
        )
    end,

    getSplitEdgeProposal = function(wholeEdgeId, nodeBetween, objectIdToRemove)
        if not(edgeUtils.isValidAndExistingId(wholeEdgeId)) or type(nodeBetween) ~= 'table' then return end

        local oldBaseEdge = api.engine.getComponent(wholeEdgeId, api.type.ComponentType.BASE_EDGE)
        local oldBaseEdgeStreet = api.engine.getComponent(wholeEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
        -- save a crash when a modded road underwent a breaking change, so it has no oldEdgeStreet
        if oldBaseEdge == nil or oldBaseEdgeStreet == nil then return end

        local node0 = api.engine.getComponent(oldBaseEdge.node0, api.type.ComponentType.BASE_NODE)
        local node1 = api.engine.getComponent(oldBaseEdge.node1, api.type.ComponentType.BASE_NODE)
        if node0 == nil or node1 == nil then return end

        if not(comparisonUtils.isXYZsSame(nodeBetween.refPosition0, node0.position)) and not(comparisonUtils.isXYZsSame(nodeBetween.refPosition0, node1.position)) then
            print('WARNING: splitEdge cannot find the nodes')
        end
        local isNodeBetweenOrientatedLikeMyEdge = comparisonUtils.isXYZsSame(nodeBetween.refPosition0, node0.position)
        local distance0 = isNodeBetweenOrientatedLikeMyEdge and nodeBetween.refDistance0 or nodeBetween.refDistance1
        local distance1 = isNodeBetweenOrientatedLikeMyEdge and nodeBetween.refDistance1 or nodeBetween.refDistance0
        local tanSign = isNodeBetweenOrientatedLikeMyEdge and 1 or -1

        local oldTan0Length = isNodeBetweenOrientatedLikeMyEdge and transfUtils.getVectorLength(oldBaseEdge.tangent0) or transfUtils.getVectorLength(oldBaseEdge.tangent1)
        local oldTan1Length = isNodeBetweenOrientatedLikeMyEdge and transfUtils.getVectorLength(oldBaseEdge.tangent1) or transfUtils.getVectorLength(oldBaseEdge.tangent0)

        local playerOwned = api.type.PlayerOwned.new()
        playerOwned.player = api.engine.util.getPlayer()

        local newNodeBetween = api.type.NodeAndEntity.new()
        newNodeBetween.entity = -3
        newNodeBetween.comp.position = api.type.Vec3f.new(nodeBetween.position.x, nodeBetween.position.y, nodeBetween.position.z)

        local newEdge0 = api.type.SegmentAndEntity.new()
        newEdge0.entity = -1
        newEdge0.type = 0 -- ROAD
        newEdge0.comp.node0 = oldBaseEdge.node0
        newEdge0.comp.node1 = -3
        newEdge0.comp.tangent0 = api.type.Vec3f.new(
            oldBaseEdge.tangent0.x * distance0 / oldTan0Length,
            oldBaseEdge.tangent0.y * distance0 / oldTan0Length,
            oldBaseEdge.tangent0.z * distance0 / oldTan0Length
        )
        newEdge0.comp.tangent1 = api.type.Vec3f.new(
            nodeBetween.tangent.x * distance0 * tanSign,
            nodeBetween.tangent.y * distance0 * tanSign,
            nodeBetween.tangent.z * distance0 * tanSign
        )
        newEdge0.comp.type = oldBaseEdge.type -- respect bridge or tunnel
        newEdge0.comp.typeIndex = oldBaseEdge.typeIndex -- respect bridge or tunnel type
        newEdge0.playerOwned = playerOwned
        newEdge0.streetEdge = oldBaseEdgeStreet

        local newEdge1 = api.type.SegmentAndEntity.new()
        newEdge1.entity = -2
        newEdge1.type = 0 -- ROAD
        newEdge1.comp.node0 = -3
        newEdge1.comp.node1 = oldBaseEdge.node1
        newEdge1.comp.tangent0 = api.type.Vec3f.new(
            nodeBetween.tangent.x * distance1 * tanSign,
            nodeBetween.tangent.y * distance1 * tanSign,
            nodeBetween.tangent.z * distance1 * tanSign
        )
        newEdge1.comp.tangent1 = api.type.Vec3f.new(
            oldBaseEdge.tangent1.x * distance1 / oldTan1Length,
            oldBaseEdge.tangent1.y * distance1 / oldTan1Length,
            oldBaseEdge.tangent1.z * distance1 / oldTan1Length
        )
        newEdge1.comp.type = oldBaseEdge.type
        newEdge1.comp.typeIndex = oldBaseEdge.typeIndex
        newEdge1.playerOwned = playerOwned
        newEdge1.streetEdge = oldBaseEdgeStreet

        if type(oldBaseEdge.objects) == 'table' then
            -- local edge0StationGroups = {}
            -- local edge1StationGroups = {}
            local edge0Objects = {}
            local edge1Objects = {}
            for _, edgeObj in pairs(oldBaseEdge.objects) do
                if edgeObj[1] ~= objectIdToRemove then
                    local edgeObjPosition = edgeUtils.getObjectPosition(edgeObj[1])
                    -- logger.print('edge object position: old and new way')
                    -- logger.debugPrint(edgeObjPositionOld)
                    -- logger.debugPrint(edgeObjPosition)
                    if type(edgeObjPosition) ~= 'table' then return end -- change nothing and leave
                    local assignment = utils.getWhichEdgeGetsEdgeObjectAfterSplit(
                        edgeObjPosition,
                        {node0.position.x, node0.position.y, node0.position.z},
                        {node1.position.x, node1.position.y, node1.position.z},
                        nodeBetween
                    )
                    if assignment.assignToSide == 0 then
                        -- LOLLO NOTE if we skip this check,
                        -- one can split a road between left and right terminals of a streetside staion
                        -- and add more terminals on the new segments.
                        -- local stationGroupId = api.engine.system.stationGroupSystem.getStationGroup(edgeObj[1])
                        -- if arrayUtils.arrayHasValue(edge1StationGroups, stationGroupId) then return end -- don't split station groups
                        -- if edgeUtils.isValidId(stationGroupId) then table.insert(edge0StationGroups, stationGroupId) end
                        table.insert(edge0Objects, { edgeObj[1], edgeObj[2] })
                    elseif assignment.assignToSide == 1 then
                        -- local stationGroupId = api.engine.system.stationGroupSystem.getStationGroup(edgeObj[1])
                        -- if arrayUtils.arrayHasValue(edge0StationGroups, stationGroupId) then return end -- don't split station groups
                        -- if edgeUtils.isValidId(stationGroupId) then table.insert(edge1StationGroups, stationGroupId) end
                        table.insert(edge1Objects, { edgeObj[1], edgeObj[2] })
                    else
                        -- logger.print('don\'t change anything and leave')
                        -- logger.print('LOLLO error, assignment.assignToSide =', assignment.assignToSide)
                        return -- change nothing and leave
                    end
                end
            end
            newEdge0.comp.objects = edge0Objects -- LOLLO NOTE cannot insert directly into edge0.comp.objects
            newEdge1.comp.objects = edge1Objects
        end

        local proposal = api.type.SimpleProposal.new()
        proposal.streetProposal.edgeObjectsToRemove[#proposal.streetProposal.edgeObjectsToRemove+1] = objectIdToRemove
        proposal.streetProposal.edgesToAdd[1] = newEdge0
        proposal.streetProposal.edgesToAdd[2] = newEdge1
        proposal.streetProposal.edgesToRemove[1] = wholeEdgeId
        proposal.streetProposal.nodesToAdd[1] = newNodeBetween

        local context = api.type.Context:new()
        -- context.checkTerrainAlignment = false -- default is false, true gives smoother Z
        -- context.cleanupStreetGraph = true -- default is false
        -- context.gatherBuildings = true  -- default is false
        -- context.gatherFields = true -- default is true
        context.player = api.engine.util.getPlayer() -- default is -1

        -- logger.print('context =') logger.debugPrint(context)
        local expectedResult = api.engine.util.proposal.makeProposalData(proposal, context)
        if expectedResult.errorState.critical then
            logger.print('expectedResult =') logger.debugPrint(expectedResult)
            return nil
        end

        logger.print('proposal =') logger.debugPrint(proposal)
        return proposal

        -- api.cmd.sendCommand(
        --     api.cmd.make.buildProposal(proposal, context, true), -- the 3rd param is "ignore errors"; wrong proposals will be discarded anyway
        --     function(result, success)
        --         -- logger.print('LOLLO street splitter callback returned result = ')
        --         -- logger.debugPrint(result)
        --         -- logger.print('LOLLO street splitter callback returned success = ', success)
        --         if not(success) then
        --             logger.print('Warning: streetTuning.splitEdge failed, proposal = ') logger.debugPrint(proposal)
        --         end
        --     end
        -- )
    end,

    replaceStationWithSnappyCopy = function(oldConstructionId)
        -- rebuild the station with the same params but snappy, to prevent pointless internal conflicts
        -- that will prevent changing properties
        logger.print('replaceStationWithSnappyCopy starting, oldConstructionId =', oldConstructionId)
        if not(edgeUtils.isValidAndExistingId(oldConstructionId)) then return end

        local oldConstruction = api.engine.getComponent(oldConstructionId, api.type.ComponentType.CONSTRUCTION)
        logger.print('oldConstruction =') logger.debugPrint(oldConstruction)
        if not(oldConstruction)
        or not(oldConstruction.params)
        or oldConstruction.params.snapNodes == 3 -- leave if nothing is going to change
        or oldConstruction.fileName ~= _eventProperties.lorryStationBuilt.conName then return end

        local newConstruction = api.type.SimpleProposal.ConstructionEntity.new()
        newConstruction.fileName = oldConstruction.fileName
        -- cannot clone this userdata dynamically, coz it won't take pairs and ipairs
        newConstruction.params = {
            streetType_ = oldConstruction.params.streetType_,
            isStoreCargoOnPavement = oldConstruction.params.isStoreCargoOnPavement,
            direction = oldConstruction.params.direction,
            snapNodes = 3, -- this is what this is all about
            hasBus = oldConstruction.params.hasBus,
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
        -- proposal.constructionsToRemove[1] = oldConstructionId -- fails to add
        -- proposal.constructionsToRemove:add(oldConstructionId) -- fails to add
        -- proposal.old2new = { -- expected number, received table
        --     { oldConstructionId, 1 }
        -- }
        -- proposal.old2new = {
        --     oldConstructionId, 1
        -- }
        -- proposal.old2new = {
        --     oldConstructionId,
        -- }

        local context = api.type.Context:new()
        context.checkTerrainAlignment = false -- true gives smoother z, default is false
        context.cleanupStreetGraph = false -- default is false
        context.gatherBuildings = false -- default is false
        context.gatherFields = true -- default is true
        context.player = api.engine.util.getPlayer()

        local cmd = api.cmd.make.buildProposal(proposal, context, true) -- the 3rd param is "ignore errors"
        api.cmd.sendCommand(cmd, function(res, success)
            -- logger.print('LOLLO replaceStationWithSnappyCopy res = ')
            -- logger.debugPrint(res)
            logger.print('LOLLO replaceStationWithSnappyCopy success = ') logger.debugPrint(success)
            -- if success then
            -- end
        end)
    end,
}

function data()
    return {
        guiHandleEvent = function(id, name, args)
            -- LOLLO NOTE param can have different types, even boolean, depending on the event id and name
            -- if (name ~= 'builder.apply') then return end

            -- logger.print('guiHandleEvent caught id =', id, 'name =', name, 'args =') logger.debugPrint(args)
            -- if name ~= 'builder.proposalCreate' then
            --  logger.print('guiHandleEvent caught id =', id, 'name =', name, 'args =') logger.debugPrint(args)
            -- end

            -- xpcall(
            --     function()
            if name == 'builder.apply' then
                -- logger.print('guiHandleEvent caught id =', id, 'name =', name, 'args =') logger.debugPrint(args)
                if (id == 'constructionBuilder') then
                    -- modular lorry station has been built
                    if (not(args.result) or not(args.result[1])) then return end

                    if _isBuildingLorryBayWithEdges(args) then
                        api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
                            string.sub(debug.getinfo(1, 'S').source, 1),
                            _eventId,
                            _eventProperties.lorryStationBuilt.eventName,
                            {
                                constructionEntityId = args.result[1]
                            }
                        ))
                    end
                -- elseif id == 'streetTerminalBuilder' then
                --     -- waypoint or streetside stations have been built
                --     if (args and args.proposal and args.proposal.proposal
                --     and args.proposal.proposal.edgeObjectsToAdd
                --     and args.proposal.proposal.edgeObjectsToAdd[1]
                --     and args.proposal.proposal.edgeObjectsToAdd[1].modelInstance)
                --     then
                --         if _guiConstants._ploppableCargoModelId
                --         and args.proposal.proposal.edgeObjectsToAdd[1].modelInstance.modelId == _guiConstants._ploppableCargoModelId then
                --             local stationId = args.proposal.proposal.edgeObjectsToAdd[1].resultEntity
                --             logger.print('stationId =') logger.debugPrint(stationId)
                --             local edgeId = args.proposal.proposal.edgeObjectsToAdd[1].segmentEntity
                --             logger.print('edgeId =') logger.debugPrint(edgeId)
                --             if not(edgeId) or not(stationId) then return end

                --             api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
                --                 string.sub(debug.getinfo(1, 'S').source, 1),
                --                 _eventId,
                --                 _eventProperties.ploppableStreetsideCargoStationBuilt.eventName,
                --                 {
                --                     edgeId = edgeId,
                --                     stationId = stationId,
                --                 }
                --             ))
                --         elseif _guiConstants._ploppablePassengersModelId
                --         and args.proposal.proposal.edgeObjectsToAdd[1].modelInstance.modelId == _guiConstants._ploppablePassengersModelId then
                --             local stationId = args.proposal.proposal.edgeObjectsToAdd[1].resultEntity
                --             logger.print('stationId =') logger.debugPrint(stationId)
                --             local edgeId = args.proposal.proposal.edgeObjectsToAdd[1].segmentEntity
                --             logger.print('edgeId =') logger.debugPrint(edgeId)
                --             if not(edgeId) or not(stationId) then return end

                --             api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
                --                 string.sub(debug.getinfo(1, 'S').source, 1),
                --                 _eventId,
                --                 _eventProperties.ploppableStreetsidePassengerStationBuilt.eventName,
                --                 {
                --                     edgeId = edgeId,
                --                     stationId = stationId,
                --                 }
                --             ))
                --         end
                --     end
                end
            end
            --     end,
            --     _myErrorHandler
            -- )
        end,
        -- guiInit = function()
        -- end,
        handleEvent = function(src, id, name, args)
            if (id ~= _eventId) then return end
            logger.print('handleEvent starting, src =', src, ', id =', id, ', name =', name, ', args =') logger.debugPrint(args)
            if type(args) ~= 'table' then return end

            if name == _eventProperties.lorryStationBuilt.eventName then
                actions.replaceStationWithSnappyCopy(args.constructionEntityId)
            -- elseif name == _eventProperties.ploppableStreetsideCargoStationBuilt.eventName then
            --     if edgeUtils.isValidAndExistingId(args.edgeId) and edgeUtils.isValidAndExistingId(args.stationId) and not(edgeUtils.isEdgeFrozen(args.edgeId)) then
            --         local stationTransf = edgeUtils.getObjectTransf(args.stationId)
            --         -- logger.print('stationTransf =') logger.debugPrint(stationTransf)
            --         local nodeBetween = edgeUtils.getNodeBetweenByPosition(
            --             args.edgeId,
            --             {stationTransf[13], stationTransf[14], stationTransf[15]},
            --             false
            --         )
            --         logger.print('nodeBetween =') logger.debugPrint(nodeBetween)
            --         local proposal = actions.getSplitEdgeProposal(args.edgeId, nodeBetween, args.stationId)
            --         if proposal then
            --             actions.buildStation_UNUSED(proposal, stationTransf)
            --         end
            --     end
            -- elseif name == _eventProperties.ploppableStreetsidePassengerStationBuilt.eventName then
            end
        end,
        -- update = function()
        -- end,
        -- guiUpdate = function()
        -- end,
    }
end
