local logger = require('lollo_lorry_station.logger')
local results = {}

local function _getModSettings1()
    if type(game) ~= 'table' or type(game.config) ~= 'table' then return nil end
    return game.config._lolloLorryStation
end

local function _getModSettings2()
    if type(api) ~= 'table' or type(api.res) ~= 'table' or type(api.res.getBaseConfig) ~= 'table' then return end

    local baseConfig = api.res.getBaseConfig()
    if not(baseConfig) then return end

    return baseConfig._lolloLorryStation
end

results.paramValues = {
    gain = {
        allValues = { 0, 1 },
        defaultValueIndexBase0 = 1,
    }
}

local function _getDefaultGain()
    return results.paramValues.gain.allValues[results.paramValues.gain.defaultValueIndexBase0 + 1]
end

results.getGain = function()
    local modSettings = _getModSettings1() or _getModSettings2()
    if not(modSettings) then
        print('WARNING: lollo lorry station cannot read modSettings')
        return _getDefaultGain()
    end

    logger.print('modSettings =') logger.debugPrint(modSettings)
    return results.paramValues.gain.allValues[modSettings['gain'] + 1] or _getDefaultGain()
end

results.setModParamsFromRunFn = function(modParams)
    -- LOLLO NOTE if all default values are set, modParams in runFn will be an empty table,
    -- so thisModParams here will be nil
    -- In this case, we assign the default values.
    if type(game) ~= 'table' or type(game.config) ~= 'table' or modParams == nil then return end

    if type(game.config._lolloLorryStation) ~= 'table' then
        game.config._lolloLorryStation = {}
    end

    local thisModParams = modParams[getCurrentModId()]
    if type(thisModParams) == 'table'
    and type(thisModParams.gain) == 'number'
    and thisModParams.gain >= 0
    and thisModParams.gain < #results.paramValues.gain.allValues
    then
        game.config._lolloLorryStation.gain = thisModParams.gain -- LOLLO NOTE base 0 and base 1
    else
        game.config._lolloLorryStation.gain = results.paramValues.gain.defaultValueIndexBase0
    end

    logger.print('modParams =') logger.debugPrint(modParams)
    logger.print('thisModParams =') logger.debugPrint(thisModParams)
    logger.print('game.config._lolloLorryStation =') logger.debugPrint(game.config._lolloLorryStation)
end

return results