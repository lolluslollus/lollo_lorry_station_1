local _constants = require('lollo_lorry_station/constants')
local slotUtils = require('lollo_lorry_station/slotHelpers')
local matrixUtils = require('lollo_lorry_station/matrix')
local transfUtils = require('lollo_lorry_station/transfUtils')
-- local debugger = require('debugger')
local luadump = require('lollo_lorry_station/luadump')

if math.atan2 == nil then
	math.atan2 = function(dy, dx)
		local result = 0
		if dx == 0 then
			result = math.pi * 0.5
		else
			result = math.atan(dy / dx)
		end

		if dx > 0 then
			return result
		elseif dx < 0 and dy >= 0 then
			return result + math.pi
		elseif dx < 0 and dy < 0 then
			return result - math.pi
		elseif dy > 0 then
			return result
		elseif dy < 0 then
			return - result
		else return false
		end
	end
end

local helper = {}

-- helper.getNearbyStreetEdges = function(position, edgeSearchRadius)
--     -- if you want to use this, you may have to account for the transformation
--     if type(position) ~= 'table' then return {} end

--     local nearbyEdges = game.interface.getEntities(
--         {pos = position, radius = edgeSearchRadius},
--         -- {type = "BASE_EDGE", includeData = true}
--         {includeData = true}
--     )

--     local results = {}
--     for i, v in pairs(nearbyEdges) do
--         if not v.track and v.streetType then
--             table.insert(results, v)
--         end
--     end

--     return results
-- end

helper.getNearbyStreetEdges = function(transf)
    -- if you want to use this, you may have to account for the transformation
    if type(transf) ~= 'table' then return {} end

    -- debugger()
    local edgeSearchRadius = _constants.xMax * _constants.xTransfFactor -- * 0.7071
    local squareCentrePosition = transfUtils.getVec123Transformed({0, 0, 0}, transf)
    local nearbyEdges = game.interface.getEntities(
        {pos = squareCentrePosition, radius = edgeSearchRadius},
        {type = "BASE_EDGE", includeData = true}
        -- {includeData = true}
    )
    local sampleNearbyEdges = {
        [27346] = {
            ["node0pos"] = {503.47393798828, -3262.2072753906, 15.127754211426},
            ["node0tangent"] = {11.807357788086, -53.536338806152, -1.3161367177963},
            ["node1tangent"] = {39.382007598877, -39.382049560547, -1.2736799716949},
            ["type"] = "BASE_EDGE",
            ["hasTram"] = false,
            ["id"] = 27346,
            ["node1"] = 25371,
            ["track"] = false,
            ["streetType"] = "standard/country_small_new.lua",
            ["node0"] = 27343,
            ["hasBus"] = false,
            ["node1pos"] = {529.49230957031, -3309.6865234375, 13.174621582031}
        },
        [27350] = {
            ["node0pos"] = {529.49230957031, -3309.6865234375, 13.174621582031},
            ["node0tangent"] = {55.327167510986, -55.327224731445, -1.7893730401993},
            ["node1tangent"] = {15.339179992676, -76.696083068848, 2.7962200641632},
            ["type"] = "BASE_EDGE",
            ["hasTram"] = false,
            ["id"] = 27350,
            ["node1"] = 25826,
            ["track"] = false,
            ["streetType"] = "standard/country_small_new.lua",
            ["node0"] = 25371,
            ["hasBus"] = false,
            ["node1pos"] = {565.62121582031, -3377.1943359375, 13.753684997559}
        }
    }


    local results = {}
    for _, v in pairs(nearbyEdges) do
        -- LOLLO TODO make it discard paths and other unsuitable street types
        -- edges contain a field like:
        -- "streetType" = "standard/country_small_new.lua",
        if not v.track and v.streetType then
            table.insert(results, v)
        end
    end

    return results
end

-- helper.getEdgeWithSequentialFields = function(edgeWithNamedFields)
--     return {
--         {
--             edgeWithNamedFields['node0pos'],
--             edgeWithNamedFields['node1pos'],
--         },
--         {
--             edgeWithNamedFields['node0tangent'],
--             edgeWithNamedFields['node1tangent'],
--         }
--     }
-- end

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

helper.getEdgeBetween = function(node0, node1)
    -- local sign = function(n)
    --     return n > 0 and 1 or n < 0 and -1 or 1 --0
    -- end
    local x0 = node0[1][1]
    local x1 = node1[1][1]
    local cos0 = node0[2][1]
    local cos1 = node1[2][1]
    local y0 = node0[1][2]
    local y1 = node1[1][2]
    local sin0 = node0[2][2]
    local sin1 = node1[2][2]
    local theta0 = math.atan2(sin0, cos0)
    local theta1 = math.atan2(sin1, cos1)
    local z0 = node0[1][3]
    local z1 = node1[1][3]
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
            -- x0 + sign(x1 - x0) * math.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0)),
            x0 + math.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0)),
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

    local a = abcd[1][1]
    local b = abcd[2][1]
    local c = abcd[3][1]
    local d = abcd[4][1]
    -- Now I take the x2' halfway between x0' and x1',
    local x2I = x0I + (x1I - x0I) * 0.5
    local y2I = a + b * x2I + c * x2I * x2I + d * x2I * x2I * x2I
    -- calculate its y derivative:
    local tan2I = b + 2 * c * x2I + 3 * d * x2I * x2I
    -- Now I undo the rotation I did at the beginning
    local ro2 = math.sqrt((x2I - x0I) * (x2I - x0I) + (y2I - y0I) * (y2I - y0I))
    local alpha2I = math.atan2(y2I - y0I, x2I - x0I)
    local theta2I = math.atan(tan2I) -- LOLLO TODO find out the quadrant or try to use atan2, which does it automagically

    local edge2WithAbsoluteCoordinates = {
        {
            x0I + ro2 * math.cos(alpha2I - zRotation),
            y0I + ro2 * math.sin(alpha2I - zRotation),
            0
        },
        {
            math.cos(theta2I - zRotation),
            math.sin(theta2I - zRotation),
            0
        }
    }
    -- add Z
    local z2 = game.interface.getHeight({edge2WithAbsoluteCoordinates[1][1], edge2WithAbsoluteCoordinates[1][2]})
    edge2WithAbsoluteCoordinates[1][3] = z2
    edge2WithAbsoluteCoordinates[2][3] = (node0[2][3] + node1[2][3]) * 0.5

    return edge2WithAbsoluteCoordinates
end

return helper