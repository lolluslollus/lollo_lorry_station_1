local luadump = require('lollo_lorry_station/luadump')
local stringUtils = require('lollo_lorry_station/stringUtils')
local debugger = require('debugger')

local state = {
    isShowAllEvents = false
}

local function myErrorHandler(err)
    print('ERROR: ', err)
end

function data()
    return {
        handleEvent = function(src, id, name, param)
            if (id ~= '__lolloLorryStationEvent__') then
                return
            end

            print("__lolloLorryStationEvent__ caught")
            state.isShowAllEvents = true
--[[             package.loaded["lollo_lorry_station/reloaded"] = nil
            local reloaded = require("lollo_lorry_station/reloaded")
            reloaded.trySocket() ]]

--[[             package.loaded["lollo_lorry_station/reloaded"] = nil
            local reloaded = require("lollo_lorry_station/reloaded")
            reloaded.tryDebugger()
 ]]
 
            -- package.loaded["lollo_lorry_station/reloaded"] = nil
            -- local reloaded = require("lollo_lorry_station/reloaded")
            -- reloaded.tryGlobalVariables()

            --gui = {
            --    buttoncallbacks = {  },
            --    windowcallbacks = {  }  absoluteLayout_get = (id),
            --    boxLayout_create = (id, orientation),
            --    boxLayout_get = (id, orientation),
            --    button_create = (id, content),
            --    button_get = (id, content),
            --    component_create = (id, name),
            --    component_get = (id),
            --    imageView_create = (id, path),
            --    imageView_get = (id, path),
            --    textView_create = (id, text, width),
            --    textView_get = (id),
            --    window_create = (id, title, child),
            --    window_get = (id)
            --}

            --            game.interface = {
            --     addPlayer = (),
            --     book = (),
            --     buildConstruction = (),
            --     bulldoze = (),
            --     clearJournal = (),
            --     findPath = (),
            --     getBuildingType = (),
            --     getBuildingTypes = (),
            --     getCargoType = (),
            --     getCargoTypes = (),
            --     getCompanyScore = (),
            --     getConstructionEntity = (),
            --     getDateFromNowPlusOffsetDays = (),
            --     getDepots = (),
            --     getDestinationDataPerson = (),
            --     getEntities = (),
            --     getEntity = (),
            --     getGameDifficulty = (),
            --     getGameSpeed = (),
            --     getGameTime = (),
            --     getHeight = (),
            --     getIndustryProduction = (),
            --     getIndustryProductionLimit = (),
            --     getIndustryShipping = (),
            --     getIndustryTransportRating = (),
            --     getLines = (),
            --     getLog = (),
            --     getMillisPerDay = (),
            --     getName = (),
            --     getPlayer = (),
            --     getPlayerJournal = (),
            --     getStationTransportSamples = (),
            --     getStations = (),
            --     getTownCapacities = (),
            --     getTownCargoSupplyAndLimit = (),
            --     getTownEmission = (),
            --     getTownReachability = (),
            --     getTownTrafficRating = (),
            --     getTownTransportSamples = (),
            --     getTowns = (),
            --     getVehicles = (),
            --     getWorld = (),
            --     replaceVehicle = (),
            --     setBuildInPauseModeAllowed = (),
            --     setBulldozeable = (),
            --     setDate = (),
            --     setGameSpeed = (),
            --     setMarker = (),
            --     setMaximumLoan = (),
            --     setMillisPerDay = (),
            --     setMinimumLoan = (),
            --     setMissionState = (),
            --     setName = (),
            --     setPlayer = (),
            --     setTownCapacities = (),
            --     setTownDevelopmentActive = (),
            --     setZone = (),
            --     spawnAnimal = (),
            --     startEvent = (),
            --     upgradeConstruction = ()
            --   }

            --  game.gui = nil or empty

            -- game.res = {
            --     gameScript = {
            --       ["arrivaltracker.lua_handleEvent"] = (src, id, name, param),
            --       ["arrivaltracker.lua_load"] = (loadedstate),
            --       ["arrivaltracker.lua_save"] = (),
            --       ["base.lua_init"] = (),
            --       ["base.lua_update"] = (),
            --       ["contexthelper.lua_guiHandleEvent"] = (id, name, param),
            --       ["contexthelper.lua_guiUpdate"] = (),
            --       ["contexthelper.lua_init"] = (),
            --       ["contexthelper.lua_load"] = (state),
            --       ["contexthelper.lua_save"] = (),
            --       ["contexthelper.lua_update"] = (),
            --       ["entry.lua_guiHandleEvent"] = (id, name, param),
            --       ["entry.lua_guiUpdate"] = (),
            --       ["entry.lua_handleEvent"] = (src, id, name, param),
            --       ["entry.lua_load"] = (data),
            --       ["entry.lua_save"] = (),
            --       ["gameinfo.lua_guiInit"] = (),
            --       ["gameinfo.lua_guiUpdate"] = (),
            --       ["gameinfo.lua_init"] = (),
            --       ["gameinfo.lua_load"] = (state),
            --       ["gameinfo.lua_save"] = (),
            --       ["gui.lua_guiHandleEvent"] = (id, name, param),
            --       ["guidesystem.lua_guiHandleEvent"] = (id, name, param),
            --       ["guidesystem.lua_guiUpdate"] = (),
            --       ["guidesystem.lua_handleEvent"] = (src, id, name, param),
            --       ["guidesystem.lua_load"] = (state, reset),
            --       ["guidesystem.lua_save"] = (),
            --       ["guidesystem.lua_update"] = (),
            --       ["mn_upgrader_gs.lua_guiUpdate"] = (),
            --       ["mn_upgrader_gs.lua_handleEvent"] = (src, id, name, param),
            --       ["modname.lua_guiHandleEvent"] = (id, name, param),
            --       ["modname.lua_guiUpdate"] = (),
            --       ["modname.lua_handleEvent"] = (src, id, name, param),
            --       ["modname.lua_load"] = (allState),
            --       ["modname.lua_save"] = (),
            --       ["modname.lua_update"] = (),
            --       ["mus.lua_guiHandleEvent"] = (id, name, param),
            --       ["selectortooltip.lua_guiHandleEvent"] = (id, name, param),
            --       ["selectortooltip.lua_guiUpdate"] = (),
            --       ["selectortooltip.lua_load"] = (state),
            --       ["selectortooltip.lua_save"] = (),
            --       ["snowball_coordinates_callbacks.lua_guiUpdate"] = (),
            --       ["snowball_fences_callback.lua_guiHandleEvent"] = (id, name, param),
            --       ["snowball_fences_callback.lua_handleEvent"] = (src, id, name, param)
            --     }
            --   }
        end,
        guiHandleEvent = function(id, name, param)
            -- if id ~= 'constructionBuilder' then
            --     return
            -- end
            -- if name ~= 'builder.apply' then
            --     return
            -- end
            -- if name == "builder.proposalCreate" then return end

            -- xpcall(
            --     function()
            --         print('LOLLO id = ', id)
            --         print('LOLLO name = ', name)
            --     end,
            --     myErrorHandler
            -- )
            -- LOLLO NOTE when U try to add a streetside bus or lorry stop, the streetBuilder fires this event.
            -- Then, the proposal contains no new objects and no old objects: it's not empty, but it's only filled with objects
            -- that are in turn filled with empty objects.
            -- Once the user has hovered on a suitable spot (ie streetside), the proposal is not empty anymore,
            -- and it is actually rather complex.
            if (id ~= 'constructionBuilder' and name ~= "builder.proposalCreate") and not state.isShowAllEvents then return end
            -- if not stringUtils.stringContains(name, 'builder') then return end
            -- debugger()

            -- print('LOLLO api in UI thread = ')
            -- luadump(true)(api)

            -- if true then return end

            print('{\n-- guiHandleEvent --')
            print('\n - id = ', id)
            print('\n - name = ', name)

            -- print('- io = ')
            -- luadump(true)(io)

            if name ~= 'builder.apply' then return end

            game.interface.sendScriptEvent(
                '__lolloLorryStationEvent__',
                'built',
                { }
            )

            

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
                myErrorHandler
            ) ]]
            

            --[[ xpcall(
                function()
                    print("debugger = ")
                    luadump(true)(debugger)
                    print('about to start debugger')
                    debugger()
                    print('debugger called')
                end,
                myErrorHandler
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
                myErrorHandler
            ) ]]

            --[[ xpcall(
                function()
                    print(' -- _ =')
                    luadump(true)(_G._)
                end,
                myErrorHandler
            ) ]]

            --[[ xpcall(
                function()
                    print(' -- begin')
                    local one = ug.BaseEdge:new()
                    luadump(true)(one)
                    print(' -- end')
                end,
                myErrorHandler
            ) ]]

            --[[ xpcall(
                function()
                    print(' -- begin')
                    debugPrint('LOLLO')
                    print(' -- end')
                end,
                myErrorHandler
            ) ]]

            --[[ xpcall(
                function()
                    print(' -- begin')
                    debugPrint(ug)
                    print(' -- end')
                end,
                myErrorHandler
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

            --[[ game.gui = {
                absoluteLayout_addItem = (),
                absoluteLayout_deleteAll = (),
                absoluteLayout_setPosition = (),
                addTask = (),
                boxLayout_addItem = (),
                boxLayout_create = (),
                button_create = (),
                calcMinimumSize = (),
                component_create = (),
                component_setLayout = (),
                component_setStyleClassList = (),
                component_setToolTip = (),
                component_setTransparent = (),
                getCamera = (),
                getContentRect = (),
                getMousePos = (),
                getTerrainPos = (),
                imageView_create = (),
                imageView_setImage = (),
                isEditor = (),
                isGuideSystemActive = (),
                openWindow = (),
                playCutscene = (),
                playSoundEffect = (),
                playTrack = (),
                setAutoCamera = (),
                setCamera = (),
                setConstructionAngle = (),
                setEnabled = (),
                setHighlighted = (),
                setMedalsCompletion = (),
                setMissionComplete = (),
                setTaskProgress = (),
                setVisible = (),
                showTask = (),
                stopAction = (),
                textView_create = (),
                textView_setText = (),
                window_close = (),
                window_create = (),
                window_setIcon = (),
                window_setPosition = (),
                window_setTitle = ()
              }, ]]

            --[[ game.interface = {
                findPath = (),
                getBuildingType = (),
                getBuildingTypes = (),
                getCargoType = (),
                getCargoTypes = (),
                getCompanyScore = (),
                getDateFromNowPlusOffsetDays = (),
                getDepots = (),
                getDestinationDataPerson = (),
                getEntities = (),
                getEntity = (),
                getGameDifficulty = (),
                getGameSpeed = (),
                getGameTime = (),
                getHeight = (),
                getIndustryProduction = (),
                getIndustryProductionLimit = (),
                getIndustryShipping = (),
                getIndustryTransportRating = (),
                getLines = (),
                getLog = (),
                getMillisPerDay = (),
                getName = (),
                getPlayer = (),
                getPlayerJournal = (),
                getStationTransportSamples = (),
                getStations = (),
                getTownCapacities = (),
                getTownCargoSupplyAndLimit = (),
                getTownEmission = (),
                getTownReachability = (),
                getTownTrafficRating = (),
                getTownTransportSamples = (),
                getTowns = (),
                getVehicles = (),
                getWorld = (),
                sendScriptEvent = (),
                setBuildInPauseModeAllowed = (),
                setDate = (),
                setMarker = (),
                setTownCapacities = (),
                setZone = ()
              }, ]]
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
