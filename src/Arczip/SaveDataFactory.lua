local Arczip = require("src/Arczip/Arczip")
local Locations = require("src/Arczip/Locations")
local LOG = require("src/LOG")
local Campaign = require("src/Campaign")
local Resource = require("src/Resource")

-- this file is the primary communication layer between Arczip and the TTS arcs mod.
-- Arczip expects a well defined save_data structure as input and gives a well defined string as output.
-- This file is responsible for saving and loading that save_data structure based on the tts game state.

SaveDataFactory = {}

function SaveDataFactory:SavePieces(pieces)
    local objects = getAllObjects()
    for _, piece in ipairs(objects) do
        local pieceInfo = Arczip:IdentifyPiece(piece)
        if (pieceInfo) then
            if not pieces[pieceInfo.name] then
                pieces[pieceInfo.name] = {}
            end
            local piece_locations = pieces[pieceInfo.name]

            -- get all the locations that this piece is in and fiter it by the set of locations
            -- that this piece 'can' be in
            local locations = Locations:GetLocations(piece.getPosition())
            local foundLocation = nil
            for _, location in ipairs(locations) do
                if Arczip.locationLookups[pieceInfo.type].stringToIndex[location] ~= nil then
                    foundLocation = location
                    break
                end
            end

            local count = piece.getQuantity()
            if count == -1 then
                count = 1
            end

            if foundLocation then
                if piece_locations[foundLocation] == nil then
                    piece_locations[foundLocation] = count
                else
                    piece_locations[foundLocation] = piece_locations[foundLocation] + count
                end
            end
            
        end
    end
end

function SaveDataFactory:GetPieceFromSupply(piece_info)

    local function getDamageRotation(bag, piece_info)
        local rotation = bag.getRotation()
        if piece_info.state == 'Damaged' then
            rotation.z = 180
        else
            rotation.z = 0
        end
        return rotation
    end


    local result = nil
    if piece_info.color == nil then
        -- non-player piece

        -- Blight
        if piece_info.type == 'Blight' then
            local blightBag = getObjectFromGUID(Campaign.guids.blight)
            result = blightBag.takeObject({
                rotation = getDamageRotation(blightBag, piece_info),
                smooth = false
            })
        end

        -- Resources
        local IsResource = {Material = true, Fuel = true, Weapon = true, Relic = true, Psionic = true, }
        if IsResource[piece_info.type] then
            result = Resource:take(piece_info.type, nil)
        end

        -- Ambition Markers
        if piece_info.type == 'AmbitionMarker' then
            local guid = ({
                ["5/3"] = "c9e0ee", 
                ["3/2"] = "a9b02a", 
                ["2/0"] = "b0b4d0",
                ["9/4"] = "c9e0ee", 
                ["6/3"] = "a9b02a", 
                ["4/2"] = "b0b4d0",
            })[piece_info.state]
            local rotation_z = ({
                ["5/3"] = 0, 
                ["3/2"] = 0, 
                ["2/0"] = 0,
                ["9/4"] = 180, 
                ["6/3"] = 180, 
                ["4/2"] = 180,
            })[piece_info.state]

            result = getObjectFromGUID(guid)
            local rotation = result.getRotation()
            rotation.z = rotation_z
            result.setRotation(rotation)
        end
        
    elseif piece_info.color == 'Free' then
        -- Free buildings
        if piece_info.type == 'City' then
            local cityBag = getObjectFromGUID(Campaign.guids.free_cities)
            result = cityBag.takeObject({
                rotation = getDamageRotation(cityBag, piece_info),
                smooth = false
            })
        elseif piece_info.type == 'Starport' then
            local starportBag = getObjectFromGUID(Campaign.guids.free_starports)
            result = starportBag.takeObject({
                rotation = getDamageRotation(starportBag, piece_info),
                smooth = false
            })
        end
    elseif piece_info.color == 'Imperial' then
        -- Imperial ships
        local shipBag = getObjectFromGUID(Campaign.guids.imperial_ships)
        result = shipBag.takeObject({
            smooth = false,
        })
        if piece_info.state == 'Damaged' then
            result = result.setState(2)
        end
    else
        -- player piece
        local colorKey = piece_info.color
        local player_pieces_GUIDs = Global.getVar("player_pieces_GUIDs")[colorKey]

        if piece_info.type == 'City' then
            local player_area = getObjectFromGUID(player_pieces_GUIDs.area_zone)
            local in_player_area = {}
            for _, object in ipairs(player_area.getObjects()) do
                in_player_area[object.getGUID()] = true
            end

            for _, city_guid in ipairs(player_pieces_GUIDs.cities) do
                local city = getObjectFromGUID(city_guid)
                if in_player_area[city.getGUID()] and not city.isSmoothMoving() then
                    result = city
                    city.setRotation(getDamageRotation(city, piece_info))
                    break
                end
            end
        elseif piece_info.type == 'Starport' then
            local starportBag = getObjectFromGUID(player_pieces_GUIDs.starports)
            result = starportBag.takeObject({
                rotation = getDamageRotation(starportBag, piece_info),
                smooth = false
            })
        elseif piece_info.type == 'Ship' then
            local shipBag = getObjectFromGUID(player_pieces_GUIDs.ships)
            result = shipBag.takeObject({
                smooth = false,
            })
            if piece_info.state == 'Damaged' then
                result = result.setState(2)
            end
        elseif piece_info.type == 'Agent' then
            local agentBag = getObjectFromGUID(player_pieces_GUIDs.agents)
            result = agentBag.takeObject({
                smooth = false,
            })
        elseif piece_info.type == 'Flagship' then
            local FlagshipBag = getObjectFromGUID(Campaign.guids.flagships)
            local guid = ({
                Red = 'b87511', 
                White = 'f39d4a', 
                Teal = 'f6f6a4', 
                Yellow = 'a8047e'
            })[piece_info.color]

            result = FlagshipBag.takeObject({
                guid = guid,
                smooth = false
            })
        end
    end

    if result == nil then
        LOG.ERROR("piece type "..piece_info.name..
        " unrecognized by loader. It's likely this piece is just not supported yet")
    end
    return result
