local LOG = require("src/LOG")
require("src/GUIDs")

local SupplyManager = {}
-- Map player color names to broadcast RGB colors (values 0..1)
local PLAYER_BROADCAST_COLOR = {
    White = {1, 1, 1},
    Red = {1, 0, 0},
    Yellow = {1, 1, 0},
    Teal = {0, 0.8, 0.8},
    Pink = {1, 0.4, 0.7},
    Blue = {0.2, 0.6, 1},
    Green = {0.0, 0.8, 0.0},
    Orange = {1, 0.6, 0.0},
    Purple = {0.6, 0.2, 0.8},
    Brown = {0.5, 0.3, 0.1},
    Grey = {0.7, 0.7, 0.7},
    Black = {0.0, 0.0, 0.0}
}
-- TODO
-- stack management algorithm
-- remove from game GUID

local city_row = {{0.10, 2.00, -2.00}, {0.33, 2.00, -2.00},
                  {0.56, 2.00, -2.00}, {0.79, 2.00, -2.00},
                  {1.02, 2.00, -2.00}}

local all_supplies = {
    -- Player Agents
    ["White Agent"] = {
        bag = player_pieces_GUIDs["White"]["agents"],
        mini_bag = player_pieces_GUIDs["White"]["mini_agents"]
    },
    ["Teal Agent"] = {
        bag = player_pieces_GUIDs["Teal"]["agents"],
        mini_bag = player_pieces_GUIDs["Teal"]["mini_agents"]
    },
    ["Yellow Agent"] = {
        bag = player_pieces_GUIDs["Yellow"]["agents"],
        mini_bag = player_pieces_GUIDs["Yellow"]["mini_agents"]
    },
    ["Red Agent"] = {
        bag = player_pieces_GUIDs["Red"]["agents"],
        mini_bag = player_pieces_GUIDs["Red"]["mini_agents"]
    },

    -- Player Fresh Ships
    ["White Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["White"]["ships"],
        mini_bag = player_pieces_GUIDs["White"]["mini_ships"]
    },
    ["Teal Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["Teal"]["ships"],
        mini_bag = player_pieces_GUIDs["Teal"]["mini_ships"]
    },
    ["Yellow Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["Yellow"]["ships"],
        mini_bag = player_pieces_GUIDs["Yellow"]["mini_ships"]
    },
    ["Red Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["Red"]["ships"],
        mini_bag = player_pieces_GUIDs["Red"]["mini_ships"]
    },

    -- Player Damaged Ships
    ["White Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["White"]["ships"],
        mini_bag = player_pieces_GUIDs["White"]["mini_ships"],
        state = 1
    },
    ["Teal Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["Teal"]["ships"],
        mini_bag = player_pieces_GUIDs["Teal"]["mini_ships"],
        state = 1
    },
    ["Yellow Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["Yellow"]["ships"],
        mini_bag = player_pieces_GUIDs["Yellow"]["mini_ships"],
        state = 1
    },
    ["Red Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["Red"]["ships"],
        mini_bag = player_pieces_GUIDs["Red"]["mini_ships"],
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
    -- all pinks
    -- Player Agents
    ["Pink Agent"] = {
        bag = player_pieces_GUIDs["Pink"]["agents"],
        mini_bag = player_pieces_GUIDs["Pink"]["mini_agents"]
    },

    -- Player Fresh Ships
    ["Pink Ship (Fresh)"] = {
        bag = player_pieces_GUIDs["Pink"]["ships"],
        mini_bag = player_pieces_GUIDs["Pink"]["mini_ships"]
    },

    -- Player Damaged Ships
    ["Pink Ship (Damaged)"] = {
        bag = player_pieces_GUIDs["Pink"]["ships"],
        mini_bag = player_pieces_GUIDs["Pink"]["mini_ships"],
        state = 1
    },

    -- Player Starport
    ["Pink Starport"] = {
        bag = player_pieces_GUIDs["Pink"]["starports"],
        face_up = true
    },

    -- Player Cities
    ["Pink City"] = {
        origin = player_pieces_GUIDs["Pink"]["player_board"],
        face_up = true,
        set = player_pieces_GUIDs["Pink"]["cities"],
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

    -- Campaign Components
    ["Blight"] = {
        bag = blight_GUID
    },
    ["Imperial Ship (Damaged)"] = {
        bag = imperial_ships_GUID,
        mini_bag = mini_imperial_ships_GUID
    },
    ["Imperial Ship (Fresh)"] = {
        bag = imperial_ships_GUID,
        mini_bag = mini_imperial_ships_GUID
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
function SupplyManager.returnObject(object, is_bottom_deck, returning_player_color)

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

    elseif supply.mini_bag then
        local regular_bag_exists = getObjectFromGUID(supply.bag)
        if regular_bag_exists then
            regular_bag_exists.putObject(object)
        else
            getObjectFromGUID(supply.mini_bag).putObject(object)
        end

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
                -- If this is a City being returned to its supply, lower it in Z
                local ok_name, nm = pcall(function() return object.getName() end)
                -- if ok_name and nm and string.find(nm, "City") then
                --     pcall(function()
                --         if pos.z then pos.z = pos.z - 1.64 end
                --     end)
                -- end
                object.setPositionSmooth(pos, false, true)
                -- Broadcast to all players that the city was returned and instruct placement
                if ok_name and nm and string.find(nm, "City") then
                    -- determine owner color from the city's name (e.g., 'White City' -> 'White')
                    local owner_color = nil
                    local nm_lower = string.lower(nm)
                    for colname, _ in pairs(player_pieces_GUIDs) do
                        if string.find(nm_lower, string.lower(colname)) then
                            owner_color = colname
                            break
                        end
                    end

                    local msg
                    if owner_color then
                        msg = "Returned " .. tostring(nm) .. " to its supply. The " .. tostring(owner_color) .. " player should place it in the rightmost city slot; resources may be rearranged."
                    else
                        msg = "Returned " .. tostring(nm) .. " to its supply. The player who returned it should place it in the rightmost city slot; resources may be rearranged."
                    end

                    -- choose broadcast color based on the owner (who gets the city back)
                    local col = {r=0.8, g=0.8, b=0.8}
                    if owner_color and PLAYER_BROADCAST_COLOR[owner_color] then
                        local c = PLAYER_BROADCAST_COLOR[owner_color]
                        col = {r=c[1], g=c[2], b=c[3]}
                    end
                    broadcastToAll(msg, col)
                end
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
            -- Add 'Discard' option for tagged court cards (Guild, Vox, Lore)
            pcall(function()
                if object.hasTag and (object.hasTag("Guild") or object.hasTag("Vox") or object.hasTag("Lore")) then
                    object.addContextMenuItem("Discard",
                        SupplyManager.discardToCourtFromMenu)
                end
            end)
        end
    end
    -- Add special context menu for Material Cartel cards so user can place
    -- the materials disk above the card.
    local ok, name = pcall(function() return object.getName and object.getName() end)
    if ok and name then
        local nl = string.lower(name)
        -- detect any '* Cartel' cards and add a context menu to place the matching marker
        if string.find(nl, "cartel") then
            -- choose a resource key based on the cartel name
            local resource_key
            if string.find(nl, "material") then
                resource_key = "materials"
            elseif string.find(nl, "fuel") then
                resource_key = "fuel"
            elseif string.find(nl, "weapon") or string.find(nl, "weapons") then
                resource_key = "weapons"
            elseif string.find(nl, "psionic") or string.find(nl, "psionics") then
                resource_key = "psionics"
            elseif string.find(nl, "relic") then
                resource_key = "relics"
            end
            if resource_key then
                pcall(function()
                    object.addContextMenuItem("Place supply on card",
                        function(player_color, position, obj) SupplyManager.placeResourceMarkerOnCard(player_color, position, obj) end)
                    -- allow returning the resource marker to its initial origin
                    object.addContextMenuItem("Return supply",
                        function(player_color, position, obj) SupplyManager.returnResourceMarkerToOrigin(player_color, position, obj) end)
                end)
            end
        end
    end

    -- Also ensure any Card with Guild/Vox/Lore tags gets a 'Discard' menu
    pcall(function()
        if object.type == "Card" and object.hasTag then
            local is_tagged = object.hasTag("Guild") or object.hasTag("Vox") or object.hasTag("Lore")
            if is_tagged then
                -- Avoid adding duplicate when the card is already in all_supplies
                local in_supplies = false
                local ok_name, nm = pcall(function() return object.getName and object.getName() end)
                if ok_name and nm and nm ~= "" and all_supplies[nm] then in_supplies = true end
                if not in_supplies then
                    object.addContextMenuItem("Discard", SupplyManager.discardToCourtFromMenu)
                end
            end
        end
    end)

    -- If the card is Sworn Guardians, add bury-to-court option
    pcall(function()
        if object.type == "Card" and object.getName then
            local ok, nm = pcall(function() return object.getName() end)
            if ok and nm then
                if string.lower(nm) == string.lower("SWORN GUARDIANS") then
                    object.addContextMenuItem("Bury into Court Deck", SupplyManager.burySwornGuardiansFromMenu)
                end
            end
        end
    end)
end

-- Generic handler: move the resource marker (from resources_markers_GUID)
-- above the provided card and also move any object that was sitting on top
-- the marker to remain stacked.
function SupplyManager.placeResourceMarkerOnCard(player_color, position, object)
    if not object or not object.getName then return end
    local name = object.getName()
    if not name then return end
    local nl = string.lower(name)
    if not string.find(nl, "cartel") then return end

    local resource_key
    if string.find(nl, "material") then
        resource_key = "materials"
    elseif string.find(nl, "fuel") then
        resource_key = "fuel"
    elseif string.find(nl, "weapon") or string.find(nl, "weapons") then
        resource_key = "weapons"
    elseif string.find(nl, "psionic") or string.find(nl, "psionics") then
        resource_key = "psionics"
    elseif string.find(nl, "relic") then
        resource_key = "relics"
    end
    if not resource_key then
        LOG.ERROR("Unknown cartel resource for card: " .. tostring(name))
        return
    end

    local marker_guid = resources_markers_GUID and resources_markers_GUID[resource_key]
    if not marker_guid then
        LOG.ERROR("Resource marker GUID not configured for " .. tostring(resource_key))
        return
    end

    local marker = getObjectFromGUID(marker_guid)
    if not marker then
        LOG.ERROR("Resource marker object not found (GUID=" .. tostring(marker_guid) .. ")")
        return
    end

    -- record current marker position (if present) so we can move stacked objects
    local ok_old, old_pos = pcall(function() return marker.getPosition() end)

    -- target position above the card
    local above = {0, 1.8, 0}
    local target_pos = object.positionToWorld(above)
    pcall(function() marker.setPositionSmooth(target_pos) end)
    if marker.setRotation then pcall(function() marker.setRotationSmooth({0, 90, 0}) end) end

    -- If we have an old marker position, move any objects that were on top of it
    if ok_old and old_pos then
        for _, candidate in ipairs(getObjects()) do
            if candidate.getGUID and candidate.getGUID() ~= marker.getGUID() and candidate.getGUID() ~= object.getGUID() then
                local ok2, cpos = pcall(function() return candidate.getPosition() end)
                if ok2 and cpos then
                    local dx = math.abs(cpos.x - old_pos.x)
                    local dz = math.abs(cpos.z - old_pos.z)
                    local dy = cpos.y - old_pos.y
                    if dx <= 0.6 and dz <= 0.6 and dy > 0.05 then
                        local rel_y = dy
                        local new_pos = {target_pos[1], target_pos[2] + rel_y, target_pos[3]}
                        pcall(function() candidate.setPositionSmooth(new_pos) end)
                    end
                end
            end
        end
    end
end

-- Move the materials marker (resources_markers_GUID["materials"]) above the
-- selected card. Callback signature: (player_color, position, object)
function SupplyManager.placeMaterialsOnCard(player_color, position, object)
    if not object or not object.getName then return end
    local mat_guid = resources_markers_GUID and resources_markers_GUID["materials"]
    if not mat_guid then
        LOG.ERROR("materials GUID not configured")
        return
    end
    local mat_obj = getObjectFromGUID(mat_guid)
    if not mat_obj then
        LOG.ERROR("Materials marker object not found (GUID=" .. tostring(mat_guid) .. ")")
        return
    end

    -- Move the materials disk above the card (0, 1.8, 0) in card-local coordinates
    local above = {0, 1.8, 0}
    local target_pos = object.positionToWorld(above)
    mat_obj.setPositionSmooth(target_pos)
    -- ensure marker is oriented upright
    if mat_obj.setRotation then
        mat_obj.setRotationSmooth({0, 90, 0})
    end
    -- Also move any object that was sitting on top of the materials marker
    -- so it stays on top of the marker after the move.
    local ok, mat_pos = pcall(function() return mat_obj.getPosition() end)
    if not ok or not mat_pos then return end

    for _, candidate in ipairs(getObjects()) do
        if candidate.getGUID and candidate.getGUID() ~= mat_obj.getGUID() and candidate.getGUID() ~= object.getGUID() then
            local ok2, cpos = pcall(function() return candidate.getPosition() end)
            if ok2 and cpos then
                local dx = math.abs(cpos.x - mat_pos.x)
                local dz = math.abs(cpos.z - mat_pos.z)
                local dy = cpos.y - mat_pos.y
                -- consider it 'on top' if horizontally very close and vertically above the marker
                if dx <= 0.6 and dz <= 0.6 and dy > 0.05 then
                    -- preserve the vertical offset relative to the marker
                    local rel_y = dy
                    local new_pos = {target_pos[1], target_pos[2] + rel_y, target_pos[3]}
                    pcall(function()
                        candidate.setPositionSmooth(new_pos)
                    end)
                end
            end
        end
    end
end


-- Return a resource marker to its configured origin coordinates and move any stacked objects with it.
function SupplyManager.returnResourceMarkerToOrigin(player_color, position, object)
    if not object or not object.getName then return end
    local name = object.getName()
    if not name then return end
    local nl = string.lower(name)
    if not string.find(nl, "cartel") then return end

    local resource_key
    if string.find(nl, "material") then
        resource_key = "materials"
    elseif string.find(nl, "fuel") then
        resource_key = "fuel"
    elseif string.find(nl, "weapon") or string.find(nl, "weapons") then
        resource_key = "weapons"
    elseif string.find(nl, "psionic") or string.find(nl, "psionics") then
        resource_key = "psionics"
    elseif string.find(nl, "relic") then
        resource_key = "relics"
    end
    if not resource_key then
        LOG.ERROR("Unknown cartel resource for card: " .. tostring(name))
        return
    end

    local marker_guid = resources_markers_GUID and resources_markers_GUID[resource_key]
    if not marker_guid then
        LOG.ERROR("Resource marker GUID not configured for " .. tostring(resource_key))
        return
    end

    local marker = getObjectFromGUID(marker_guid)
    if not marker then
        LOG.ERROR("Resource marker object not found (GUID=" .. tostring(marker_guid) .. ")")
        return
    end

    -- map resource keys to their initial world coordinates (from user)
    local origins = {
        materials = {-16.17, 1.00, -8.98},
        fuel = {-16.18, 1.00, -6.83},
        weapons = {-16.14, 1.00, -4.81},
        relics = {-16.09, 1.00, -2.84},
        psionics = {-16.08, 1.00, -0.82}
    }

    local target_pos = origins[resource_key]
    if not target_pos then
        LOG.ERROR("No origin coordinates configured for " .. tostring(resource_key))
        return
    end

    -- record old marker position so stacked objects can be moved with it
    local ok_old, old_pos = pcall(function() return marker.getPosition() end)

    pcall(function() marker.setPositionSmooth(target_pos) end)
    if marker.setRotation then pcall(function() marker.setRotationSmooth({0, 90, 0}) end) end

    -- Move any objects that were sitting on top of the marker to remain stacked.
    if ok_old and old_pos then
        for _, candidate in ipairs(getObjects()) do
            if candidate.getGUID and candidate.getGUID() ~= marker.getGUID() and candidate.getGUID() ~= object.getGUID() then
                local ok2, cpos = pcall(function() return candidate.getPosition() end)
                if ok2 and cpos then
                    local dx = math.abs(cpos.x - old_pos.x)
                    local dz = math.abs(cpos.z - old_pos.z)
                    local dy = cpos.y - old_pos.y
                    if dx <= 0.6 and dz <= 0.6 and dy > 0.05 then
                        local rel_y = dy
                        local new_pos = {target_pos[1], target_pos[2] + rel_y, target_pos[3]}
                        pcall(function() candidate.setPositionSmooth(new_pos) end)
                    end
                end
            end
        end
    end
end


-- Move a tagged court card to the court discard zone. Callback signature:
-- (player_color, position, object)
function SupplyManager.discardToCourtFromMenu(player_color, position, object)
    if not object then return end
    local court_discard = getObjectFromGUID(court_discard_zone_GUID)
    if not court_discard then
        LOG.ERROR("Court discard zone not found: " .. tostring(court_discard_zone_GUID))
        return
    end
    pcall(function()
        object.setPositionSmooth(court_discard.getPosition() + Vector({0, 3, 0}))
        if object.setRotationSmooth then
            object.setRotationSmooth(Vector({0, 270, 0}))
        end
    end)
end

-- Bury the Sworn Guardians into the court deck (attempt to put into the base court deck,
-- fallback to moving to the court deck zone).
function SupplyManager.burySwornGuardiansFromMenu(player_color, position, object)
    if not object then return end

    -- Prefer the deck currently in the court deck zone
    local court_zone = getObjectFromGUID(court_deck_zone_GUID)
    if court_zone and court_zone.getObjects then
        local objs = court_zone.getObjects()
        for _, obj in ipairs(objs) do
            if obj and obj.tag == "Deck" and obj.putObject then
                pcall(function()
                    obj.putObject(object)
                end)
                return
            end
        end
    end

    -- If no deck in zone, fall back to configured base court deck GUID
    local base_guid = (Global and Global.getVar and Global.getVar("base_court_deck_GUID")) or base_court_deck_GUID
    local ok_base, base_deck = pcall(function() return base_guid and getObjectFromGUID(base_guid) end)
    if ok_base and base_deck and base_deck.putObject then
        pcall(function()
            base_deck.putObject(object)
        end)
        return
    end

    -- final fallback: move the card to the court deck zone position
    if court_zone then
        pcall(function()
            object.setPositionSmooth(court_zone.getPosition() + Vector({0, 3, 0}))
            if object.setRotationSmooth then object.setRotationSmooth(Vector({0, 270, 0})) end
        end)
    else
        LOG.ERROR("Unable to find court deck or zone to bury Sworn Guardians")
    end
end

function SupplyManager.returnFromMenu(player_color, position, object)
    for _, i in pairs(Player.getPlayers()) do
        if i.color == player_color then
            for ct, k in ipairs(i.getSelectedObjects()) do
                Wait.time(function()
                    SupplyManager.returnObject(k, nil, player_color)
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
    local area = Vector({0.18, 0, 0.18})
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
