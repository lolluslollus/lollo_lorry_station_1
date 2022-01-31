local _constants = require('lollo_lorry_station.constants')

local _util = {
    print = function(...)
        if not(_constants.isExtendedLog) then return end

        print(...)
    end,

    debugPrint = function(whatever)
        if not(_constants.isExtendedLog) then return end
        debugPrint(whatever)
    end
}

return _util
