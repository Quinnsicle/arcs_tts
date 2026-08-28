local ActionCards = require("src/ActionCards")
local AmbitionMarkers = require("src/AmbitionMarkers")
local Initiative = require("src/InitiativeMarker")
local RoundManager = require("src/RoundManager")
require("src/GUIDs")
local SupplyManager = require("src/Supplies")

control_GUID = Global.getVar("control_GUID")

-- font_color = {0.8, 0.58, 0.27}, GOLD
local teal = {0.4, 0.6, 0.6}
local GREEN = {0.2, 0.5, 0.2}
local RED = {0.8, 0.3, 0.2}

-- Button Rows
-- Row 1 - {x, y, -1.17}
-- Row 2 - {x, y, -0.59}
-- Row 3 - {x, y, -0.01}
-- Row 4 - {x, y, 0.57}
-- Row 5 - {x, y, 1.15}

-- Button Columns
-- Full Col   - {0.00, y, z}
-- Left Side  - {-0.45, y, z}
-- Right Side - {0.45, y, z}

-- Dimension
-- Height - height = 260
-- Full Col - width = 820
-- Half Col - width = 440

local controls_params = {
    index = 0,
    function_owner = self,
    click_function = "doNothing",
    label = "Controls",
    height = 1,
    width = 1,
    position = {0, 0.5, -1.17},
    tooltip = "",
    font_size = 160,
    color = {0, 0, 0},
    hover_color = {0, 0, 0},
    font_color = {0.8, 0.58, 0.27}
}

