local _constants = require('lollo_lorry_station/constants')
local slotUtils = require('lollo_lorry_station/slotHelpers')
local matrixUtils = require('lollo_lorry_station/matrix')
local transfUtils = require('lollo_lorry_station/transfUtils')
local debugger = require('debugger')
local luadump = require('lollo_lorry_station/luadump')

local helper = {}

helper.getNearbyStreetEdges = function(position, edgeSearchRadius)
    -- if you want to use this, you may have to account for the transformation
    if type(position) ~= 'table' then return {} end
    
    -- local nearbyNodes = game.interface.getEntities(
    --     {pos = entity.position, radius = _constants.edgeSearchRadius},
    --     {type = "BASE_NODE", includeData = true}
    --     -- {type = "CONSTRUCTION", includeData = true, fileName = _constants.constructionFileName}
    -- )

    local nearbyEdges = game.interface.getEntities(
        {pos = position, radius = edgeSearchRadius},
        -- {type = "BASE_EDGE", includeData = true}
        {includeData = true}
    )

    debugger()

    local results = {}
    for i, v in pairs(nearbyEdges) do
        if not v.track and v.streetType then
            table.insert(results, v)
        end
    end

    return results
end

helper.getStreetEdgesSquareBySquare = function(transf)
    -- transf is an absolute transformation, which contains the absolute coordinates in 13, 14, 15
    if type(transf) ~= 'table' then return {} end

    local results = {}
    -- LOLLO NOTE 0.7071 looks until the edges (circle outside the square), 0.5 neglects them (circle inside the square):
    -- it turns out this is not critical, coz we can only find the base edges and those are rectangles with the road inside.
    -- They can extend quite a bit outside the road.
    -- As a consequence, instead of following the road closely, we have rectangles that start and end
    -- at lane switchers (ie edge ends).
    -- To mitigate this, we use a finer mesh. Best would be to use some different tech here.
    local searchRadius = math.max(_constants.xTransfFactor, _constants.yTransfFactor) * 0.7071 * 0.1 --0.5
    -- searchRadius = 0.0
    print('LOLLO getStreetEdgesSquareBySquare starting')
    print('LOLLO searchRadius =', searchRadius)
    print('LOLLO transf = ')
    luadump(true)(transf)

    for x = _constants.xMin, _constants.xMax do
        for y = _constants.yMin, _constants.yMax do
            local squarePosition = {
                x * _constants.xTransfFactor,
                y * _constants.yTransfFactor,
                0
            }
            squarePosition = transfUtils.getVec123Transformed(squarePosition, transf)
            squarePosition[3] = game.interface.getHeight({squarePosition[1], squarePosition[2]}) or transf[15]
            local nearbyStreetEdges = game.interface.getEntities(
                {pos = squarePosition, radius = searchRadius},
                {type = "BASE_EDGE", includeData = true}
            )
            -- LOLLO TODO make it discard paths and other unsuitable street types
            -- print('LOLLO x = ', x, ' y = ', y)
            -- print('LOLLO squarePosition =')
            -- luadump(true)(squarePosition)
            -- print('LOLLO nearbyStreetEdges =')
            -- luadump(true)(nearbyStreetEdges)
            -- LOLLO NOTE #nearbyStreetEdges always returns 0 coz the table is not numbered, so I must iterate.
            -- This is a major caveat of lua's.
            for _, v in pairs(nearbyStreetEdges) do
                slotUtils.setValueInNestedTable(results, v, x, y)

                -- -- returns -1 for a normal chunk of road in the countryside
                -- local con = api.engine.streetConnectorSystem.getConstructionEntityForEdge(v.id)
                -- -- returns -1 for a normal chunk of road in the countryside
                -- local edge = api.engine.streetSystem.getEdgeForEdgeObject(v.id)
            end
        end
    end

    -- print('LOLLO results = ')
    -- luadump(true)(results)
    return results
end

helper.getXKey = function(x)
    return tostring(x)
    -- return _constants.xPrefix .. tostring(x)
end

