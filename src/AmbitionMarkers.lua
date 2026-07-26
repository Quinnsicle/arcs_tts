-- Used in all aspects of manipulating zero marker and 3 ambition markers
require("src/GUIDs")

local ambitionMarkers = {}

local action_cards = require("src/ActionCards")
local ArcsPlayer = require("src/ArcsPlayer")
local Log = require("src/LOG")

-- is_face_down = false = lower (teal) side is face up
-- is_face_down = true  = higher (yellow) side is face up
local markers = {
    {
        object = getObjectFromGUID(ambition_marker_GUIDs[1]),
        column_pos = Vector({-0.83, 0.2, -1.07}),
        [false] = {
            first_power = 5,
            second_power = 3,
            power_desc = "5 / 3 power"
        },
        [true] = {
            first_power = 9,
            second_power = 4,
            power_desc = "9 / 4 power"
        }
    }, {
        object = getObjectFromGUID(ambition_marker_GUIDs[2]),
        column_pos = Vector({-0.92, 0.2, -1.07}),
        [false] = {
            first_power = 3,
            second_power = 2,
            power_desc = "3 / 2 power"
        },
        [true] = {
            first_power = 6,
            second_power = 3,
            power_desc = "6 / 3 power"
        }
    }, {
        object = getObjectFromGUID(ambition_marker_GUIDs[3]),
        column_pos = Vector({-1.00, 0.21, -1.07}),
        [false] = {
            first_power = 2,
            second_power = 0,
            power_desc = "2 / 0 power"
        },
        [true] = {
            first_power = 4,
            second_power = 2,
            power_desc = "4 / 2 power"
        }
    },   {
        object = getObjectFromGUID(ambition_marker_GUIDs[4]),
        column_pos = Vector({-0.83, 0.2, -1.07}),
        [true] = {
            first_power = 6,
            second_power = 4,
            third_power = 2,
            power_desc = "6 / 4 / 2 power"
        },
        [false] = {
            first_power = 10,
            second_power = 5,
            third_power = 3,
            power_desc = "10 / 5 / 3 power"
        }
    }, {
        object = getObjectFromGUID(ambition_marker_GUIDs[5]),
        column_pos = Vector({-0.92, 0.2, -1.07}),
        [true] = {
            first_power = 4,
            second_power = 2,
            third_power = 1,
            power_desc = "4 / 2 / 1 power"
        },
        [false] = {
            first_power = 7,
            second_power = 4,
            third_power = 2,
            power_desc = "7 / 4 / 2 power"
        }
    }, {
        object = getObjectFromGUID(ambition_marker_GUIDs[6]),
        column_pos = Vector({-1.00, 0.21, -1.07}),
        [false] = {
            first_power = 3,
            second_power = 1,
            third_power = 0,
            power_desc = "3 / 1 / 0 power"
        },
        [true] = {
            first_power = 5,
            second_power = 2,
            third_power = 1,
            power_desc = "5 / 2 / 1 power"
        }
    }
}

local ambitions = {
    {
        name = "Undeclared",
        row_pos = Vector({0, 0, -0.01})
    }, {
        name = "Tycoon",
        row_pos = Vector({0, 0, 0.35})
    }, {
        name = "Tyrant",
        row_pos = Vector({0, 0, 0.74})
    }, {
        name = "Warlord",
        row_pos = Vector({0, 0, 1.12})
    }, {
        name = "Keeper",
        row_pos = Vector({0, 0, 1.5})
    }, {
        name = "Empath",
        row_pos = Vector({0, 0, 1.91})
    }
}

local last_declared_marker = nil
local zero_button_hidden = false
local zero_button_menu_attached = false

function ambitionMarkers:is_zero_button_hidden()
    return zero_button_hidden or Global.getVar("zero_marker_button_hidden") or false
end

function ambitionMarkers:set_zero_button_hidden(hidden)
    zero_button_hidden = hidden
    if Global and Global.setVar then
        Global.setVar("zero_marker_button_hidden", hidden)
    end
    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    if not zero_marker then
        return
    end

    if hidden then
        if zero_marker.clearButtons then
            zero_marker.clearButtons()
        elseif zero_marker.getButtons then
            local buttons = zero_marker.getButtons() or {}
            for index, button in ipairs(buttons) do
                if button and button.click_function == 'declare_ambition' then
                    pcall(function() zero_marker.removeButton(index) end)
                end
            end
        end
    else
        ambitionMarkers.add_button()
    end
