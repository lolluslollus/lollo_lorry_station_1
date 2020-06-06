local luadump = require('lollo_lorry_station/luadump')
local inspect = require('lollo_lorry_station/inspect')
local arrayUtils = require('lollo_lorry_station/arrayUtils')
local edgeUtils = require('lollo_lorry_station/edgeHelpers')
-- local _modConstants = require('lollo_lorry_station/constants')
local stringUtils = require('lollo_lorry_station/stringUtils')
local debugger = require('debugger')

local state = {
    isShowAllEvents = false
}

local _constants = arrayUtils.addProps(
    {
        constructionFileName = 'station/street/lollo_lorry_station.con',
        stationFileName = 'station/road/lollo_small_cargo.mdl'
    }
)

-- The idea here is, the user plops a streetside lorry station and then selects it.
-- The trouble is, there is no way to tell what I really selected.
local function _getCloneWoutModulesAndSeed(obj)
    return arrayUtils.cloneOmittingFields(obj, {'modules', 'seed'})
end

local function _myErrorHandler(err)
    print('ERROR: ', err)
end

function data()
    return {
        handleEvent = function(src, id, name, args)
            if src == 'guidesystem.lua' then return end -- also comes with guide system switched off
            if state.isShowAllEvents then
                print('LOLLO handleEvent src =', src, ' id =', id, ' name =', name)
            end
            if (id == '__lolloLorryStation2Event__') then
                print('__lolloLorryStation2Event__ caught')
                print('LOLLO src = ', src, ' id = ', id, ' name = ', name, 'param = ')
                luadump(true)(args)

                if name == 'built' then
                    print('LOLLO game.interface.buildConstruction = ')
                    luadump(true)(game.interface.buildConstruction)

                    -- local allModels = api.res.modelRep.getAll()
                    -- debugger()
                    -- I arrive here from built with a funny transf looking like
                    -- 'transf' = '((0.203505 / -0.979074 / 0 / 0)/(0.979074 / 0.203505 / 0 / 0)/(0 / 0 / 1 / 0)/(569.336 / -3375.41 / 14.1587 / 1))'
                    -- which I stringified coz it is userData

                    -- from here on, I need to reverse the parameters.transf string somehow.
                    -- It looks like:
                    -- 'transf' = '((0.594247 / -0.804282 / 0 / 0)/(0.804282 / 0.594247 / 0 / 0)/(0 / 0 / 1 / 0)/(-3463.13 / 3196.42 / 55.4744 / 1))'
                    args.params = {}
                    -- parameters.params.id = parameters.id
                    args.params.streetEdges = edgeUtils.getNearbyStreetEdges(
                        args.position,
                        10
                    )
                    args.params.position = _getCloneWoutModulesAndSeed(args.position)
                elseif name == 'select' then
                    print('LOLLO game.interface.buildConstruction = ')
                    luadump(true)(game.interface.buildConstruction)

                    -- debugger()
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
                luadump(true)(param)
                -- id = 	mainView	 name = 	select	 param = 25278
                xpcall(
                    function()
                        -- with this event, param is the selected item id
                        local stationGroup = game.interface.getEntity(param)
                        if type(stationGroup) ~= 'table' or stationGroup.type ~= 'STATION_GROUP' or type(stationGroup.position) ~= 'table' then return end

                        local stationId = false
                        local stationPosition = {}
                        local allStations = game.interface.getEntities(
                            {pos = stationGroup.position, radius = 0},
                            {type = 'STATION', includeData = true}
                        )
                        -- print('LOLLO allStations = ')
                        -- luadump(true)(allStations)
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

                        -- debugger()

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

                        -- debugger()
                        if stationId then
                            game.interface.sendScriptEvent(
                                '__lolloLorryStation2Event__',
                                'select',
                                {
                                    id = stationId,
                                    position = stationPosition,
                                    stationGroupId = stationGroup.id,
                                }
                            )
                        end
                    end,
                    _myErrorHandler
                )
            elseif name == 'builder.apply' then
                -- when U add a streetside station, U don't get any ids. The streetside station is an edge object,
                -- it has no id (for now at least), so the edge id seems more interesting.
                -- U can try to figure it out here, but it's probably easier in the select handler
                -- print('LOLLO gui builder.apply caught, id = ', id, ' name = ', name, ' param = ')
                -- luadump(true)(param)
                -- you cannot check the types coz they contain userdata, so use xpcall
                xpcall(
                    function()
                        print('LOLLO name = ')
                        luadump(true)(name)
                        print('LOLLO param = ')
                        -- luadump(true)(param)
                        -- local allModels = api.res.modelRep.getAll()
                        -- print('LOLLO allModels = ')
                        -- luadump(true)(allModels)
                        -- debugger()
                        local stationModelId = api.res.modelRep.find(_constants.stationFileName)

                        -- print('LOLLO model instance =')
                        -- luadump(true)(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance)
                        -- print('LOLLO transf0 = ')
                        -- luadump(true)(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf0)
                        -- print(inspect(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf0))
                        -- print('LOLLO transf = ')
                        -- luadump(true)(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf)
                        -- print(inspect(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf))

                        if not param
                        or not param.proposal
                        or not param.proposal.proposal
                        or not param.proposal.proposal.edgeObjectsToAdd
                        or not param.proposal.proposal.edgeObjectsToAdd[1]
                        or not param.proposal.proposal.edgeObjectsToAdd[1].modelInstance
                        or param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.modelId ~= stationModelId then return end

                        -- local entity = game.interface.getEntity(param.result[1]) -- the newly built station
                        -- if type(entity) ~= 'table' or entity.type ~= 'CONSTRUCTION' or type(entity.position) ~= 'table' then return end

                        -- debugger()
                        game.interface.sendScriptEvent(
                            '__lolloLorryStation2Event__',
                            'built',
                            {
                                -- id = param.result[1],
                                -- params = entity.params,
                                -- position = entity.position,
                                -- proposal = param.proposal,
                                -- result = param.result
                                transf = tostring(param.proposal.proposal.edgeObjectsToAdd[1].modelInstance.transf)
                            }
                        )
                    end,
                    _myErrorHandler
                )

                local sampleParam = 
                {
                  data = {
                    collisionInfo = {
                      collisionEntities = {  },
                      autoRemovalEntity2models = {  },
                      fieldEntities = {  },
                      buildingEntities = {  }
                    },
                    entity2tn = {
                      [25280] = {
                        nodes = {  },
                        edges = {
                          {
                            speedLimit = 0,
                            curveSpeedLimit = 0,
                            curSpeed = 0,
                            precedence = false
                          },
                          {
                            speedLimit = 22.22222328186,
                            curveSpeedLimit = 75.967430114746,
                            curSpeed = 14.666667938232,
                            precedence = false
                          },
                          {
                            speedLimit = 22.22222328186,
                            curveSpeedLimit = 75.900161743164,
                            curSpeed = 14.666667938232,
                            precedence = false
                          },
                          {
                            speedLimit = 0,
                            curveSpeedLimit = 0,
                            curSpeed = 0,
                            precedence = false
                          }
                        }
                      },
                      [25284] = {
                        -- nodes = {
                        --   userdata: 0x7f2662053758,
                        --   userdata: 0xd822fa8
                        -- },
                        edges = {
                          {
                            speedLimit = 0,
                            curveSpeedLimit = 0,
                            curSpeed = 0,
                            precedence = false
                          },
                          {
                            speedLimit = 22.22222328186,
                            curveSpeedLimit = 75.964141845703,
                            curSpeed = 14.666667938232,
                            precedence = false
                          },
                          {
                            speedLimit = 22.22222328186,
                            curveSpeedLimit = 75.586784362793,
                            curSpeed = 14.666667938232,
                            precedence = false
                          },
                          {
                            speedLimit = 22.22222328186,
                            curveSpeedLimit = 75.892021179199,
                            curSpeed = 14.666667938232,
                            precedence = false
                          },
                          {
                            speedLimit = 0,
                            curveSpeedLimit = 0,
                            curSpeed = 0,
                            precedence = false
                          },
                          {
                            speedLimit = 0,
                            curveSpeedLimit = 0,
                            curSpeed = 0,
                            precedence = false
                          }
                        }
                      },
                      [25288] = {
                        -- nodes = {
                        --   userdata: 0x7f265b5edd68,
                        --   userdata: 0x7f2634524d08,
                        --   userdata: 0x7f2698d103c8,
                        --   userdata: 0x7f2667194928
                        -- },
                        edges = {
                          {
                            speedLimit = -1,
                            curveSpeedLimit = 100,
                            curSpeed = -0.66000002622604,
                            precedence = false
                          }
                        }
                      },
                      [25289] = {
                        -- nodes = {
                        --   userdata: 0x7f263455a488,
                        --   userdata: 0x7f26345cfe28,
                        --   userdata: 0x7f263460bc68,
                        --   userdata: 0x7f2634560a38
                        -- },
                        edges = {
                          {
                            speedLimit = -1,
                            curveSpeedLimit = 100,
                            curSpeed = -0.66000002622604,
                            precedence = false
                          }
                        }
                      },
                      [27258] = {
                        nodes = {  },
                        edges = {
                          {
                            speedLimit = 0,
                            curveSpeedLimit = 0,
                            curSpeed = 0,
                            precedence = false
                          },
                          {
                            speedLimit = 22.22222328186,
                            curveSpeedLimit = 75.962844848633,
                            curSpeed = 14.666667938232,
                            precedence = false
                          },
                          {
                            speedLimit = 22.22222328186,
                            curveSpeedLimit = 75.895401000977,
                            curSpeed = 14.666667938232,
                            precedence = false
                          },
                          {
                            speedLimit = 0,
                            curveSpeedLimit = 0,
                            curSpeed = 0,
                            precedence = false
                          }
                        }
                      }
                    },
                    tpNetLinkProposal = {
                      toRemove = {  },
                      toAdd = {  }
                    },
                    costs = 1200,
                    errorState = {
                      critical = false,
                      messages = {  },
                      warnings = {  }
                    }
                  },
                  proposal = {
                    proposal = {
                      addedNodes = {  },
                      addedSegments = {
                        {
                          entity = -1,
                          comp = {
                            node0 = 25289,
                            node1 = 25288,
                            tangent0 = (-47.2417 / 58.2757 / -0.227116),
                            tangent1 = (-45.2802 / 59.8255 / -0.310316),
                            type = 0,
                            typeIndex = -1,
                            objects = {
                              { -1, 1 }
                            }
                          },
                          type = 0,
                          params = {
                            streetType = 12,
                            hasBus = false,
                            tramTrackType = 0,
                            precedenceNode0 = 2,
                            precedenceNode1 = 2
                          },
                        --   playerOwned = <unknown type>,
                          streetEdge = {
                            streetType = 12,
                            hasBus = false,
                            tramTrackType = 0,
                            precedenceNode0 = 2,
                            precedenceNode1 = 2
                          },
                          trackEdge = {
                            trackType = -1,
                            catenary = false
                          }
                        }
                      },
                      removedNodes = {  },
                      removedSegments = {
                        {
                          entity = 26286,
                          comp = {
                            node0 = 25289,
                            node1 = 25288,
                            tangent0 = (-47.2417 / 58.2757 / -0.227116),
                            tangent1 = (-45.2802 / 59.8255 / -0.310316),
                            type = 0,
                            typeIndex = -1,
                            objects = {  }
                          },
                          type = 0,
                          params = {
                            streetType = 12,
                            hasBus = false,
                            tramTrackType = 0,
                            precedenceNode0 = 2,
                            precedenceNode1 = 2
                          },
                        --   playerOwned = <unknown type>,
                          streetEdge = {
                            streetType = 12,
                            hasBus = false,
                            tramTrackType = 0,
                            precedenceNode0 = 2,
                            precedenceNode1 = 2
                          },
                          trackEdge = {
                            trackType = -1,
                            catenary = false
                          }
                        }
                      },
                      edgeObjectsToRemove = {  },
                      edgeObjectsToAdd = {
                        {
                          category = 0,
                          segmentEntity = -1,
                          modelInstance = {
                            modelId = 3639,
                            -- transf0 = <unknown type>,
                            transf = ((0.625234 / -0.780437 / 0 / 0)/(0.780437 / 0.625234 / 0 / 0)/(0 / 0 / 1 / 0)/(-3409.59 / 3126.84 / 55.8393 / 1)),
                            transformator = -1
                          },
                          oneWay = false,
                          left = false,
                          name = 'High Street',
                          playerEntity = 18737
                        }
                      },
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
                    toAdd = {  },
                    old2new = {  },
                    parcelsToRemove = {  }
                  },
                  result = {  }
                }
            end

--[[             xpcall(
                function()
                    print('one')
                    local out = io.popen('find /v '' > con', 'w')
                    print('out = ')
                    luadump(true)(out)
                    luadump(true)(table.unpack(out))
                    print('two')
                    out:write('three' .. '\r\n') --\r because windows
                    print('four')
                    out:flush()
                    print('five')
                end,
                _myErrorHandler
            ) ]]
            

            --[[ xpcall(
                function()
                    print('debugger = ')
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
                -- if key ~= 'package' and key ~= '_G' then
                --     luadump(true)(value)
                -- else
                --     print('luadump too long, skipped')
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

            -- -- print('-- package = ')
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