helper.getYKey = function(y)
    return tostring(y)
    -- return _constants.yPrefix .. tostring(y)
end

helper.getEdgeBetween = function(edge0, edge1)
    local sign = function(n)
        return n > 0 and 1 or n < 0 and -1 or 0
    end
    local x0 = edge0[1][1]
    local x1 = edge1[1][1]
    local cos0 = edge0[2][1]
    local cos1 = edge1[2][1]
    local y0 = edge0[1][2]
    local y1 = edge1[1][2]
    local sin0 = edge0[2][2]
    local sin1 = edge1[2][2]
    local theta0 = math.atan2(sin0, cos0)
    local theta1 = math.atan2(sin1, cos1)
    -- rotate the edges around the Z axis so that y0 = y1
    local zRotation = -math.atan2(y1 - y0, x1 - x0)
    local edge0Rotated = {
        {
            x0,
            y0,
            0
        },
        {
            math.cos(theta0 + zRotation),
            math.sin(theta0 + zRotation),
            0
        }
    }
    local edge1Rotated = {
        {
            x0 + sign(x1 - x0) * math.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0)),
            y0,
            0
        },
        {
            math.cos(theta1 + zRotation),
            math.sin(theta1 + zRotation),
            0
        }
    }
    local x0I = edge0Rotated[1][1]
    local x1I = edge1Rotated[1][1]
    local cos0I = edge0Rotated[2][1]
    local cos1I = edge1Rotated[2][1]
    local y0I = edge0Rotated[1][2]
    local y1I = edge1Rotated[1][2]
    local sin0I = edge0Rotated[2][2]
    local sin1I = edge1Rotated[2][2]
    local theta0I = math.atan2(sin0I, cos0I)
    local theta1I = math.atan2(sin1I, cos1I)

    -- Now I can solve the system:
    -- a + b x0' + c x0'^2 + d x0'^3 = y0'
    -- a + b x1' + c x1'^2 + d x1'^3 = y0'
    -- b + 2 c x0' + 3 d x0'^2 = sin0' / cos0'
    -- b + 2 c x1' + 3 d x1'^2 = sin1' / cos1'
    local abcd = matrixUtils.mul(
        matrixUtils.invert(
            {
                {1, x0I, x0I * x0I, x0I * x0I * x0I},
                {1, x1I, x1I * x1I, x1I * x1I * x1I},
                {0, 1, 2 * x0I, 3 * x0I * x0I},
                {0, 1, 2 * x1I, 3 * x1I * x1I}
            }
        ),
        {
            {y0I},
            {y0I},
            {sin0I / cos0I},
            {sin1I / cos1I}
        }
    )

    -- Now I take the x2' halfway between x0' and x1',
    local x2I = x0I + (x1I - x0I) * 0.5
    local y2I = abcd[1] + abcd[2] * x2I + abcd[3] * x2I * x2I + abcd[4] * x2I * x2I * x2I
    -- calculate its y derivative:
    local tan2I = abcd[2] + 2 * abcd[3] * x2I + 3 * abcd[4] * x2I * x2I
    local ro2 = math.sqrt((x2I - x0I) * (x2I - x0I) + (y2I - y0I) * (y2I - y0I))
    local alpha2I = math.atan2(y2I - y0I, x2I - x0I)
    local theta2I = math.atan(tan2I) -- LOLLO TODO find out the quadrant or try to use atan2, which does it automagically

    -- Now I undo the rotation I did at the beginning
    local edge2 = {
        {
            ro2 * math.cos(alpha2I - zRotation),
            ro2 * math.sin(alpha2I - zRotation),
            0
        },
        {
            math.cos(theta1 - zRotation),
            math.sin(theta1 - zRotation),
            0
        }
    }
    -- add Z
    -- LOLLO TODO uncomment after testing
    -- edge2[1][3] = game.interface.getHeight({edge2[1][1], edge2[1][2]})
    edge2[2][3] = (edge0[2][3] + edge1[2][3]) * 0.5

    return edge2
end

return helper