end

function ambitionMarkers:toggle_zero_button(player_color, position, clicked_object)
    local hidden = ambitionMarkers:is_zero_button_hidden()
    ambitionMarkers:set_zero_button_hidden(not hidden)
    local status = hidden and "enabled" or "disabled"
    if type(player_color) == "string" and player_color ~= "" then
        broadcastToColor("Zero marker ambition button " .. status, player_color, {0.8, 0.8, 0.2})
    else
        broadcastToAll("Zero marker ambition button " .. status, {0.8, 0.8, 0.2})
    end
end

function ambitionMarkers:ensure_zero_marker_context_menu()
    if zero_button_menu_attached then
        return
    end

    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    if not zero_marker or not zero_marker.addContextMenuItem then
        return
    end
    pcall(function()
        zero_marker.addContextMenuItem("Toggle Zero Button", function(player_color, position, clicked_object)
            ambitionMarkers:toggle_zero_button(player_color, position, clicked_object)
        end)
        zero_button_menu_attached = true
    end)
end

function ambitionMarkers:get_ambition_info(object)
    -- Guard against missing object or reach board (load-order issues)
    if not object or not object.getPosition then
        -- Try resolving the ambition marker by any known ambition_marker_GUIDs
        local found = nil
        if ambition_marker_GUIDs then
            for i = 1, #ambition_marker_GUIDs do
                local g = ambition_marker_GUIDs[i]
                local o = getObjectFromGUID(g)
                if o and o.getPosition then
                    found = o
                    break
                end
            end
        end
        if not found then
            Log.WARNING("get_ambition_info called with invalid object and no ambition marker fallbacks available")
            return
        end
        object = found
    end

    -- safe guid for retry tracking and indexing
    local obj_guid = (object.getGUID and object.getGUID()) or object.guid or "unknown"

    local reach_map = getObjectFromGUID(reach_board_GUID)
    if not reach_map then
        -- Wait and retry a few times in case the reach board hasn't loaded yet
        ambitionMarkers._retry_counts = ambitionMarkers._retry_counts or {}
        local count = ambitionMarkers._retry_counts[obj_guid] or 0
        if count < 6 then
            ambitionMarkers._retry_counts[obj_guid] = count + 1
            Wait.time(function()
                ambitionMarkers.get_ambition_info(object)
            end, 0.5)
            return
        else
            Log.WARNING("reach_board not found; aborting ambition info for " .. tostring(obj_guid))
            return
        end
    end

    -- ensure object has a valid position
    local obj_pos = object.getPosition()
    if not obj_pos then
        ambitionMarkers._retry_counts = ambitionMarkers._retry_counts or {}
        local count = ambitionMarkers._retry_counts[obj_guid] or 0
        if count < 6 then
            ambitionMarkers._retry_counts[obj_guid] = count + 1
            Wait.time(function()
                ambitionMarkers.get_ambition_info(object)
            end, 0.5)
            return
        else
            Log.WARNING("object has no position; aborting ambition info for " .. tostring(obj_guid))
            return
        end
    end

    local local_pos = reach_map.positionToLocal(obj_pos)
    if not local_pos then
        ambitionMarkers._retry_counts = ambitionMarkers._retry_counts or {}
        local count = ambitionMarkers._retry_counts[obj_guid] or 0
        if count < 6 then
            ambitionMarkers._retry_counts[obj_guid] = count + 1
            Wait.time(function()
                ambitionMarkers.get_ambition_info(object)
            end, 0.5)
            return
        else
            Log.WARNING("positionToLocal returned nil; aborting for " .. tostring(obj_guid))
            return
        end
    end

    -- Instead of computing only for the moved object, refresh all markers
    ambitionMarkers.refresh_all_ambitions()
end


