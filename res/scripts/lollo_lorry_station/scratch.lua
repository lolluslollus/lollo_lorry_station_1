package.path = package.path .. ';res/scripts/?.lua'

local dump = require('res/scripts/luadump')
local stringUtils = require('lollo_lorry_station/stringUtils')

local function isBuildingStreetSplitter(param)
    print('\n - param.proposal.toAdd = ')
    local toAdd = type(param) == 'table' and param
    and type(param.proposal) == 'userdata' and param.proposal
    and type(param.proposal.toAdd) == 'userdata' and param.proposal.toAdd
    print('- toAdd = ', dump(false)(toAdd))

    if toAdd and #toAdd > 0 then
        for i = 1, #toAdd do
            if toAdd[i].fileName == [[lollo_street_splitter.con]] then
                return true
            end
        end
    end
    return false
end

local par = { lollo = true }
print(isBuildingStreetSplitter(par))

print(not(qqqqq))
