local PolarCoordinates = require("src/Arczip/PolarCoordinates")
local Arczip = require('src/Arczip/Arczip')
local LOG = require("src/LOG")
local Merchant = require('src/Merchant')

Locations = {
    cluster_angles = {
        2.052557, 0.7417785, -0.1325305, -1.055315, -2.449816, 3.012656
    },
    planet_angles = {
        2.052557, 1.57182, 1.120667, 0.7417785, 0.4169267, 0.1276975,
        -0.1325305, -0.4081573, -0.7228218, -1.055315, -1.560048, -2.017114,
        -2.449816, -2.73055, -3.006387, 3.012656, 2.736147, 2.418476
    },
    radii = {2.6, 4.7, 13}
}

function PointWithinBounds(object, position)
    local bounds = object.getBoundsNormalized()
    local minX = bounds.center.x - 0.5 * bounds.size.x
    local maxX = bounds.center.x + 0.5 * bounds.size.x
    local minZ = bounds.center.z - 0.5 * bounds.size.z
    local maxZ = bounds.center.z + 0.5 * bounds.size.z

    return position.x > minX and position.x < maxX and position.z > minZ and position.z < maxZ
end

function Locations:GetLocations(position)
    local result = {}

    -- check if position is at a building slot
    local building_slot_tolorance = 0.1
    local cluster_zone_guids = Global.getVar("cluster_zone_GUIDs")
    for cluster_id, cluster in ipairs(cluster_zone_GUIDs) do
        for system_id, planet in ipairs({cluster.a, cluster.b, cluster.c}) do
            for slot, building_zone_guid in ipairs(planet.buildings) do
                local building_zone = getObjectFromGUID(building_zone_guid)
                local zone_position = building_zone.getPosition()
                local distance = Vector(zone_position):sqrDistance(position)
                if distance < building_slot_tolorance then
                    table.insert(result, Arczip.Locations.Map.BuildingSlots[cluster_id][system_id][slot])
                    break
                end
            end
        end
    end

    -- look on the map first
    local map = getObjectFromGUID(Global.getVar("reach_board_GUID"))

    -- check if position is in a system
    if PointWithinBounds(map, position) then

        local polar = PolarCoordinates:FromWorld(position)
        if polar.radius < Locations.radii[1] then
            -- twisted passage
            table.insert(result, Arczip.Locations.Map.FloatingMap.TwistedPassage)
        elseif polar.radius < Locations.radii[2] then
            -- gate
            local thetaA
            local thetaB
            for i = 0, #Locations.cluster_angles + 1 do
                thetaA = Locations.cluster_angles[i % #Locations.cluster_angles + 1]
                thetaB = Locations.cluster_angles[(i + 1) % #Locations.cluster_angles + 1]
                if thetaA < thetaB then thetaB = thetaB - 2 * math.pi end

                local objTheta = polar.theta
                if thetaA < 0 and thetaB < 0 and objTheta > 0 then
                    objTheta = objTheta - 2 * math.pi
                end

                if (objTheta < thetaA and objTheta > thetaB) then
                    local cluster = i % #Locations.cluster_angles + 1
                    table.insert(result, Arczip.Locations.Map.FloatingMap.Gates[cluster])
                    break
                end
            end

        elseif polar.radius < Locations.radii[3] then
            -- planet
            local thetaA
            local thetaB
            for i = 0, #Locations.planet_angles + 1 do
                thetaA = Locations.planet_angles[i % #Locations.planet_angles + 1]
                thetaB = Locations.planet_angles[(i + 1) % #Locations.planet_angles + 1]
                if thetaA < thetaB then thetaB = thetaB - 2 * math.pi end

                local objTheta = polar.theta
                if thetaA < 0 and thetaB < 0 and objTheta > 0 then
                    objTheta = objTheta - 2 * math.pi
                end

                if (objTheta < thetaA and objTheta > thetaB) then
                    local system = i % 3 + 1
                    local cluster = math.floor(i / 3) % 6 + 1
                    table.insert(result, Arczip.Locations.Map.FloatingMap.Planets[cluster][system])
                    break
                end
            end
        end
    end


    local player_pieces_GUIDs = Global.getVar("player_pieces_GUIDs")
    
    -- check if position is in a resource slot
    local resource_offsets = {
        Vector(-4.34, 0.02, 1.05), 
        Vector(-3.09, 0.02, 1.05), 
        Vector(-1.84, 0.02, 1.05), 
        Vector(-0.59, 0.02, 1.05), 
        Vector( 0.66, 0.02, 1.05), 
        Vector( 1.91, 0.02, 1.05),
    }
    local resource_slot_tolorance = 0.1
    for color, pieces in pairs(player_pieces_GUIDs) do
        local board = getObjectFromGUID(pieces.player_board)
        -- only check slots if resource is on the player board
        if PointWithinBounds(board, position) then
            for slot_index, offset in ipairs(resource_offsets) do
                local slot_position = offset + board.getPosition()
                
                local distance = Vector(slot_position):sqrDistance(position)
                if distance < resource_slot_tolorance then
                    table.insert(result, Arczip.Locations.PlayerBoards.ResourceSlots[color][slot_index])
                    break
                end
            end
        end
    end

    -- check if position is in a trophy box
    for color, pieces in pairs(player_pieces_GUIDs) do
        local trophies_zone = getObjectFromGUID(pieces.trophies_zone)
        if PointWithinBounds(trophies_zone, position) then
            table.insert(result, Arczip.Locations.PlayerBoards.Trophies[color])
        end
    end

    -- check if position is in a captives box
    local player_pieces_GUIDs = Global.getVar("player_pieces_GUIDs")
    for color, pieces in pairs(player_pieces_GUIDs) do
        local captives_zone = getObjectFromGUID(pieces.captives_zone)
        if PointWithinBounds(captives_zone, position) then
            table.insert(result, Arczip.Locations.PlayerBoards.Captives[color])
        end
    end

    local player_pieces_GUIDs = Global.getVar("player_pieces_GUIDs")
    for color, pieces in pairs(player_pieces_GUIDs) do
        local area_zone = getObjectFromGUID(pieces.area_zone)
        if PointWithinBounds(area_zone, position) then
            table.insert(result, Arczip.Locations.PlayerBoards.Table[color])
        end
    end

    -- TODO: Court

    -- check if position is in an Ambition Box
    local map_position = map.getPosition()
    local ambition_half_width = 2.68
    local ambition_half_height = 0.81
    local ambition_x = map_position.x + 14.8
    local ambitions_z = {
        map_position.z +  4.28,
        map_position.z +  1.95,
        map_position.z + -0.38,
        map_position.z + -2.71,
        map_position.z + -5.04,
    }
    if position.x > ambition_x - ambition_half_width and position.x < ambition_x + ambition_half_width then
        for ambition_index, ambition_z in ipairs(ambitions_z) do
            if position.z > ambition_z - ambition_half_height and position.z < ambition_z + ambition_half_height then
                table.insert(result, Arczip.Locations.Ambitions[ambition_index])
            end
        end
    end


    return result
end

function Locations:getSystem(position)

    local polar = PolarCoordinates:FromWorld(position)

    if polar.radius < Locations.radii[1] then
        -- twisted passage
        return {
            name = 'twisted_passage', 
            cluster = 7, 
            system = 1
        }
    elseif polar.radius < Locations.radii[2] then
        -- gate
        local thetaA
        local thetaB
        for i = 0, #Locations.cluster_angles + 1 do
            thetaA = Locations.cluster_angles[i % #Locations.cluster_angles + 1]
            thetaB = Locations.cluster_angles[(i + 1) % #Locations.cluster_angles + 1]
            if thetaA < thetaB then thetaB = thetaB - 2 * math.pi end

            local objTheta = polar.theta
            if thetaA < 0 and thetaB < 0 and objTheta > 0 then
                objTheta = objTheta - 2 * math.pi
            end

            if (objTheta < thetaA and objTheta > thetaB) then
                local cluster = i % #Locations.cluster_angles + 1
                return {
                    name = 'gate_' .. tostring(cluster),
                    cluster = cluster,
                    system = 4
                }
            end
        end

    elseif polar.radius < Locations.radii[3] then
        -- planet
        local thetaA
        local thetaB
        for i = 0, #Locations.planet_angles + 1 do
            thetaA = Locations.planet_angles[i % #Locations.planet_angles + 1]
            thetaB = Locations.planet_angles[(i + 1) % #Locations.planet_angles + 1]
            if thetaA < thetaB then thetaB = thetaB - 2 * math.pi end

            local objTheta = polar.theta
            if thetaA < 0 and thetaB < 0 and objTheta > 0 then
                objTheta = objTheta - 2 * math.pi
            end

            if (objTheta < thetaA and objTheta > thetaB) then
                local system = i % 3 + 1
                local cluster = math.floor(i / 3) % 6 + 1
                return {
                    name = cluster..'_'..system,
                    cluster = cluster,
                    system = system
                }
            end
        end
    end
    return nil
end

function Locations:groupObjectsBySystem(objects)
    local result = {
        { {}, {}, {}, {} }, { {}, {}, {}, {} }, { {}, {}, {}, {} }, { {}, {}, {}, {} },
        { {}, {}, {}, {} }, { {}, {}, {}, {} }, { {} }
    }
    for _, object in ipairs(objects) do
        local system = Locations:getSystem(object.getPosition())
        if system then
            table.insert(result[system.cluster][system.system], object)
        end
    end
    return result
end

function Locations:HighlightSystem(position)
    local vectorLines = {}

    local polar = PolarCoordinates:FromWorld(position)

    if polar.radius < Locations.radii[1] then
        -- twisted passage
        local density = 60
        local theta = Locations.cluster_angles[1]
        for i = 1, density do
            local a = {radius = 0, theta = theta}
            local b = {radius = Locations.radii[1], theta = theta}
            table.insert(vectorLines, {
                points = {
                    PolarCoordinates:ToWorld(a), PolarCoordinates:ToWorld(b)
                },
                color = {1, 1, 0.3, 0.3},
                thickness = 0.1,
                rotation = {0, 0, 0}
            })
            theta = theta - ((2 * math.pi) / density)
        end
    elseif polar.radius < Locations.radii[2] then
        -- gate
        local density = 120
        local thetaA
        local thetaB
        for i = 0, #Locations.cluster_angles + 1 do
            thetaA = Locations.cluster_angles[i % #Locations.cluster_angles + 1]
            thetaB = Locations.cluster_angles[(i + 1) % #Locations.cluster_angles + 1]
            if thetaA < thetaB then thetaB = thetaB - 2 * math.pi end

            local objTheta = polar.theta
            if thetaA < 0 and thetaB < 0 and objTheta > 0 then
                objTheta = objTheta - 2 * math.pi
            end

            if (objTheta < thetaA and objTheta > thetaB) then break end
        end

        local theta = thetaA
        while theta > thetaB do
            local a = {radius = Locations.radii[1], theta = theta}
            local b = {radius = Locations.radii[2], theta = theta}
            table.insert(vectorLines, {
                points = {
                    PolarCoordinates:ToWorld(a), PolarCoordinates:ToWorld(b)
                },
                color = {1, 1, 0.3, 0.3},
                thickness = 0.1,
                rotation = {0, 0, 0}
            })
            theta = theta - ((2 * math.pi) / density)
        end
    elseif polar.radius < Locations.radii[3] then
        -- planet
        local density = 360
        local thetaA
        local thetaB
        for i = 0, #Locations.planet_angles + 1 do
            thetaA = Locations.planet_angles[i % #Locations.planet_angles + 1]
            thetaB = Locations.planet_angles[(i + 1) % #Locations.planet_angles + 1]
            if thetaA < thetaB then thetaB = thetaB - 2 * math.pi end

            local objTheta = polar.theta
            if thetaA < 0 and thetaB < 0 and objTheta > 0 then
                objTheta = objTheta - 2 * math.pi
            end

            if (objTheta < thetaA and objTheta > thetaB) then break end
        end

        local theta = thetaA
        while theta > thetaB do
            local a = {radius = Locations.radii[2], theta = theta}
            local b = {radius = Locations.radii[3], theta = theta}
            table.insert(vectorLines, {
                points = {
                    PolarCoordinates:ToWorld(a), PolarCoordinates:ToWorld(b)
                },
                color = {1, 1, 0.3, 0.3},
                thickness = 0.1,
                rotation = {0, 0, 0}
            })
            theta = theta - ((2 * math.pi) / density)
        end
    end
    return vectorLines
end

local createdBags = {}

local _MovePieceMethods = nil
function GetMovePieceMethods()
    
    local function MoveToPlanet(location, piece)
        LOG.DEBUG('MoveToPlanet('..location..', '..piece.getName()..')')
        local cluster_zone_guids = Global.getVar("cluster_zone_GUIDs")
        local clusterNum = tonumber(location:sub(8,8))
        local planetKey = ({['⮝'] = 'a', ['☾'] = 'b', ['⬢'] = 'c', })[location:sub(9,9)]
        local zone = getObjectFromGUID(cluster_zone_guids[clusterNum][planetKey].ships)
        
        local bag = createdBags[location]

        if not bag then
            local template = getObjectFromGUID('fd842b')
            local position = zone.getPosition()
            position.y = 0.5
            bag = template.clone({
                position = position,
            })
            bag.setLock(false)
            bag.setName('')
            createdBags[location] = bag
        end
        Wait.frames(
            function()
                bag.call('AddObject', {object = piece})
            end, 1)
    end

    local function MoveToGate(location, piece)
        LOG.DEBUG('MoveToGate('..location..', '..piece.getName()..')')
        local cluster_zone_guids = Global.getVar("cluster_zone_GUIDs")
        local clusterNum = tonumber(location:sub(6,6))
        local zone = getObjectFromGUID(cluster_zone_guids[clusterNum].gate)
        
        local bag = createdBags[location]

        if not bag then
            local template = getObjectFromGUID('fd842b')
            local position = zone.getPosition()
            position.y = 0.92
            bag = template.clone({
                position = position,
            })
            bag.setLock(false)
            bag.setName('')
            createdBags[location] = bag
        end
        Wait.frames(
            function()
                bag.call('AddObject', {object = piece})
            end, 1)
    end

    local function MoveToTwistedPassage(location, piece)
        LOG.DEBUG('MoveToTwistedPassage('..location..', '..piece.getName()..')')
    end

    local function MoveToBuildingSlot(location, piece)
        LOG.DEBUG('MoveToBuildingSlot('..location..', '..piece.getName()..')')
        local cluster_zone_guids = Global.getVar("cluster_zone_GUIDs")
        local clusterNum = tonumber(location:sub(1,1))
        local planetKey = ({['⮝'] = 'a', ['☾'] = 'b', ['⬢'] = 'c', })[location:sub(2,2)]
        local slotNum = ({['A'] = 1, ['B'] = 2 })[location:sub(3,3)]
        local zone = getObjectFromGUID(cluster_zone_guids[clusterNum][planetKey].buildings[slotNum])
        piece.setPositionSmooth(zone.getPosition(), false, false)
    end

    local function MoveToResourceSlot(location, piece)
        LOG.DEBUG('MoveToResourceSlot('..location..', '..piece.getName()..')')
        local player_color = location:match("%w+")
        local slot_num = tonumber(location:sub(#location, #location))
        local player = ArcsPlayer:new({color = player_color})
        local slot_pos = player.resource_slot_pos[slot_num]

        local player_pieces_GUIDs = Global.getVar('player_pieces_GUIDs')
        local player_board = getObjectFromGUID(player_pieces_GUIDs[player_color].player_board)

        piece.setPositionSmooth(player_board.positionToWorld(slot_pos), false, false)
    end

    local function MoveToTrophies(location, piece)
        LOG.DEBUG('MoveToTrophies('..location..', '..piece.getName()..')')
    end

    local function MoveToCaptives(location, piece)
        LOG.DEBUG('MoveToCaptives('..location..', '..piece.getName()..')')
    end

    local function MoveToTable(location, piece)
        LOG.DEBUG('MoveToTable('..location..', '..piece.getName()..')')
    end

    local function MoveToCourtSlot(location, piece)
        LOG.DEBUG('MoveToPlanet('..location..', '..piece.getName()..')')
    end

    local function MoveToAmbition(location, piece)
        LOG.DEBUG('MoveToAmbition('..location..', '..piece.getName()..')')

        local reach_board_GUID = Global.getVar('reach_board_GUID')
        local board = getObjectFromGUID(reach_board_GUID)
        local merchant_pos = Merchant.ambition_pos[piece.getName():lower()]
        if merchant_pos then
            piece.setPositionSmooth(board.positionToWorld(merchant_pos), false, false)
            return
        end

        local offset_x = {
            ['c9e0ee'] = 16.28 - 2.81,
            ['a9b02a'] = 17.61 - 2.81,
            ['b0b4d0'] = 18.94 - 2.81,
        }
        local offset_z = {
            Tycoon = 3.64 + 0.64,
            Tyrant = 1.31 + 0.64,
            Warlord = -1.02 + 0.64,
            Keeper = -3.35 + 0.64,
            Empath = -5.68 + 0.64,
        }
        local offset_y = .5

        local offset = Vector(offset_x[piece.getGUID()], offset_y, offset_z[location])
         
        piece.setPositionSmooth(board.getPosition() + offset, false, false)
    end

    local MethodsMap = {
        Map = {
            FloatingMap = {
                Planets = MoveToPlanet,
                Gates = MoveToGate,
                TwistedPassage = MoveToTwistedPassage,
            },
            BuildingSlots = MoveToBuildingSlot,
        },
        PlayerBoards = {
            ResourceSlots = MoveToResourceSlot,
            Trophies = MoveToTrophies,
            Captives = MoveToCaptives,
            Table = MoveToTable,
        },
        Court = MoveToCourtSlot,
        Ambitions = MoveToAmbition
    }

    if _MovePieceMethods == nil then
        _MovePieceMethods = {}
        
        function Helper(Locations, MethodsMap)
            
            if type(Locations) == 'string' then
                _MovePieceMethods[Locations] = MethodsMap
                return
            end

            for k,v in pairs(Locations) do
                local methodsSubMap = MethodsMap
                if type(MethodsMap) == 'table' then
                    methodsSubMap = MethodsMap[k]
                end
                Helper(v, methodsSubMap)
            end
        end
        Helper(Arczip.Locations, MethodsMap)
    end
    return _MovePieceMethods
end

function Locations:MovePieceToLocation(location, piece)
    GetMovePieceMethods()[location](location, piece)
end

return Locations