end

function SaveDataFactory:LoadPieces(pieces)

    for piece_name, locations in pairs(pieces) do
        local piece_info = Arczip.id_to_piece[Arczip.piece_to_id[piece_name]]
        for location, count in pairs(locations) do
            for i = 1, count do
                local piece = self:GetPieceFromSupply(piece_info)
                -- TODO: Move piece to the correct location
                Locations:MovePieceToLocation(location, piece)
            end
        end
    end
    
end

function SaveDataFactory:Save()

    local active_player_info = Global.getVar('active_players')
    -- shift active players by initiative
    local initiative_GUID = Global.getVar('initiative_GUID')
    local seized_initiative_GUID = Global.getVar('seized_initiative_GUID')
    local player_pieces_guids = Global.getVar("player_pieces_GUIDs")
    local LeadPlayer = nil
    for i, player_info in ipairs(active_player_info) do
        local area_zone = getObjectFromGUID(player_pieces_guids[player_info.color].area_zone)
        for _, object in ipairs(area_zone.getObjects()) do
            if object.guid == initiative_GUID or object.guid == seized_initiative_GUID then
                LeadPlayer = i
                break
            end
        end
    end

    local ordered_players = {}
    if LeadPlayer ~= nil then
        for i = -1, #active_player_info - 2 do
            local index = (i + LeadPlayer) % #active_player_info + 1
            table.insert(ordered_players, active_player_info[index])
        end
    end
    
    local save_data = {
        version_number = 1,
        active_clusters = {true, true, true, true, true, true},
        active_players = ordered_players,
        gamemode = 'BaseGame', -- todo: support campaign
    }

    -- set inactive clusters to false
    for _, oop_cluster in ipairs(getObjectsWithTag('oop_cluster')) do
        save_data.active_clusters[tonumber(oop_cluster.getName())] = false
    end

    -- record the location of relevant pieces
    save_data.pieces = {}
    SaveDataFactory:SavePieces(save_data.pieces)

    return save_data
end

function SaveDataFactory:Load(save_data)
    -- TODO: load inactive clusters

    -- TODO: load player order

    -- load pieces
    SaveDataFactory:LoadPieces(save_data.pieces)
end

return SaveDataFactory
