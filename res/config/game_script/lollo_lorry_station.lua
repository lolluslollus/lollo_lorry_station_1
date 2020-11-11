local arrayUtils = require('lollo_lorry_station.arrayUtils')

-- LOLLO TODO try and get rid of all game. dependencies

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
    return _isBuildingConstructionWithFileName(param, 'station/street/lollo_lorry_bay_with_edges.con')
end

local function _myErrorHandler(err)
    print('lollo lorry station ERROR: ', err)
end

local function _replaceStation(oldConstructionId)
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
    newConstruction.params = {
        streetType_ = oldConstruction.params.streetType_,
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

    -- if I bulldoze here, the station will inherit the old name
    -- game.interface.bulldoze(oldConstructionId)

    local callback = function(res, success)
        -- print('LOLLO _buildStation res = ')
		-- debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        -- print('LOLLO _buildStation success = ')
        -- debugPrint(success)
        -- if success then
            -- if I bulldoze here, the station will get the new name
        -- end
	end

    local context = api.type.Context:new()
    context.checkTerrainAlignment = false -- true gives smoother z, default is false
    context.cleanupStreetGraph = false -- default is false
    context.gatherBuildings = false -- default is false
    context.gatherFields = true -- default is true
    context.player = api.engine.util.getPlayer()

	local cmd = api.cmd.make.buildProposal(proposal, context, true) -- the 3rd param is "ignore errors"
	api.cmd.sendCommand(cmd, callback)
end

function data()
    return {
        ini = function()
        end,
        handleEvent = function(src, id, name, param)
            if (id ~= '__lolloLorryStationEvent__') then return end
            if type(param) ~= 'table' or type(param.constructionEntityId) ~= 'number' or param.constructionEntityId < 0 then return end

            -- print('param.constructionEntityId =', param.constructionEntityId or 'NIL')
            if name == 'lorryStationBuilt' then
                _replaceStation(param.constructionEntityId)
            end
        end,
        guiHandleEvent = function(id, name, param)
            -- LOLLO NOTE param can have different types, even boolean, depending on the event id and name
            if id ~= 'constructionBuilder' then return end
            if name ~= 'builder.apply' then return end
            -- if name == "builder.proposalCreate" then return end

            xpcall(
                function()
                    if not param.result or not param.result[1] then
                        return
                    end

                    if _isBuildingLorryBayWithEdges(param) then
                        game.interface.sendScriptEvent(
                            '__lolloLorryStationEvent__',
                            'lorryStationBuilt',
                            {
                                constructionEntityId = param.result[1]
                            }
                        )
                    end
                end,
                _myErrorHandler
            )
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
