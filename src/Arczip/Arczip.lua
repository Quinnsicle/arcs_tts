

-- This library adds support for reading and loading the arczip save format.
-- arczip is a univerally applicable save format for arcs games so that applications
-- can transfer arcs save state freely.
local Log = require("src/LOG")

function piece_to_string(piece)
    if piece.type == nil then return 'Empty' end

    retult = ''

    if piece.color == nil then
        result = result .. 'token_'
    else
        result = result .. piece.color:lower() .. '_'
    end

    result = result .. piece.type:lower()

    if piece.state ~= nil then
        result = result .. '_'
        result = result .. piece.state:lower()
    end

    return result
end

local arczip = { 
    piece_to_id = {}, 
    id_to_piece = {},
    Locations = {
        Map = {
            FloatingMap = {
                Planets = {
                    { 'Planet_1⮝', 'Planet_1☾', 'Planet_1⬢', },
                    { 'Planet_2⮝', 'Planet_2☾', 'Planet_2⬢', },
                    { 'Planet_3⮝', 'Planet_3☾', 'Planet_3⬢', },
                    { 'Planet_4⮝', 'Planet_4☾', 'Planet_4⬢', },
                    { 'Planet_5⮝', 'Planet_5☾', 'Planet_5⬢', },
                    { 'Planet_6⮝', 'Planet_6☾', 'Planet_6⬢', },
                },
                Gates = { 'Gate_1','Gate_2', 'Gate_3', 'Gate_4', 'Gate_5', 'Gate_6', },
                TwistedPassage = 'TwistedPassage',
            },
            BuildingSlots = {
                { { '1⮝A', '1⮝B', },  { '1☾A', },          { '1⬢A','1⬢B', },   },
                { { '2⮝A', },          { '2☾A', },          { '2⬢A','2⬢B', },   },
                { { '3⮝A', },          { '3☾A', },          { '3⬢A','3⬢B', },   },
                { { '4⮝A', '4⮝B', },  { '4☾A', '4☾B', },   { '4⬢A', },          },
                { { '5⮝A',  },         { '5☾A',  },         { '5⬢A','5⬢B', },   },
                { { '6⮝A', },          { '6☾A', '6☾B', },   { '6⬢A', },         },
            },
        },
        PlayerBoards = {
            ResourceSlots = {
                Red = {'Red_R1','Red_R2','Red_R3','Red_R4','Red_R5','Red_R6', },
                White = {'White_R1','White_R2','White_R3','White_R4','White_R5','White_R6', },
                Teal = {'Teal_R1','Teal_R2','Teal_R3','Teal_R4','Teal_R5','Teal_R6', },
                Yellow = {'Yellow_R1','Yellow_R2','Yellow_R3','Yellow_R4','Yellow_R5','Yellow_R6', },
            },
            Trophies = {
                Red ='Red_Trophies', 
                White = 'White_Trophies', 
                Teal = 'Teal_Trophies', 
                Yellow = 'Yellow_Trophies',
            },
            Captives = {
                Red = 'Red_Captives', 
                White = 'White_Captives', 
                Teal = 'Teal_Captives', 
                Yellow = 'Yellow_Captives',
            },

            -- holds guild cards and other 'owned' items with no specified location
            Table = {
                Red = 'Red_Table', 
                White = 'White_Table', 
                Teal = 'Teal_Table', 
                Yellow = 'Yellow_Table',
            }
        },
        Court = { 'Court1', 'Court2', 'Court3', 'Court4', 'Court5' },
        Ambitions = { 'Tycoon', 'Tyrant', 'Warlord', 'Keeper', 'Empath'},

    },

    -- because different pieces can be stored in a different set of locations,
    -- we ID their locations separately. so we don't exceed 63 unique locations for each piece type
    -- note that 'supplies' are not considered locations because pieces are assumed to be in the supply if nowhere else
    PieceLocations = {
        Ship = { 'FloatingMap', 'Trophies', },
        Blight = { 'FloatingMap', 'Trophies', },
        City = { 'Map', 'Trophies', },
        Starport = { 'Map', 'Trophies', },
        Agent = { 'Captives', 'Trophies', 'Table', 'Court'}, -- 'Table' stores favors
        Flagship = { 'FloatingMap'},

        Material = {'ResourceSlots', 'Tycoon'},
        Fuel = {'ResourceSlots', 'Tycoon'},
        Weapon = {'ResourceSlots', 'Warlord'},
        Relic = {'ResourceSlots', 'Keeper'},
        Psionic = {'ResourceSlots', 'Empath'},

        AmbitionMarker = {'Ambitions'},
    },

    locationLookups = {},
    
    location_id = {},
    location_name = {},

    player_order = {
        id_to_order = {
            { "Red", "White", "Teal", "Yellow" },
            { "Red", "White", "Yellow", "Teal" },
            { "Red", "Teal", "White", "Yellow" },
            { "Red", "Teal", "Yellow", "White" },
            { "Red", "Yellow", "White", "Teal" },
            { "Red", "Yellow", "Teal", "White" },
            { "White", "Red", "Teal", "Yellow" },
            { "White", "Red", "Yellow", "Teal" },
            { "White", "Teal", "Red", "Yellow" },
            { "White", "Teal", "Yellow", "Red" },
            { "White", "Yellow", "Red", "Teal" },
            { "White", "Yellow", "Teal", "Red" },
            { "Teal", "Red", "White", "Yellow" },
            { "Teal", "Red", "Yellow", "White" },
            { "Teal", "White", "Red", "Yellow" },
            { "Teal", "White", "Yellow", "Red" },
            { "Teal", "Yellow", "Red", "White" },
            { "Teal", "Yellow", "White", "Red" },
            { "Yellow", "Red", "White", "Teal" },
            { "Yellow", "Red", "Teal", "White" },
            { "Yellow", "White", "Red", "Teal" },
            { "Yellow", "White", "Teal", "Red" },
            { "Yellow", "Teal", "Red", "White" },
            { "Yellow", "Teal", "White", "Red" },
            { "Red", "White", "Teal" },
            { "Red", "White", "Yellow" },
            { "Red", "Teal", "White" },
            { "Red", "Teal", "Yellow" },
            { "Red", "Yellow", "White" },
            { "Red", "Yellow", "Teal" },
            { "White", "Red", "Teal" },
            { "White", "Red", "Yellow" },
            { "White", "Teal", "Red" },
            { "White", "Teal", "Yellow" },
            { "White", "Yellow", "Red" },
            { "White", "Yellow", "Teal" },
            { "Teal", "Red", "White" },
            { "Teal", "Red", "Yellow" },
            { "Teal", "White", "Red" },
            { "Teal", "White", "Yellow" },
            { "Teal", "Yellow", "Red" },
            { "Teal", "Yellow", "White" },
            { "Yellow", "Red", "White" },
            { "Yellow", "Red", "Teal" },
            { "Yellow", "White", "Red" },
            { "Yellow", "White", "Teal" },
            { "Yellow", "Teal", "Red" },
            { "Yellow", "Teal", "White" },
            { "Red", "White" },
            { "Red", "Teal" },
            { "Red", "Yellow" },
            { "White", "Red" },
            { "White", "Teal" },
            { "White", "Yellow" },
            { "Teal", "Red" },
            { "Teal", "White" },
            { "Teal", "Yellow" },
            { "Yellow", "Red" },
            { "Yellow", "White" },
            { "Yellow", "Teal" },
        },
        order_to_id = {}
    },
}