local start_chapter_params = {
    index = 1,
    function_owner = self,
    click_function = "start_chapter",
    label = "Start Chapter",
    tooltip = "Deal action cards",
    height = 260,
    width = 820,
    position = {0, 0.5, -0.59},
    font_size = 90,
    font_color = {0, 0, 0},
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local end_round_params = {
    index = 2,
    function_owner = self,
    click_function = "end_round",
    label = "End Round",
    tooltip = "Cleanup action cards",
    height = 260,
    width = 590,
    position = {-0.2, 0.5, -0.01},
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local takeInitiative_params = {
    index = 3,
    function_owner = self,
    click_function = "take_initiative",
    label = "Take\nInitiative",
    height = 260,
    width = 440,
    tooltip = "",
    position = {-0.45, 0.5, 0.57},
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local seizeInitiative_params = {
    index = 4,
    height = 260,
    width = 440,
    function_owner = self,
    click_function = "seize_initiative",
    label = "Seize\nInitiative",
    tooltip = "",
    position = {0.45, 0.5, 0.57},
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local toggle_auto_end_params = {
    index = 5,
    function_owner = self,
    click_function = "toggle_auto_end",
    label = "Toggle\nAuto\nEnd",
    tooltip = "Toggle Auto End Round.\n\nPlease report any problems to the Steam Workshop or Github page",
    height = 260,
    width = 220,
    position = {0.6, 0.5, -0.01},
    font_size = 50,
    color = RED,
    hover_color = {0.34, 0.48, 0.34}
}

function onload()
    self.createButton(controls_params)
    self.createButton(start_chapter_params)
    self.createButton(end_round_params)
    self.createButton(takeInitiative_params)
    self.createButton(seizeInitiative_params)
    self.createButton(toggle_auto_end_params)
    self.createButton({
        index = 10,
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
end

function doNothing()
end

function start_chapter()

    local available_colors = {"White", "Yellow", "Red", "Teal", "Pink"}

    --------------------------------------------------------------------
    -- STEP 1: GET DECK (use ActionCards helper which scans the zone)
    --------------------------------------------------------------------
    local deck = ActionCards.get_action_deck()

    if not deck then
        LOG.ERROR("Action deck not found in action deck zone")
        return
    end

    --------------------------------------------------------------------
    -- STEP 2: SCAN FOR MANDATE CARDS
    --------------------------------------------------------------------
    local mandate_by_color = {}
    local mandate_found = false

    local objects = deck.getObjects()

    for _, obj in ipairs(objects) do
        if obj.description then
            for _, color in ipairs(available_colors) do
                if string.find(obj.description, color .. " Mandate") then
                    mandate_by_color[color] = obj.guid
                    mandate_found = true
                end
            end
        end
    end

    --------------------------------------------------------------------
    -- STEP 3: GIVE MANDATES IF THEY EXIST
    --------------------------------------------------------------------
    if mandate_found then
        for _, color in ipairs(available_colors) do
            local guid = mandate_by_color[color]

            if guid and Player[color] then
                deck.takeObject({
                    guid = guid,
                    position = Player[color].getHandTransform().position,
                    smooth = true,
                    callback_function = function(card)
                        if card then
                            card.setRotationSmooth({0, 180, 0})
                        end
                    end
                })
            end
        end
    end

    --------------------------------------------------------------------
    -- STEP 4: SHUFFLE AFTER MANDATES REMOVAL
    --------------------------------------------------------------------
    if mandate_found then
        Wait.time(function()
            if deck and deck.shuffle then
                deck.shuffle()
            end
        end, 0.3)
    end

    --------------------------------------------------------------------
    -- STEP 5: ORIGINAL GAME CHECKS
    --------------------------------------------------------------------
    if ActionCards.count_action_cards() > 0 then
        broadcastToAll(
            "There are still action cards in play, please End Round and try again.",
            Color.Red
        )
        return
    end

    Initiative.unseize()
    ActionCards.clear_face_up_discard()

    if ActionCards.check_hands() then
        return
    end

    --------------------------------------------------------------------
    -- CARTEL CHECK (protected): if any player has a '* Cartel' card in
    -- their player area, detect matching resources in other players'
    -- area zones and notify players with a reminder.
    --------------------------------------------------------------------
    do
        local ok_cartel, cartel_err = pcall(function()
            local function get_resource_key_from_name(name)
                if not name then return nil end
                local nl = string.lower(name)
                if string.find(nl, "material") then return "materials", "material" end
                if string.find(nl, "fuel") then return "fuel", "fuel" end
                if string.find(nl, "weapon") or string.find(nl, "weapons") then return "weapons", "weapon" end
                if string.find(nl, "psionic") or string.find(nl, "psionics") then return "psionics", "psionic" end
                if string.find(nl, "relic") then return "relics", "relic" end
                return nil
            end

            local cartel_owners = {}
            for colname, pdata in pairs(player_pieces_GUIDs) do
                local area_guid = pdata and pdata.area_zone
                if area_guid then
                            local zone = nil
                            local ok_get_zone, z = pcall(function() return getObjectFromGUID(area_guid) end)
                            if ok_get_zone then zone = z end
                            if zone and zone.getObjects then
                                local ok_objs, objs = pcall(function() return zone.getObjects() end)
                                if ok_objs and objs then
                                    for _, obj in ipairs(objs) do
                                        local ok, nm = pcall(function() return obj.getName and obj.getName() end)
                                        if ok and nm and string.find(string.lower(nm), "cartel") then
                                            local resource_key, match_word = get_resource_key_from_name(nm)
                                            if resource_key then
                                                cartel_owners[colname] = cartel_owners[colname] or {}
                                                table.insert(cartel_owners[colname], {cartel_name = nm, resource_key = resource_key, match_word = match_word, guid = (pcall(function() return obj.getGUID and obj.getGUID() end) and obj.getGUID and obj.getGUID() or "?")})
                                            end
                                        end
                                    end
                                else
                                    broadcastToAll("Warning: failed to read Cartel area zone for " .. tostring(colname), {1, 0.5, 0})
                                end
                            else
                                broadcastToAll("Warning: Cartel area zone not found or invalid for " .. tostring(colname), {1, 0.5, 0})
                            end
                end
            end

            local msgs = {}
            for owner_color, cartels in pairs(cartel_owners) do
                for _, info in ipairs(cartels) do
                    local cartel_name = info.cartel_name
                    local match_word = info.match_word
                    for victim_color, vdata in pairs(player_pieces_GUIDs) do
                        if victim_color ~= owner_color then
                            local vz = nil
                            local ok_get_vz, z2 = pcall(function() return getObjectFromGUID(vdata.area_zone) end)
                            if ok_get_vz then vz = z2 end
                            if vz and vz.getObjects then
                                local ok_objs2, objs2 = pcall(function() return vz.getObjects() end)
                                local found = {}
                                if ok_objs2 and objs2 then
                                    for _, o in ipairs(objs2) do
                                        local ok2, onm = pcall(function() return o.getName and o.getName() end)
                                        if ok2 and onm and string.find(string.lower(onm), match_word) then
                                            table.insert(found, o)
                                        end
                                    end
                                else
                                    broadcastToAll("Warning: failed to read victim Cartel area for " .. tostring(victim_color), {1, 0.5, 0})
                                end
                                
                                if #found > 0 then
                                    for _, robj in ipairs(found) do
                                        local robj_guid = "?"
                                        local ok_guid, g = pcall(function() return robj.getGUID and robj.getGUID() end)
                                        if ok_guid and g then robj_guid = g end
                                        local ok_name, rname = pcall(function() return robj.getName and robj.getName() end)
                                        broadcastToAll("Cartel resource reminder detected in " .. tostring(victim_color) .. ": guid=" .. tostring(robj_guid) .. " name=" .. tostring(ok_name and rname or "?"), {1, 0.5, 0})
                                    end
                                    table.insert(msgs, victim_color .. " has " .. tostring(#found) .. " " .. match_word .. "(s) in their player area because of " .. owner_color .. "'s " .. cartel_name .. ". Please return them to supply (unless Frozen).")
                                end
                            end
                        end
                    end
                end
            end

            if #msgs > 0 then
                local full = "Cartel reminder:\n"
                for _, m in ipairs(msgs) do full = full .. m .. "\n" end
                broadcastToAll(full, {1, 0.5, 0})
            end
        end)
        if not ok_cartel then
            local msg = "Error in start_chapter cartel check: " .. tostring(cartel_err)
            broadcastToAll(msg, {1, 0, 0})
            if debug and debug.traceback then
                broadcastToAll(debug.traceback(), {1, 0, 0})
            end
        end
    end

    --------------------------------------------------------------------
    -- STEP 6: DEAL CARDS (CONDITIONAL)
    --------------------------------------------------------------------
    if ActionCards.deal_hand then
        if mandate_found then
            -- mandates exist → reduce hand to keep balance (5 total feel)
            ActionCards.deal_hand(5)
        else
            -- no mandates → original rule
            ActionCards.deal_hand(6)
        end
    else
        print("ERROR: deal_hand missing in ActionCards")
    end

    --------------------------------------------------------------------
    -- STEP 7: INITIATIVE
    --------------------------------------------------------------------
    local initiative_player = Global.getVar("initiative_player")

    if initiative_player then
        broadcastToAll(initiative_player .. " will start the chapter\n", initiative_player)
        Turns.turn_color = initiative_player
        Global.setVar("turn_count", 0)
    else
        broadcastToAll(
            "\n\n!!Could not determine initiative player!!\nPlease ensure initiative marker is near a player board.\n\n"
        )
    end

    -- Remind if overlay is on
    if Global.getVar("overlay_sending_enabled") then
        broadcastToAll("Reminder: Overlay is ON - player hands are being displayed", {0.2, 0.8, 0.2})
    end
end

function end_round()
    RoundManager.endRound()
end

function toggle_auto_end()
    local toggle = Global.getVar("is_auto_end_round_enabled")

    toggle = not toggle
    Global.setVar("is_auto_end_round_enabled", toggle)

    if (toggle) then
        self.editButton({
            index = 5,
            color = GREEN,
            hover_color = {0.34, 0.48, 0.34}
        })
    else
        self.editButton({
            index = 5,
            color = RED,
            hover_color = {0.48, 0.34, 0.34}
        })
    end
end

function take_initiative(objectButtonClicked, playerColorClicked)
    Initiative.take(playerColorClicked)
end

function seize_initiative(objectButtonClicked, playerColorClicked)
    Initiative.seize(playerColorClicked)
end
