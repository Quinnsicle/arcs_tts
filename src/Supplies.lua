local LOG = require("src/LOG")
require("src/GUIDs")

local SupplyManager = {}
-- TODO
-- stack management algorithm
-- remove from game GUID

local city_row = {{0.10, 2.00, -2.00}, {0.33, 2.00, -2.00},
                  {0.56, 2.00, -2.00}, {0.79, 2.00, -2.00},
                  {1.02, 2.00, -2.00}}

local all_supplies = {

    -- Player Agents
    ["White Agent"] = {
        bag = player_pieces_GUIDs["White"]["agents"]
    },
    ["Teal Agent"] = {
        bag = player_pieces_GUIDs["Teal"]["agents"]
    },
    ["Yellow Agent"] = {
        bag = player_pieces_GUIDs["Yellow"]["agents"]
    },
    ["Red Agent"] = {
        bag = player_pieces_GUIDs["Red"]["agents"]
    },

    -- Player Fresh Ships
    ["White Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["White"]["ships"]
    },
    ["Teal Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["Teal"]["ships"]
    },
    ["Yellow Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["Yellow"]["ships"]
    },
    ["Red Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["Red"]["ships"]
    },

    -- Player Damaged Ships
    ["White Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["White"]["ships"],
        state = 1
    },
    ["Teal Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["Teal"]["ships"],
        state = 1
    },
    ["Yellow Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["Yellow"]["ships"],
        state = 1
    },
    ["Red Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["Red"]["ships"],
        state = 1
    },

    -- Player Damaged Ships
    ["White Starport"] = {
        bag = player_pieces_GUIDs["White"]["starports"],
        face_up = true
    },
    ["Teal Starport"] = {
        bag = player_pieces_GUIDs["Teal"]["starports"],
        face_up = true
    },
    ["Yellow Starport"] = {
        bag = player_pieces_GUIDs["Yellow"]["starports"],
        face_up = true
    },
    ["Red Starport"] = {
        bag = player_pieces_GUIDs["Red"]["starports"],
        face_up = true
    },

    -- Player Cities
    ["White City"] = {
        origin = player_pieces_GUIDs["White"]["player_board"],
        face_up = true,
        set = player_pieces_GUIDs["White"]["cities"],
        pos = city_row
    },
    ["Teal City"] = {
        origin = player_pieces_GUIDs["Teal"]["player_board"],
        face_up = true,
        set = player_pieces_GUIDs["Teal"]["cities"],
        pos = city_row
    },
    ["Yellow City"] = {
        origin = player_pieces_GUIDs["Yellow"]["player_board"],
        face_up = true,
        set = player_pieces_GUIDs["Yellow"]["cities"],
        pos = city_row
    },
    ["Red City"] = {
        origin = player_pieces_GUIDs["Red"]["player_board"],
        face_up = true,
        set = player_pieces_GUIDs["Red"]["cities"],
        pos = city_row
    },

    -- Resources
    ["Psionic"] = {
        pos = {0, 2, 0},
        origin = resources_markers_GUID["psionics"]
    },
    ["Relic"] = {
        pos = {0, 2, 0},
        origin = resources_markers_GUID["relics"]
    },
    ["Weapon"] = {
        pos = {0, 2, 0},
        origin = resources_markers_GUID["weapons"]
    },
    ["Fuel"] = {
        pos = {0, 2, 0},
        origin = resources_markers_GUID["fuel"]
    },
    ["Material"] = {
        pos = {0, 2, 0},
        origin = resources_markers_GUID["materials"]
    },

    -- Campaing Components
    ["Blight"] = {
        bag = blight_GUID
    },
    ["Imperial Ship (Damaged)"] = {
        bag = imperial_ships_GUID,
        state = 1
    },
    ["Imperial Ship (Fresh)"] = {
        bag = imperial_ships_GUID
    },
    ["Free City"] = {
        bag = free_cities_GUID
    },
    ["Free Starport"] = {
        bag = free_starports_GUID
    },

    -- Miscallaneous
    [""] = {
        ignore = true
    },
    ["Zero Marker"] = {
        pos = {0.938, 1.747, 1.091},
        rot = {0.00, 180.00, 0.00},
        origin = reach_board_GUID
    }
}