local characters =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()+,./:;<>[]{}"

local baseEncoding = {}

function arczip:CreateLocationLookup(location_keys)

    local result = {
        stringToIndex = {},
        indexToString = {}
    }

    local locationsSet = {}
    for _, location in ipairs(location_keys) do
        locationsSet[location] = true
    end

    local location_index = 1
    function InitLocationsRec(dict, include)
        for k,v in pairs(dict) do
            local include_key = include
            if locationsSet[k] == true then
                include_key = true
            end
            if type(v) == 'string' then
                if include_key or locationsSet[v] then
                    if (location_index > (#characters - 1)) then
                        Log.ERROR(location_index .. ' exceeded maximum number of locations that a piece can be')
                    end
                    result.stringToIndex[v] = location_index
                    result.indexToString[location_index] = v
                    location_index = location_index + 1
                end
            else
                InitLocationsRec(v, include_key)
            end
        end
    end
    InitLocationsRec(self.Locations, false)

    return result
end

function baseEncoding:encode(number)
    return characters:sub(number + 1, number + 1)
end

function baseEncoding:decode(char) return characters:find(char, 1, true) - 1 end

function arczip.CreatePieceInfo(color, type, state, unique)

    local name = tostring(type)
    if color then
        name = color..' '..name
    end
    if state then
        name = name..' ('..state..')'
    end

    local PieceInfo = { 
        color = color, 
        type = type, 
        state = state, 
        unique = unique,
        name = name
    }
    
    return PieceInfo
end

-- gets the piece info associated with an object if there is one
function arczip:IdentifyPiece(object)
    local name = object.getName()
    for _, piece in pairs(self.id_to_piece) do
        local match = piece.type ~= nil

        if match and piece.tts_name ~= nil then
            if piece.tts_name ~= object.getName() then
                match = false
            end
        end

        if match and piece.tts_guids ~= nil then
            local found = false
            for _, guid in ipairs(piece.tts_guids) do
                if object.getGUID() == guid then
                    found = true
                    break
                end
            end
            if not found then
                match = false
            end
        end

        if match and piece.tts_flip == false then
            local rotation = object.getRotation()
            if rotation.z > 90 and rotation.z < 270 then
                match = false
            end
        end

        if match and piece.tts_flip == true then
            local rotation = object.getRotation()
            if rotation.z <= 90 or rotation.z >= 270 then
                match = false
            end
        end


        if match then
            return piece
        end
    end
    return nil
end

function arczip:EmptyPiece()
    return self.id_to_piece['A']
end

function arczip:init()
    for piece, locations in pairs(self.PieceLocations) do
        self.locationLookups[piece] = arczip:CreateLocationLookup(locations)
    end

    for id, order in ipairs(self.player_order.id_to_order) do
        local player_order_string = JSON.encode(order)
        self.player_order.order_to_id[player_order_string] = id
    end
 
    local id_index = 0
    local function addPiece(piece)
        self.piece_to_id[piece.name] = id_index
        self.id_to_piece[id_index] = piece
        id_index = id_index + 1
        return piece
    end

    local piece = addPiece(arczip.CreatePieceInfo(nil, nil, nil, nil, nil)) -- add the empty id

    for i, color in ipairs({ 'Red', 'White', 'Teal', 'Yellow' }) do

        -- Player Buildings
        for _, type in ipairs({ 'City', 'Starport' }) do
            for _, state in ipairs({ 'Fresh', 'Damaged' }) do
                piece = addPiece(arczip.CreatePieceInfo(color, type, state, true))
                piece.tts_name = color..' '..type
                piece.tts_flip = state == 'Damaged'
            end
        end

        -- Player Ships
        for _, state in ipairs({ 'Fresh', 'Damaged' }) do
            piece = addPiece(arczip.CreatePieceInfo(color, 'Ship', state, false))
            piece.tts_name = color..' Ship ('..state..')'
        end

        -- Player Agents
        piece = addPiece(arczip.CreatePieceInfo(color, 'Agent', nil, true))
        piece.tts_name = color..' Agent'

        -- Player Flagships
        piece = addPiece(arczip.CreatePieceInfo(color, 'Flagship', nil, true))
        piece.tts_guids = ({{'b87511'}, {'f39d4a'}, {'f6f6a4'}, {'a8047e'}})[i]
    end

    -- Free Buildings
    for _, type in ipairs({ 'City', 'Starport' }) do
        for _, state in ipairs({ 'Fresh', 'Damaged' }) do
            piece = addPiece(arczip.CreatePieceInfo('Free', type, state, true))
            piece.tts_name = 'Free '..type
            piece.tts_flip = state == 'Damaged'
        end
    end

    -- Imperial Ships
    for _, state in ipairs({ 'Fresh', 'Damaged' }) do
        piece = addPiece(arczip.CreatePieceInfo('Imperial', 'Ship', state, false))
        
        if state == 'Damaged' then
            piece.tts_name = 'Imperial Ship (Damaged)'
        else
            piece.tts_name = 'Imperial Ship'
        end
    end

    -- Blight
    for _, state in ipairs({ 'Fresh', 'Damaged' }) do
        piece = addPiece(arczip.CreatePieceInfo(nil, 'Blight', state, false))
        piece.tts_name = 'Blight'
        piece.tts_flip = state == 'Damaged'
    end

    -- Resources
    for _, Resource in ipairs({'Material', 'Fuel', 'Weapon', 'Relic', 'Psionic', }) do
        piece = addPiece(arczip.CreatePieceInfo(nil, Resource, nil, false))
        piece.tts_name = Resource
    end

    -- Ambition Markers
    piece = addPiece(arczip.CreatePieceInfo(nil, 'AmbitionMarker', "5/3", true))
    piece.tts_flip = false
    piece.tts_guids = {'c9e0ee'}
    piece = addPiece(arczip.CreatePieceInfo(nil, 'AmbitionMarker', "9/4", true))
    piece.tts_flip = true
    piece.tts_guids = {'c9e0ee'}
    
    piece = addPiece(arczip.CreatePieceInfo(nil, 'AmbitionMarker', "3/2", true))
    piece.tts_flip = false
    piece.tts_guids = {'a9b02a'}
    piece = addPiece(arczip.CreatePieceInfo(nil, 'AmbitionMarker', "6/3", true))
    piece.tts_flip = true
    piece.tts_guids = {'a9b02a'}
    
    piece = addPiece(arczip.CreatePieceInfo(nil, 'AmbitionMarker', "2/0", true))
    piece.tts_flip = false
    piece.tts_guids = {'b0b4d0'}
    piece = addPiece(arczip.CreatePieceInfo(nil, 'AmbitionMarker', "4/2", true))
    piece.tts_flip = true
    piece.tts_guids = {'b0b4d0'}
    
end

arczip:init()

local runLengthEncoding = {}

function runLengthEncoding:isNumChar(char) 
    return char:match("%w") ~= nil 
end

function runLengthEncoding:encode(data_string)
    local result = ""
    local counter = 1
    function checkCounter()
        -- if counter == 1 then
        --    result = result..result:sub(#result, #result)
        if counter > 1 then
            result = result..tostring(counter)
            counter = 1
        end
    end

    for i = 1, #data_string do

        local prevCharacter = nil
        if #result > 0 then
            prevCharacter = result:sub(#result, #result)
        end

        local character = data_string:sub(i,i)
        if character == prevCharacter then
            counter = counter + 1
        else
            checkCounter()
            result = result..data_string:sub(i,i)
        end
    end
    checkCounter()
    return result
end

function runLengthEncoding:decode(data_string)
    while true do
        local found_begin = nil
        local found_end = nil
        found_begin, found_end = string.find(data_string, "%d+")
        if not found_begin then return data_string end

        local letter = string.sub(data_string, found_begin - 1, found_begin - 1)
        local number = tonumber(string.sub(data_string, found_begin, found_end))
        local before = string.sub(data_string, 1, found_begin - 2)
        local after = string.sub(data_string, found_end + 1)

        local during = string.rep(letter, number)

        data_string = before .. during .. after
    end
    return data_string
end

function arczip:readSome(data_string, index, count)
    local result = string.sub(data_string, index, index + count - 1)
    index = index + count
    return result, index
end

function arczip:readPiece(data_string, index)
    local id, index = self:readSome(data_string, index, 1)
    return self.id_to_piece[id], index
end

function arczip:readBitset(data_string, index)
    local val, index = self:readSome(data_string, index, 1)
    val = baseEncoding:decode(val)
    return arczip:intToBitset(val), index
end

function arczip:intToBitset(int)
    local result = { false, false, false, false, false, false }
    for i = 6, 1, -1 do
        result[i] = (int % 2) == 1
        int = math.floor(int / 2)
    end
    return result
end

function arczip:bitsetToInt(bitset)
    local result = 0
    for i, bit in ipairs(bitset) do
        if bit == 1 or bit == true then
            result = result + 2^(#bitset - i)
        end
    end
    return result
end

local function tables_equal(t1, t2)
    if #t1 ~= #t2 then return false end
    for i = 1, #t1 do if t1[i] ~= t2[i] then return false end end
    return true
end

function arczip:readEncoded(data_string, index)
    local result
    result, index = self:readSome(data_string, index, 1)
    result = baseEncoding:decode(result)
    return result, index
end


function arczip:decode(data_string)
    -- strip away runLengthEncoding to make parsing easier
    data_string = runLengthEncoding:decode(data_string)

    local index = 1

    local result = {}

    -- read version number
    result.version_number, index = self:readEncoded(data_string, index)

    -- read bitset of active clusters
    result.active_clusters, index = self:readBitset(data_string, index)

    -- determine gamemodeAAAA
    result.gamemode = 'BaseGame'
    if tables_equal(result.active_clusters, { 0, 0, 0, 0, 0, 0 }) then
        result.active_clusters = { 1, 1, 1, 1, 1, 1 }
        result.gamemode = 'Campaign'
    end

    -- read active players
    local player_order_id = nil
    player_order_id, index = self:readEncoded(data_string, index)
    local player_order = self.player_order.id_to_order[player_order_id]
    result.active_players = {}
    if player_order then
        for _, color in ipairs(player_order) do
            local arcs_player = ArcsPlayer:new{
                color = color
            }
            table.insert(result.active_players, arcs_player)
        end
    end
    

    result.pieces = {}
    for _, pieceType in ipairs(self.id_to_piece) do
        local read = nil
        read, index = self:readEncoded(data_string, index)
        while read ~= 0 do

            -- lookup the location of this piece by id
            local lookupTable = self.locationLookups[pieceType.type].indexToString
            local location = lookupTable[read]

            -- increment counter
            if not result.pieces[pieceType.name] then
                result.pieces[pieceType.name] = {}
            end
            if not result.pieces[pieceType.name][location] then
                result.pieces[pieceType.name][location] = 1
            else
                result.pieces[pieceType.name][location] = result.pieces[pieceType.name][location] + 1
            end

            read, index = self:readEncoded(data_string, index)
        end

        data_string = data_string..baseEncoding:encode(0)
    end

    return result
end

function arczip:encode(data)
    local data_string = ""

    -- write version number
    data_string = data_string..baseEncoding:encode(1)
    
    -- Write bitset of active clusters
    data_string = data_string..baseEncoding:encode(self:bitsetToInt(data.active_clusters))

    -- write player order
    local player_order = {}
    for _, player_info in ipairs(data.active_players) do
        table.insert(player_order, player_info.color)
    end
    local player_order_string = JSON.encode(player_order)
    local player_order_id = self.player_order.order_to_id[player_order_string]
    if player_order_id == nil then
        -- unknown player order
        player_order_id = 0
    end
    data_string = data_string..baseEncoding:encode(player_order_id)

    -- in order by piece type, record the location of every piece
    for _, pieceType in ipairs(self.id_to_piece) do
        local locations = data.pieces[pieceType.name]
        if locations then
            for location, count in pairs(locations) do
                local locationIndex = self.locationLookups[pieceType.type].stringToIndex[location]
                for i = 1, count do
                    -- encode repetitive data for now. run length encoding will clean it up with repetition counts
                    data_string = data_string..baseEncoding:encode(locationIndex)
                end
            end
        end
        data_string = data_string..baseEncoding:encode(0)
    end

    -- shorten with runLengthEncoding
    data_string = runLengthEncoding:encode(data_string)
    return data_string
end

return arczip
