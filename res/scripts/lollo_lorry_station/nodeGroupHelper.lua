local sampleNodes = {
    {
        {-2, -2, 0.00000},
        {4, 0.1, 0},
        3.0
    },
    {
        {2, 0, 0.00000},
        {0.1, 4, 0},
        3.0
    },
    {
        {2, 0, 0.00000},
        {-0.1, 4, 0},
        3.0
    },
    {
        {-2, 2, 0.00000},
        {-4, 0.1, 0},
        3.0
    },
}

local _nodeGroups = {}

local _getStringFromNumber = function(num)
    local str = tostring(num)
    if str:len() == 0 then
        return '00'
    elseif str:len() == 1 then
        return '0' .. str
    else
        return str
    end
end

local nodeGroupHelper = {}

nodeGroupHelper.getMyNodeGroup = function()
    local currentFileName = debug.getinfo(2).source
    print('LOLLO nodeGroupHelper.getMyNodeGroup currentFileName = ', currentFileName)
    local fileNameEnd = string.sub(currentFileName, string.len(currentFileName) - 5)
    local id = fileNameEnd:sub(1, 2)
    return _nodeGroups[id] or {}
end

nodeGroupHelper.getNodeGroupFileName = function(integerId)
    return 'lollo_models/connectors/' .. _getStringFromNumber(integerId) .. '.mdl'
end

nodeGroupHelper.setNodeGroup = function(integerId, nodes)
    local stringId = _getStringFromNumber(integerId)
    _nodeGroups[stringId] = nodes
    _nodeGroups[stringId][3] = 3 -- lane width
end

return nodeGroupHelper