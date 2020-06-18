local inspect = require('lollo_lorry_station/inspect')
local luadump = require('lollo_lorry_station/luadump')
local arrayUtils = require('lollo_lorry_station/arrayUtils')
local edgeUtils = require('lollo_lorry_station/edgeHelpers')
local transfUtils = require('lollo_lorry_station/transfUtils')
local _constants = require('lollo_lorry_station/constants')
local stringUtils = require('lollo_lorry_station/stringUtils')
local debugger = require('debugger')

local state = {
    isShowAllEvents = false
}

-- local function _getCloneWoutModulesAndSeed(obj)
--     return arrayUtils.cloneOmittingFields(obj, {'modules', 'seed'})
-- end
local function _getCloneWoutSeed(obj)
    return arrayUtils.cloneOmittingFields(obj, {'seed'})
end

local function _myErrorHandler(err)
    print('ERROR: ', err)
end

-- Hi man! I have edge0 and edge1, each with {x, y, z} and {sin x, cos x, some func of z}.
-- Given these two nodes, I can find a 3rd order polynom that connects the two edges and respects their tangents.
-- Now I can find out the coordinates of any point along the piece of road, that connects the two edges.
-- Now I put a point somewhere near the middle into the module grid. I know its coordinates and tangents.
-- This works already.
-- The trouble starts now: I want to remove the previous segment connecting edge0 and edge1, replace it with two segments and add a terminal inbetween. The new api seems to be the smart way to do it.
-- Question: if I replace the segment with the new api, like you did in the road toolbox, will that bulldoze the buildings?
function data()
    local function addSplitter(params)

    end

    return {
        handleEvent = function(src, id, name, args)
            if src == 'guidesystem.lua' then return end -- also comes with guide system switched off
            if state.isShowAllEvents then
                print('LOLLO handleEvent src =', src, ' id =', id, ' name =', name)
            end
            if (id == '__lolloLorryStationEvent__') then
                print("__lolloLorryStationEvent__ caught")
                print('LOLLO src = ', src, ' id = ', id, ' name = ', name, 'param = ')
                -- src =	lollo_lorry_station.lua	 id =	__lolloLorryStationEvent__	 name =	select
                luadump(true)(args)
                -- print('LOLLO api = ')
                -- luadump(true)(api)
                -- we upgrade the construction to inject the street edges
                if name == 'select' then
                    local newParams = _getCloneWoutSeed(args.params)
                    newParams.id = args.id
                    -- args.params.streetEdges = edgeUtils.getStreetEdgesSquareBySquare(
                    --     args.transf
                    -- )
                    -- debugger()
                    local nearbyStreetEdges = edgeUtils.getNearbyStreetEdges(
                        args.transf
                    )

                    -- local BuildProposal = api.type.BuildProposal:new()
                    -- print('LOLLO BuildProposal = ')
                    -- luadump(true)(BuildProposal)

                    -- local Proposal = api.type.Proposal:new()
                    -- print('LOLLO Proposal = ')
                    -- luadump(true)(Proposal)

                    -- local ProposalCreateCallbackResult = api.type.ProposalCreateCallbackResult:new()
                    -- print('LOLLO ProposalCreateCallbackResult = ')
                    -- luadump(true)(ProposalCreateCallbackResult)

                    -- local ProposalData = api.type.ProposalData:new()
                    -- print('LOLLO ProposalData = ')
                    -- luadump(true)(ProposalData)

                    -- local SimpleProposal = api.type.SimpleProposal:new()
                    -- print('LOLLO SimpleProposal = ')
                    -- luadump(true)(SimpleProposal)

                    -- local SimpleStreetProposal = api.type.SimpleStreetProposal:new()
                    -- print('LOLLO SimpleStreetProposal = ')
                    -- luadump(true)(SimpleStreetProposal)

                    -- local StreetProposal = api.type.StreetProposal:new()
                    -- print('LOLLO StreetProposal = ')
                    -- luadump(true)(StreetProposal)

                    -- local TpNetLinkProposal = api.type.TpNetLinkProposal:new()
                    -- print('LOLLO TpNetLinkProposal = ')
                    -- luadump(true)(TpNetLinkProposal)

                    -- print('LOLLO nearbyStreetEdges =')
                    -- luadump(true)(nearbyStreetEdges)
                    -- newParams.streetEdgesWithAbsoluteCoordinates = {}
                    -- newParams.streetEdgesWithRelativeCoordinates = {}
                    newParams.streetNodeGroups = {}
                    for _, edge in pairs(nearbyStreetEdges) do
                        local abs = edgeUtils.getEdgeBetween(
                            {
                                edge['node0pos'],
                                edge['node0tangent']
                            },
                            {
                                edge['node1pos'],
                                edge['node1tangent']
                            }
                        )
                        newParams.streetNodeGroups[#newParams.streetNodeGroups+1] = {
                            {
                                edge['node0pos'],
                                edge['node0tangent']
                            },
                            abs,
                            {
                                edge['node1pos'],
                                edge['node1tangent']
                            }
                        }
                    end
                    print('LOLLO newParams.streetNodeGroups = ')
                    luadump(true)(newParams.streetNodeGroups)
                    newParams.position = _getCloneWoutSeed(args.position)
                    newParams.transf = _getCloneWoutSeed(args.transf)
                    newParams.inverseTransf = transfUtils.getInverseTransf(args.transf)

                    addSplitter(newParams)

                    local newId = game.interface.upgradeConstruction(
                        args.id,
                        _constants.constructionFileName,
                        newParams
                    )
                end
            end

            state.isShowAllEvents = true

--[[             package.loaded["lollo_lorry_station/reloaded"] = nil
            local reloaded = require("lollo_lorry_station/reloaded")
            reloaded.tryDebugger()
 ]]

            -- package.loaded["lollo_lorry_station/reloaded"] = nil
            -- local reloaded = require("lollo_lorry_station/reloaded")
            -- reloaded.tryGlobalVariables()

            -- something to try:
            -- local id = game.interface.buildConstruction(
            --     "constructionName.con",
            --     params, -- params you use in your construction
            --     transf -- transformation for your construction
            -- )

        end,
        guiHandleEvent = function(id, name, param, four, five)
            -- LOLLO NOTE when U try to add a streetside bus or lorry stop, the streetBuilder fires this event.
            -- Then, the proposal contains no new objects and no old objects: it's not empty, but it's only filled with objects
            -- that are in turn filled with empty objects.
            -- Once the user has hovered on a suitable spot (ie streetside), the proposal is not empty anymore,
            -- and it is actually rather complex.
            -- package.loaded["lollo_lorry_station/reloaded"] = nil
            -- local reloaded = require("lollo_lorry_station/reloaded")
            -- reloaded.showState(state)
            if name == 'select' then
                print('LOLLO lorry station caught gui select, id = ', id, ' name = ', name, ' param = ')
                luadump(true)(param)
                -- id = 	mainView	 name = 	select	 param = 25278
                xpcall(
                    function()
                        -- with this event, param is the selected item id
                        local entity = game.interface.getEntity(param)
                        print('LOLLO selected entity = ')
                        luadump(true)(entity)

                        if type(entity) ~= 'table' or type(entity.position) ~= 'table' then return end
                        
                        -- now I know the user has selected a station group, but we need to know more
                        local constructionId = false
                        local constructionParams = {}
                        local constructionPosition = {}
                        local constructionTransf = {}
                        if entity.type == 'STATION_GROUP' then
                            local nearbyLorryStationConstructions = game.interface.getEntities(
                                {pos = entity.position, radius = 999},
                                {type = "CONSTRUCTION", includeData = true, fileName = _constants.constructionFileName}
                            )
                            -- LOLLO NOTE this call returns constructions mostly sorted by distance, but not reliably!
                            -- the game distinguishes constructions, stations and station groups.
                            -- Constructions and stations in a station group are not selected, only the station group itself, 
                            -- which does not contain a lot of data.
                            -- This is why we need this loop.
                            for _, staId in ipairs(entity.stations) do
                                for _, con in pairs(nearbyLorryStationConstructions) do
                                    if stringUtils.arrayHasValue(con.stations, staId) then
                                        if not constructionId then
                                            -- debugger()
                                            constructionId = con.id
                                            constructionParams = con.params
                                            constructionPosition = con.position
                                            constructionTransf = con.transf
                                        else
                                            break
                                        end
                                    end
                                end
                            end
                        elseif entity.type == 'CONSTRUCTION' and entity.fileName == _constants.constructionFileName then
                            local con = entity
                            constructionId = con.id
                            constructionParams = con.params
                            constructionPosition = con.position
                            constructionTransf = con.transf
                        else
                            return
                        end

                        -- debugger()
                        -- The user has selected one of my lorry stations: go ahead in the worker thread
                        if constructionId then
                            game.interface.sendScriptEvent(
                                "__lolloLorryStationEvent__",
                                "select",
                                {
                                    id = constructionId,
                                    params = constructionParams,
                                    position = constructionPosition,
                                    transf = constructionTransf
                                }
                            )
                        end
                    end,
                    _myErrorHandler
                )
            elseif name == 'builder.apply' then
                if param and param.proposal then
                    debugger()
                    print('LOLLO builder.apply caught with param = ', inspect(param))
                    print('LOLLO param.data =', inspect(param.data))
                    print('LOLLO param.proposal =', inspect(param.proposal))
                    print('LOLLO param.result =', inspect(param.result))
                    luadump(true)(param)
                end
                if true then return end
                -- print('LOLLO gui select caught, id = ', id, ' name = ', name, ' param = ')
                -- luadump(true)(param)
                -- you cannot check the types coz they contain userdata, so use xpcall
                -- if type(param) == 'table' and type(param.proposal) == 'table'
                --     and type(param.proposal.toAdd) == 'table' and type(param.proposal.toAdd[1]) == 'table'
                --     and param.proposal.toAdd[1].fileName == _constants.constructionFileName then
                xpcall(
                    function()
                        if not param.proposal.toAdd or not param.proposal.toAdd[1] or param.proposal.toAdd[1].fileName ~= _constants.constructionFileName then return end
                        if not param.result[1] then return end

                        local entity = game.interface.getEntity(param.result[1]) -- the newly built station
                        if type(entity) ~= 'table' or entity.type ~= 'CONSTRUCTION' or type(entity.position) ~= 'table' then return end

                        -- debugger()
                        game.interface.sendScriptEvent(
                            '__lolloLorryStationEvent__',
                            'built',
                            {
                                id = param.result[1],
                                params = entity.params,
                                position = entity.position,
                                -- proposal = param.proposal,
                                -- result = param.result
                                transf = entity.transf
                            }
                        )
                    end,
                    _myErrorHandler
                )

                local sampleParam = {
                    data = {
                      collisionInfo = {
                        collisionEntities = {  },
                        autoRemovalEntity2models = {
                          [18340] = { 1 }
                        },
                        fieldEntities = {  },
                        buildingEntities = {  }
                      },
                      entity2tn = {
                        [9361] = {
                        --   nodes = {
                        --     userdata: 0x7f08d56cd178,
                        --     userdata: 0x7f08a0f15668,
                        --     userdata: 0x7f08a0ebcd58,
                        --     userdata: 0x7f08a0ea2968,
                        --     userdata: 0x7f08a0dff6b8,
                        --     userdata: 0x7f08be426c08,
                        --     userdata: 0x7f08a0cf4538
                        --   },
                          edges = {
                            {
                              speedLimit = 5.5555558204651,
                              curveSpeedLimit = 160.00799560547,
                              curSpeed = 3.6666669845581,
                              precedence = false
                            },
                            {
                              speedLimit = 5.5555558204651,
                              curveSpeedLimit = 160.00799560547,
                              curSpeed = 3.6666669845581,
                              precedence = false
                            },
                            {
                              speedLimit = 5.5555558204651,
                              curveSpeedLimit = 160.00799560547,
                              curSpeed = 3.6666669845581,
                              precedence = false
                            },
                            {
                              speedLimit = 5.5555558204651,
                              curveSpeedLimit = 160.00799560547,
                              curSpeed = 3.6666669845581,
                              precedence = false
                            }
                          }
                        }
                      },
                      tpNetLinkProposal = {
                        toRemove = {  },
                        toAdd = {  }
                      },
                      costs = 1055,
                      errorState = {
                        critical = false,
                        messages = {  },
                        warnings = {  }
                      }
                    },
                    proposal = {
                      proposal = {
                        addedNodes = {  },
                        addedSegments = {  },
                        removedNodes = {  },
                        removedSegments = {  },
                        edgeObjectsToRemove = {  },
                        edgeObjectsToAdd = {  },
                        new2oldNodes = {  },
                        old2newNodes = {  },
                        new2oldSegments = {  },
                        old2newSegments = {  },
                        new2oldEdgeObjects = {  },
                        old2newEdgeObjects = {  },
                        frozenNodes = {  }
                      },
                      terrainAlignSkipEdges = {  },
                      segmentTags = {  },
                      toRemove = {  },
                      toAdd = {
                        {
                          fileName = _constants.constructionFileName,
                          params = { busLane = 0, lockLayoutCentre = 0, paramX = 0, paramY = 0, seed = 0, tramTrack = 0, year = 1950 },
                          hasCargoPlatform = false,
                          transf = ((1 / 0 / 0 / 0)/(-0 / 1 / 0 / 0)/(0 / 0 / 1 / 0)/(-3547.22 / 3206.46 / 54.534 / 1)),
                          frozenNodes = {  },
                          segmentsBefore = 0,
                          name = "Midsomer Norton Halt",
                          playerEntity = 18737,
                          setAsHeadquarterHack = false
                        }
                      },
                      old2new = {  },
                      parcelsToRemove = {  }
                    },
                    result = { 9361 }
                  }
            end

--[[             xpcall(
                function()
                    print("one")
                    local out = io.popen('find /v "" > con', 'w')
                    print("out = ")
                    luadump(true)(out)
                    luadump(true)(table.unpack(out))
                    print("two")
                    out:write("three" .. '\r\n') --\r because windows
                    print("four")
                    out:flush()
                    print("five")
                end,
                _myErrorHandler
            ) ]]
            

            --[[ xpcall(
                function()
                    print("debugger = ")
                    luadump(true)(debugger)
                    print('about to start debugger')
                    debugger()
                    print('debugger called')
                end,
                _myErrorHandler
            ) ]]

            --[[ print('- io = ')
            luadump(true)(io)

            print('-- global variables = ')
            for key, value in pairs(_G) do
                print(key, value)
                -- if key ~= "package" and key ~= "_G" then
                --     luadump(true)(value)
                -- else
                --     print("luadump too long, skipped")
                -- end
            end ]]
            -- print('-- sol = ')
            -- luadump(true)(sol)
            -- print('-- ug = ')
            -- luadump(true)(ug)

            --[[ xpcall(
                function()
                    print(' -- begin')
                    local one = ug.BaseEdge.new()
                    luadump(true)(one)
                    print(' -- end')
                end,
                _myErrorHandler
            ) ]]

            --[[ xpcall(
                function()
                    print(' -- _ =')
                    luadump(true)(_G._)
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

            -- -- print("-- package = ")
            -- -- luadump(true)(package) --this hangs
            -- print('-- getmetatable = ')
            -- luadump(true)(getmetatable(''))
            -- print('-- io = ')
            -- luadump(true)(io)

            -- print('-- game = ')
            -- luadump(true)(game)

            -- _G.lollo = true
        end,
        update = function()
        end,
        guiUpdate = function()
        end,
        save = function()
            if not state then state = {} end
            if not state.isShowAllEvents then state.isShowAllEvents = false end
            return state
        end,
        load = function(data)
            if data then
                state.isShowAllEvents = data.isShowAllEvents or false
            end
            -- if state ~= nil then
            --     print('LOLLO state = ')
            --     luadump(true)(state)
            -- end
            return state
        end
    }
end