-- Main return
function SupplyManager.returnObject(object, is_bottom_deck)

    local deck_pos = is_bottom_deck and -1 or 1
    local supply = all_supplies[object.getName()]

    if not supply then
        LOG.ERROR("Unable to return '" .. object.getName() ..
                      "' to a supply.")
        return
    end

    -- Check for additional changes that should be made when returning to supply
    if supply.state then
        object = object.setState(supply.state)
    elseif supply.face_up and object.is_face_down then
        object.flip()
    elseif supply.face_down and not object.is_face_down then
        object.flip()
    end

    -- Complete return based on type --

    -- Ignore return
    if supply.ignore then
        return

        -- Return to bag
    elseif supply.bag then
        getObjectFromGUID(supply.bag).putObject(object)

        -- Return to deck
        -- If deck doesn't exist then put card where deck was and make it the deck
    elseif supply.deck then
        local deck = getObjectFromGUID(supply.deck)
        if deck then
            object.setPosition(supply.pos)
            object.setRotation(supply.rot)
            local new_deck = deck.putObject(object)
            if new_deck then
                supply.deck = new_deck.getGUID()
                supply.pos = new_deck.getPosition() + deck_pos *
                                 Vector(0, 2, 0)
                supply.rot = new_deck.getRotation()
            end
        else
            supply.deck = object.getGUID()
            object.setPosition(supply.pos)
            object.setRotation(supply.rot)
        end

        -- Return a set of objects to a set of positions
    elseif supply.set then
        for ct, obj_GUID in ipairs(supply.set) do
            if object.getGUID() == obj_GUID then
                local pos = supply.pos[ct]
                pos = supply.origin and
                          getObjectFromGUID(supply.origin).positionToWorld(
                        pos)
                object.setPositionSmooth(pos, false, true)
            end
        end

        -- Return an object to a position
    elseif supply.pos then
        local pos = supply.pos
        pos = supply.origin and
                  getObjectFromGUID(supply.origin).positionToWorld(pos) or
                  pos
        object.setPositionSmooth(pos, false, true)
        if (supply.rot) then
            object.setRotationSmooth(supply.rot)
        end
    end

end

-- Expanded returns
function SupplyManager.returnEverything()
    for _, i in pairs(getObjects()) do
        SupplyManager.returnObject(i)
    end
end

function SupplyManager.returnZone(zone)
    for _, i in pairs(zone.getObjects()) do
        SupplyManager.returnObject(i)
    end
end

-- Remove from game shortcut
function SupplyManager.removeFromGame(object)
    local bin = getObjectFromGUID(Global.getVar(
        "removed_from_game_GUID"))
    bin.putObject(object)
end

-- Context menu return implementation
function SupplyManager.addMenuToAllObjects()
    for _, object in pairs(getObjects()) do
        SupplyManager.addMenuToObject(object)
    end
end

function SupplyManager.addMenuToObject(object)
    -- log("Adding return context menu option to "..object.getName())
    if object.getName() ~= "" and all_supplies[object.getName()] then
        object.addContextMenuItem("Return to supply",
            SupplyManager.returnFromMenu)
        object.addContextMenuItem("Take as trophy",
            SupplyManager.trophyFromMenu)
        object.addContextMenuItem("Take as captive",
            SupplyManager.captiveFromMenu)
        if object.type == "Card" then
            object.addContextMenuItem("Card to deck bottom",
                SupplyManager.buryFromMenu)
        end
    end
end

function SupplyManager.returnFromMenu(player_color, position, object)
    for _, i in pairs(Player.getPlayers()) do
        if i.color == player_color then
            for ct, k in ipairs(i.getSelectedObjects()) do
                Wait.time(function()
                    SupplyManager.returnObject(k)
                end, (ct - 1) * 0.5)
            end
        end
    end
end

function SupplyManager.captiveFromMenu(player_color, position, object)
    local zone = getObjectFromGUID(
        player_pieces_GUIDs[player_color]["captives_zone"])
    SupplyManager.addToZone(player_color, zone, object)
end

function SupplyManager.trophyFromMenu(player_color, position, object)
    local zone = getObjectFromGUID(
        player_pieces_GUIDs[player_color]["trophies_zone"])
    SupplyManager.addToZone(player_color, zone, object)
end

function SupplyManager.addToZone(player_color, zone, object)
    local area = zone.getScale() * 0.18
    local sectors = {
        [0] = Vector({1, 0, 1}),
        [1] = Vector({-1, 0, 1}),
        [2] = Vector({-1, 0, -1}),
        [3] = Vector({1, 0, -1})
    }
    for _, i in pairs(Player.getPlayers()) do
        if i.color == player_color then
            for ct, k in ipairs(i.getSelectedObjects()) do
                local pos = Vector({area.x * math.random(), 0,
                                    area.z * math.random()})
                pos = pos * sectors[ct % 4]
                pos = zone.positionToWorld(pos)
                Wait.time(function()
                    k.setPositionSmooth(pos)
                end, (ct - 1) * .5)
            end
        end
    end
end

function SupplyManager.buryFromMenu(player_color, position, object)
    for _, i in pairs(Player.getPlayers()) do
        if i.color == player_color then
            for _, k in pairs(i.getSelectedObjects()) do
                if k.type == "Card" then
                    SupplyManager.returnObject(k, true)
                end
            end
        end
    end
end

return SupplyManager