-- Scan all ambition markers and update the global ambitions table
function ambitionMarkers:refresh_all_ambitions()
    local reach_map = getObjectFromGUID(reach_board_GUID)
    if not reach_map then
        -- retry shortly if reach board missing
        Wait.time(function()
            ambitionMarkers.refresh_all_ambitions()
        end, 0.5)
        return
    end

    local global_ambitions = {}
    for i = 1, (ambition_marker_GUIDs and #ambition_marker_GUIDs or 0) do
        local guid = ambition_marker_GUIDs[i]
        local obj = getObjectFromGUID(guid)
        if obj and obj.getPosition then
            local pos = obj.getPosition()
            local local_pos = reach_map.positionToLocal(pos)
            if local_pos then
                local ambition_pos_z = local_pos.z
                local ambition_number = math.floor((ambition_pos_z + 1.83) / 0.39)
                if (ambition_number == 1) then
                    global_ambitions[guid] = ""
                elseif (ambition_number == 2) then
                    global_ambitions[guid] = "Tycoon"
                elseif (ambition_number == 3) then
                    global_ambitions[guid] = "Tyrant"
                elseif (ambition_number == 4) then
                    global_ambitions[guid] = "Warlord"
                elseif (ambition_number == 5) then
                    global_ambitions[guid] = "Keeper"
                elseif (ambition_number == 6) then
                    global_ambitions[guid] = "Empath"
                else
                    global_ambitions[guid] = ""
                end
            else
                global_ambitions[guid] = ""
            end
        else
            global_ambitions[guid] = ""
        end
    end


    Wait.time(function()
        Global.setVar("active_ambitions", global_ambitions)
        Global.call("update_player_scores")
    end, 1)
end


-- Calculate estimated ambition points for each player based on the currently
-- declared ambition markers and their flipped states. Returns a table
-- mapping player color -> estimated points (number).
function ambitionMarkers:calculate_player_ambition_points()
    local estimates = {}
    local active_players = Global.getVar("active_players") or {}
    for _, p in ipairs(active_players) do estimates[p.color] = 0 end

    local active_ambitions = Global.getVar("active_ambitions") or {}
    -- mapping from ambition name to ArcsPlayer stat field
    local stat_map = {
        Tycoon = "tycoon",
        Tyrant = "captives",
        Warlord = "trophies",
        Keeper = "keeper",
        Empath = "empath"
    }

    -- Helper: find index of guid in ambition_marker_GUIDs
    local function find_marker_index(guid)
        if not ambition_marker_GUIDs then return nil end
        for i = 1, #ambition_marker_GUIDs do
            if ambition_marker_GUIDs[i] == guid then return i end
        end
        return nil
    end

    -- Collect markers by ambition name (a single ambition may have multiple markers; sum their rewards)
    for guid, ambition_name in pairs(active_ambitions) do
        if ambition_name and ambition_name ~= "" and stat_map[ambition_name] then
            local idx = find_marker_index(guid)
            if not idx then goto continue end
            local marker_def = markers[idx]
            if not marker_def then goto continue end

            local obj = getObjectFromGUID(guid)
            local flipped = false
            if obj and obj.is_face_down ~= nil then flipped = obj.is_face_down end
            local power_def = marker_def[flipped] or marker_def[false] or {}

            -- build prize list (1st, 2nd, optional 3rd)
            local prizes = {}
            if power_def.first_power then table.insert(prizes, power_def.first_power) end
            if power_def.second_power then table.insert(prizes, power_def.second_power) end
            if power_def.third_power then table.insert(prizes, power_def.third_power) end

            -- Build ranking of players for this ambition
            local stat_field = stat_map[ambition_name]
            local players = {}
            for _, p in ipairs(active_players) do
                -- ensure player's stats have been updated (update_score should be called beforehand)
                local val = 0
                pcall(function() val = tonumber(p[stat_field]) or 0 end)
                -- Qualification: player must have at least 1 of the stat to qualify
                if val >= 1 then
                    table.insert(players, { color = p.color, value = val })
                end
            end
            if #players == 0 then goto continue end
            table.sort(players, function(a, b) return a.value > b.value end)

            -- Assign prizes with tie rules:
            -- - Players must have >=1 to qualify (already filtered)
            -- - If multiple players tie for a rank, they each receive the prize
            --   for one position lower (i.e., tied players go down one spot).
            local pos = 1
            while pos <= #players do
                -- find tie group
                local tie_val = players[pos].value
                local tie_group = { players[pos] }
                local j = pos + 1
                while j <= #players and players[j].value == tie_val do
                    table.insert(tie_group, players[j])
                    j = j + 1
                end

                -- Determine prize index: if tie group size > 1, they go down one spot
                local prize_index
                if #tie_group > 1 then
                    prize_index = pos + 1
                else
                    prize_index = pos
                end
                local prize = prizes[prize_index] or 0

                for _, entry in ipairs(tie_group) do
                    estimates[entry.color] = (estimates[entry.color] or 0) + prize
                end

                pos = j
            end
        end
        ::continue::
    end

    return estimates
end

-- Helper: apply a card-based ambition demotion (e.g., Elder for Tyrant, Archivist for Tycoon, Warrior for Empath)
local function apply_ambition_card_demotion(ambition_name, card_name, per_player, result, prizes, untied_winners, active_players)
    if ambition_name and card_name then
        for _, p in ipairs(active_players) do
            local has_card = false
            local area_zone_guid = nil
            pcall(function()
                if player_pieces_GUIDs and player_pieces_GUIDs[p.color] then
                    area_zone_guid = player_pieces_GUIDs[p.color].area_zone
                end
            end)
            if area_zone_guid then
                local area_zone = getObjectFromGUID(area_zone_guid)
                if area_zone and area_zone.getObjects then
                    local objs = area_zone.getObjects()
                    for _, obj in ipairs(objs) do
                        local obj_name = ""
                        pcall(function() obj_name = obj.getName() or "" end)
                        if string.find(obj_name or "", card_name) then
                            has_card = true
                            break
                        end
                    end
                end
            end

            if has_card then
                local prev = per_player[p.color] or 0
                
                -- Only process if player actually qualified (had some points)
                if prev > 0 then
                    -- Find which rank the player currently earned
                    local current_rank = nil
                    for i, prize in ipairs(prizes) do
                        if prev == prize then
                            current_rank = i
                            break
                        end
                    end
                    
                    if current_rank and current_rank > 0 then
                        -- Demote by one rank
                        local new_rank = current_rank + 1
                        local new_prize = prizes[new_rank] or 0
                        
                        -- Adjust only this player's points
                        local adjustment = new_prize - prev
                        result.totals[p.color] = (result.totals[p.color] or 0) + adjustment
                        per_player[p.color] = new_prize
                        
                        -- If they were untied first place winner, remove city bonus
                        if current_rank == 1 and untied_winners[ambition_name] == p.color then
                            untied_winners[ambition_name] = nil
                        end
                        
                        -- Record demotion note
                        if not result.ambition_notes[ambition_name] then result.ambition_notes[ambition_name] = {} end
                        local rank_label = nil
                        if new_rank == 2 then
                            rank_label = "2nd"
                        elseif new_rank == 3 then
                            rank_label = "3rd"
                        else
                            rank_label = tostring(new_prize) .. " points"
                        end
                        local extra = ""
                        if current_rank == 1 then
                            extra = "; no city bonus"
                        end
                        result.ambition_notes[ambition_name][p.color] = "(" .. card_name .. ": demoted to " .. rank_label .. extra .. ")"
                    end
                end
            end
        end
    end
end

-- Helper: apply Noble card restriction (only points if untied 1st place, else 0)
local function apply_ambition_card_noble(ambition_name, per_player, result, untied_winners, active_players)
    for _, p in ipairs(active_players) do
        local has_noble = false
        local area_zone_guid = nil
        pcall(function()
            if player_pieces_GUIDs and player_pieces_GUIDs[p.color] then
                area_zone_guid = player_pieces_GUIDs[p.color].area_zone
            end
        end)
        if area_zone_guid then
            local area_zone = getObjectFromGUID(area_zone_guid)
            if area_zone and area_zone.getObjects then
                local objs = area_zone.getObjects()
                for _, obj in ipairs(objs) do
                    local obj_name = ""
                    pcall(function() obj_name = obj.getName() or "" end)
                    if string.find(obj_name or "", "Noble") then
                        has_noble = true
                        break
                    end
                end
            end
        end

        if has_noble then
            local prev = per_player[p.color] or 0
            
            -- Only keep points if they were untied first place winner
            if untied_winners[ambition_name] ~= p.color then
                if prev > 0 then
                    -- Record note about losing points
                    if not result.ambition_notes[ambition_name] then result.ambition_notes[ambition_name] = {} end
                    result.ambition_notes[ambition_name][p.color] = "(Noble: no points unless untied 1st place)"
                    -- Set to 0
                    result.totals[p.color] = (result.totals[p.color] or 0) - prev
                    per_player[p.color] = 0
                end
            end
        end
    end
end

-- Helper: block points for a specific ambition if player has a card
local function apply_ambition_card_block(current_ambition, blocked_ambition, card_name, per_player, result, untied_winners, active_players)
    if current_ambition ~= blocked_ambition then
        return
    end

    for _, p in ipairs(active_players) do
        local has_card = false
        local area_zone_guid = nil
        pcall(function()
            if player_pieces_GUIDs and player_pieces_GUIDs[p.color] then
                area_zone_guid = player_pieces_GUIDs[p.color].area_zone
            end
        end)
        if area_zone_guid then
            local area_zone = getObjectFromGUID(area_zone_guid)
            if area_zone and area_zone.getObjects then
                local objs = area_zone.getObjects()
                for _, obj in ipairs(objs) do
                    local obj_name = ""
                    pcall(function() obj_name = obj.getName() or "" end)
                    if string.find(obj_name or "", card_name) then
                        has_card = true
                        break
                    end
                end
            end
        end

        if has_card then
            local prev = per_player[p.color] or 0
            if prev > 0 then
                -- Record note about blocking
                if not result.ambition_notes[blocked_ambition] then result.ambition_notes[blocked_ambition] = {} end
                result.ambition_notes[blocked_ambition][p.color] = "(" .. card_name .. ": blocked)"
                -- Set to 0
                result.totals[p.color] = (result.totals[p.color] or 0) - prev
                per_player[p.color] = 0
                if untied_winners[blocked_ambition] == p.color then
                    untied_winners[blocked_ambition] = nil
                end
            end
        end
    end
end

-- Build a detailed breakdown per ambition token and per-player assignment.
-- Returns a table: { totals = {color->points}, tokens = { { guid=..., ambition=..., prizes={...}, per_player={color->points} } } }
function ambitionMarkers:build_detailed_estimates()
    local result = { totals = {}, tokens = {}, ambition_bonuses = {}, ambition_notes = {} }
    local active_players = Global.getVar("active_players") or {}
    for _, p in ipairs(active_players) do result.totals[p.color] = 0 end

    local active_ambitions = Global.getVar("active_ambitions") or {}
    local stat_map = {
        Tycoon = "tycoon",
        Tyrant = "captives",
        Warlord = "trophies",
        Keeper = "keeper",
        Empath = "empath"
    }

    local function find_marker_index(guid)
        if not ambition_marker_GUIDs then return nil end
        for i = 1, #ambition_marker_GUIDs do if ambition_marker_GUIDs[i] == guid then return i end end
        return nil
    end

    -- Track which players won first place (untied) for which ambitions
    local untied_winners = {}  -- ambition_name -> player_color

    for guid, ambition_name in pairs(active_ambitions) do
        if ambition_name and ambition_name ~= "" and stat_map[ambition_name] then
            local idx = find_marker_index(guid)
            if not idx then goto continue end
            local marker_def = markers[idx]
            if not marker_def then goto continue end

            local obj = getObjectFromGUID(guid)
            local flipped = false
            if obj and obj.is_face_down ~= nil then flipped = obj.is_face_down end
            local power_def = marker_def[flipped] or marker_def[false] or {}

            local prizes = {}
            if power_def.first_power then table.insert(prizes, power_def.first_power) end
            if power_def.second_power then table.insert(prizes, power_def.second_power) end
            if power_def.third_power then table.insert(prizes, power_def.third_power) end

            -- build players who qualify
            local stat_field = stat_map[ambition_name]
            local players = {}
            for _, p in ipairs(active_players) do
                local val = 0
                pcall(function() val = tonumber(p[stat_field]) or 0 end)
                if val >= 1 then table.insert(players, { color = p.color, value = val }) end
            end
            if #players == 0 then
                -- record a token with zero impact
                local per_player = {}
                for _, p in ipairs(active_players) do per_player[p.color] = 0 end
                table.insert(result.tokens, { guid = guid, ambition = ambition_name, prizes = prizes, per_player = per_player, flipped = flipped })
                goto continue
            end
            table.sort(players, function(a,b) return a.value > b.value end)

            -- per-player points for this token
            local per_player = {}
            for _, p in ipairs(active_players) do per_player[p.color] = 0 end

            local pos = 1
            while pos <= #players do
                local tie_val = players[pos].value
                local tie_group = { players[pos] }
                local j = pos + 1
                while j <= #players and players[j].value == tie_val do
                    table.insert(tie_group, players[j])
                    j = j + 1
                end

                local prize_index = (#tie_group > 1) and (pos + 1) or pos
                local prize = prizes[prize_index] or 0
                for _, entry in ipairs(tie_group) do
                    per_player[entry.color] = (per_player[entry.color] or 0) + prize
                    result.totals[entry.color] = (result.totals[entry.color] or 0) + prize
                end

                -- Track untied first place winners
                if pos == 1 and #tie_group == 1 then
                    untied_winners[ambition_name] = tie_group[1].color
                end

                pos = j
            end

                -- Apply card-based ambition demotions
                if ambition_name == "Tyrant" then
                    apply_ambition_card_demotion("Tyrant", "Elder", per_player, result, prizes, untied_winners, active_players)
                elseif ambition_name == "Tycoon" then
                    apply_ambition_card_demotion("Tycoon", "Archivist", per_player, result, prizes, untied_winners, active_players)
                elseif ambition_name == "Empath" then
                    apply_ambition_card_demotion("Empath", "Warrior", per_player, result, prizes, untied_winners, active_players)
                end
                apply_ambition_card_demotion(ambition_name, "VOW OF SURVIVAL", per_player, result, prizes, untied_winners, active_players)

                -- Apply card-based ambition blocks (set to 0)
                apply_ambition_card_block(ambition_name, "Warlord", "OATH OF PEACE", per_player, result, untied_winners, active_players)
                apply_ambition_card_block(ambition_name, "Tycoon", "IRE OF THE TYCOONS", per_player, result, untied_winners, active_players)

                -- Apply Noble card restriction (all ambitions)
                apply_ambition_card_noble(ambition_name, per_player, result, untied_winners, active_players)

                table.insert(result.tokens, { guid = guid, ambition = ambition_name, prizes = prizes, per_player = per_player, flipped = flipped })
        end
        ::continue::
    end

    -- Apply loyal city bonuses for untied first place winners
    for ambition_name, winner_color in pairs(untied_winners) do
        local winner_player = nil
        for _, p in ipairs(active_players) do
            if p.color == winner_color then
                winner_player = p
                break
            end
        end

        if winner_player then
            -- Get the player's area zone
            local area_zone_guid = nil
            pcall(function()
                if player_pieces_GUIDs and player_pieces_GUIDs[winner_color] then
                    area_zone_guid = player_pieces_GUIDs[winner_color].area_zone
                end
            end)

            if area_zone_guid then
                local area_zone = getObjectFromGUID(area_zone_guid)
                if area_zone and area_zone.getObjects then
                    local zone_objects = area_zone.getObjects()
                    local loyal_city_count = 0
                    
                    -- Count loyal cities (objects with "City" in name or with City tag)
                    for _, obj in ipairs(zone_objects) do
                        local obj_name = ""
                        pcall(function() obj_name = obj.getName() or "" end)
                        if string.find(obj_name, "City") or (obj.hasTag and obj.hasTag("City")) then
                            loyal_city_count = loyal_city_count + 1
                        end
                    end

                    -- Apply bonus
                    local bonus = 0
                    if loyal_city_count == 0 then
                        bonus = 5
                    elseif loyal_city_count == 1 then
                        bonus = 2
                    end

                    if bonus > 0 then
                        result.totals[winner_color] = (result.totals[winner_color] or 0) + bonus
                        if not result.ambition_bonuses[ambition_name] then
                            result.ambition_bonuses[ambition_name] = {}
                        end
                        result.ambition_bonuses[ambition_name][winner_color] = bonus
                    end
                end
            end
        end
    end

    return result
end

function ambitionMarkers:add_button()
    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    -- If the zero marker object isn't present yet (load order), retry shortly
    if not zero_marker then
        Wait.time(function()
            ambitionMarkers.add_button()
        end, 0.5)
        return
    end

    -- Attach context menu if needed even when the button is hidden
    ambitionMarkers:ensure_zero_marker_context_menu()

    if ambitionMarkers:is_zero_button_hidden() then
        return
    end

    -- If a button already exists, edit it rather than creating a duplicate
    local existing = {}
    if zero_marker.getButtons then
        existing = zero_marker.getButtons() or {}
    end
    for _, b in ipairs(existing) do
        if b and b.click_function == 'declare_ambition' then
            local ok, err = pcall(function()
                zero_marker.editButton({
                    click_function = 'declare_ambition',
                    function_owner = zero_marker,
                    position = {0, 0.05, 0},
                    width = 3800,
                    height = 950,
                    tooltip = 'Declare Ambition'
                })
            end)
            if ok then return end
            break
        end
    end

    -- Try creating the button, and verify it exists; if not, retry a few times
    local function try_create(attempt)
        attempt = attempt or 1
        local ok, err = pcall(function()
            zero_marker.createButton({
                click_function = 'declare_ambition',
                function_owner = zero_marker,
                position = {0, 0.05, 0},
                width = 3800,
                height = 950,
                tooltip = 'Declare Ambition'
            })
        end)

        -- verify
        local btn_exists = false
        if zero_marker.getButtons then
            local buttons = zero_marker.getButtons() or {}
            for _, b in ipairs(buttons) do
                if b and b.click_function == 'declare_ambition' then
                    btn_exists = true
                    break
                end
            end
        end

        if not btn_exists and attempt < 8 then
            Wait.time(function()
                -- ensure the zero_marker still exists
                local zm = getObjectFromGUID(zero_marker_GUID)
                if zm then
                    ambitionMarkers.add_button_attempts = (ambitionMarkers.add_button_attempts or 0) + 1
                    if ambitionMarkers.add_button_attempts < 8 then
                        ambitionMarkers.add_button()
                    end
                end
            end, 0.5)
        end
    end

    try_create(1)
end

function ambitionMarkers:display_declare_button()
    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    zero_marker.editButton({
        click_function = 'declare_ambition',
        tooltip = 'Declare Ambition'
    })
end

function ambitionMarkers:display_undo_button()
    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    zero_marker.editButton({
        click_function = 'undo_ambition',
        tooltip = 'Undo'
    })
end


function ambitionMarkers:undo()
    broadcastToAll("Undo Ambition Declaration")
    if (last_declared_marker == nil) then
        Log.ERROR(
            "Could not find last declared ambition marker, resetting zero marker.")
         ambitionMarkers.display_declare_button()
        return
    end
    local reach_board = getObjectFromGUID(reach_board_GUID)
    local undo_pos =
        reach_board.positionToWorld(last_declared_marker.column_pos)
    undo_pos.y = undo_pos.y + 0.3
    -- If this spot is occupied, place the returned marker to the left by 1.33
    local function positions_too_close(p1, p2)
        local dx = math.abs(p1.x - p2.x)
        local dz = math.abs(p1.z - p2.z)
        return dx < 0.45 and dz < 0.45
    end

    local occupied = false
    -- gather existing ambition marker world positions
    for _, m in ipairs(markers) do
        if m and m.object and m.object.getPosition then
            local ok, p = pcall(function() return m.object.getPosition() end)
            if ok and p and positions_too_close(undo_pos, p) then
                occupied = true
                break
            end
        end
    end

    if occupied then
        undo_pos.x = undo_pos.x - 1.33
    end

    last_declared_marker.object.setPositionSmooth(undo_pos)

    -- move zero marker back
    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    zero_marker.setPositionSmooth(reach_board.positionToWorld({0.94, 0.2, 1.09}))
    zero_marker.setRotationSmooth({0.00, 180.00, 0.00})
    ambitionMarkers.display_declare_button()

    -- Immediately mark this marker as undeclared in Global state (safe via Global.call)
    pcall(function()
        local ok, guid = pcall(function() return last_declared_marker.object.getGUID() end)
        if ok and guid then
            pcall(function() Global.call('ambition_set_marker_undeclared', guid) end)
        end
    end)

    -- Refresh ambitions after undo movements settle (run in Global context)
    Wait.time(function()
        pcall(function() Global.call('ambition_refresh_proxy') end)
    end, 1.0)
end

function ambitionMarkers:reset_zero_marker()
    last_declared_marker = nil
    ambitionMarkers.display_declare_button()

    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    local reach_board = getObjectFromGUID(reach_board_GUID)
    zero_marker.setPositionSmooth(reach_board.positionToWorld({0.94, 0.2, 1.09}))
    zero_marker.setRotationSmooth({0.00, 180.00, 0.00})
    -- Ensure global ambitions reflect reset position after move completes
    Wait.time(function()
        pcall(function() Global.call('ambition_refresh_proxy') end)
    end, 0.8)
end

function ambitionMarkers:highest_undeclared()
    local marker_zone = getObjectFromGUID(ambition_marker_zone_GUID)
    local available_markers = marker_zone.getObjects()
    local high_points = 0
    local high_marker = nil
    local marker_mapping = {
        [ambition_marker_GUIDs[1]] = markers[1],
        [ambition_marker_GUIDs[2]] = markers[2],
        [ambition_marker_GUIDs[3]] = markers[3],
        [ambition_marker_GUIDs[4]] = markers[4],
        [ambition_marker_GUIDs[5]] = markers[5],
        [ambition_marker_GUIDs[6]] = markers[6]
    }

    for _, marker in pairs(available_markers) do
        local this_marker = marker_mapping[marker.getGUID()]
        local this_points = this_marker[this_marker.object.is_face_down]
                                .first_power
        if this_points > high_points then
            high_points = this_points
            high_marker = this_marker
        end
    end

    return high_marker

end

-- Begin Object Code --
function onLoad()
    -- ambitionMarkers.add_button()
end
function declare_ambition(obj, player_color)

    local lead_info = action_cards.get_lead_info()

    -- Is there a lead card?
    if (not lead_info) then
        broadcastToColor("No lead card has been played", player_color)
        return
    end

    -- Is there an ambition marker?
    local high_marker = ambitionMarkers.highest_undeclared()
    if (not high_marker) then
        broadcastToColor("No ambition markers available", player_color)
        return
    end

    -- Get declared ambition 
    local is_faithful = (lead_info.type == "Faithful Zeal" or lead_info.type ==
                            "Faithful Wisdom")

    -- Is the lead card a 1?
    if (lead_info.real_number == 1 and not is_faithful) then
        broadcastToColor("Actions numbered 1 cannot be declared", player_color)
        return
    end

    local power = high_marker[high_marker.object.is_face_down].power_desc
    local reach_board = getObjectFromGUID(reach_board_GUID)

    local this_ambition
    local is_mandate = lead_info.type and string.find(lead_info.type, "Mandate")
    if (lead_info.real_number == 7 or is_faithful or is_mandate) then
        broadcastToAll("" .. player_color ..
                           " is declaring ambition of choice for " .. power,
            player_color)
        broadcastToColor("Move " .. power ..
                             " ambition marker to desired ambition",
            player_color)
    else
        this_ambition = ambitions[lead_info.real_number]
        
        -- Smart column selection: try middle first, then right, then left
        -- Only place in a column if it's empty at that ambition row
        -- World x-coordinates for columns: middle 17.64, right 18.97, left 16.16
        local function count_markers_at_ambition_row(target_x, target_z)
            local count = 0
            for _, m in ipairs(markers) do
                if m.object and m.object.getPosition then
                    local obj_pos = m.object.getPosition()
                    -- Check if marker is at this x column and approximately this z row
                    if math.abs(obj_pos.x - target_x) < 0.1 and math.abs(obj_pos.z - target_z) < 0.2 then
                        count = count + 1
                    end
                end
            end
            return count
        end
        
        -- Calculate the target z position for this ambition
        local target_pos = reach_board.positionToWorld(high_marker.column_pos + this_ambition.row_pos)
        local target_z = target_pos.z
        
        -- Check columns in priority order: middle, right, left
        local selected_column_x = 17.64  -- default to middle
        
        local middle_count = count_markers_at_ambition_row(17.64, target_z)
        if middle_count == 0 then
            selected_column_x = 17.64  -- middle is empty, use it
        else
            local right_count = count_markers_at_ambition_row(18.97, target_z)
            if right_count == 0 then
                selected_column_x = 18.97  -- middle is full, right is empty, use right
            else
                selected_column_x = 16.16  -- both middle and right full, use left
            end
        end
        
        -- Build position using the selected column and the ambition row
        local pos = reach_board.positionToWorld(high_marker.column_pos + this_ambition.row_pos)
        pos.x = selected_column_x
        pos.y = pos.y + 0.3
        high_marker.object.setPositionSmooth(pos)
        broadcastToAll("" .. player_color .. " has declared " ..
                           this_ambition.name .. " ambition for " .. power,
            player_color)
    end

    last_declared_marker = high_marker

    if this_ambition and ((this_ambition.name == "Keeper" or this_ambition.name == "Empath") and
        ArcsPlayer.has_secret_order(player_color)) then
        broadcastToAll(player_color .. " has SECRET ORDER")
        return
    end

    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    zero_marker.setPositionSmooth(reach_board.positionToWorld({1.02, 0.2, 0.67}))
    zero_marker.setRotationSmooth({0.00, 90.00, 0.00})

    ambitionMarkers.display_undo_button()

    -- After moving markers/zero marker via script, refresh ambitions
    -- after a short delay so smooth movements have settled.
    Wait.time(function()
        pcall(function() Global.call('ambition_refresh_proxy') end)
    end, 0.8)
end
function undo_ambition(obj, player_color)
    ambitionMarkers.undo(obj)
end
-- End Object Code --

return ambitionMarkers
