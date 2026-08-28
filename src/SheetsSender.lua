-- Simple Sheets sender for testing
-- This module exposes a global UI callback `send_scores_to_sheet_ui`

local WEBHOOK_URL = "https://script.google.com/macros/s/AKfycbwl4ziuGruDElFuPu9lZw4VNALsXW25wHdzHENO32iCStt_tQa25dl0FE7qJpnIHd3alQ/exec"

local SheetsSender = {}
-- last computed preview rows (table form) so Send Now posts the exact preview
local last_preview_rows = nil
-- remember the last preview player order so reopening the preview does not reshuffle players
local last_preview_order_colors = nil
-- store notes text
local last_notes = ""
-- store selected act
local last_selected_act = "basegame"
-- store anonymize names checkbox state
local last_anonymize_names = false
local ActionCards = require("src/ActionCards")
require("src/GUIDs")
-- special object GUID that indicates the "first regent" tile/object
local FIRST_REGENT_GUID = "e9b0f4"

local function get_player_color(p)
    if type(p) == "table" and p.color then return tostring(p.color) end
    if type(p) == "string" then return tostring(p) end
    return tostring(p)
end

local function get_player_colors(players)
    local colors = {}
    if type(players) ~= "table" then return colors end
    for _, p in ipairs(players) do
        table.insert(colors, get_player_color(p))
    end
    return colors
end

local function get_sheets_player_roster()
    local roster = nil
    pcall(function()
        roster = Global.getTable("starting_players")
    end)
    if type(roster) == "table" and #roster > 0 then
        return roster
    end

    pcall(function()
        roster = Global.getVar("starting_players")
    end)
    if type(roster) == "table" and #roster > 0 then
        return roster
    end

    pcall(function()
        roster = Global.getVar("active_players")
    end)
    if type(roster) == "table" and #roster > 0 then
        return roster
    end

    pcall(function()
        roster = Global.getTable("active_players")
    end)
    if type(roster) == "table" and #roster > 0 then
        return roster
    end

    local ok_ordered, ordered = pcall(function() return Global.call("getOrderedPlayers", {true}) end)
    if ok_ordered and ordered and type(ordered) == "table" and #ordered > 0 then
        return ordered
    end

    return roster or {}
end

-- Convert a TTS color name (e.g., "Pink") to a hex string like "#RRGGBB".
local function color_to_hex(color_name)
    if not color_name then return "#999999" end
    local ok, col = pcall(function() return Color.fromString(color_name) end)
    if ok and col and type(col) == "table" and col[1] then
        local r = math.floor((col[1] or 1) * 255 + 0.5)
        local g = math.floor((col[2] or 1) * 255 + 0.5)
        local b = math.floor((col[3] or 1) * 255 + 0.5)
        return string.format("#%02X%02X%02X", r, g, b)
    end
    -- fallback small mapping
    local map = {
        White = "#FFFFFF", Pink = "#FF69B4", Yellow = "#FFFF66", Teal = "#008080", Red = "#FF4444", Blue = "#4488FF", Green = "#44CC44", Black = "#222222"
    }
    return map[color_name] or "#999999"
end

local function same_color_set(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return false end
    if #a ~= #b then return false end
    local counts = {}
    for _, color in ipairs(a) do
        counts[color] = (counts[color] or 0) + 1
    end
    for _, color in ipairs(b) do
        local count = counts[color]
        if not count then return false end
        if count == 1 then counts[color] = nil else counts[color] = count - 1 end
    end
    return next(counts) == nil
end

local function order_players_like(players, colors)
    if type(players) ~= "table" or type(colors) ~= "table" or #players == 0 then return players end
    local by_color = {}
    for _, p in ipairs(players) do
        by_color[get_player_color(p)] = p
    end
    local ordered = {}
    local seen = {}
    for _, color in ipairs(colors) do
        local p = by_color[color]
        if p then
            table.insert(ordered, p)
            seen[color] = true
        end
    end
    -- include any newly-seated players at the end without changing the remembered order
    for _, p in ipairs(players) do
        local color = get_player_color(p)
        if not seen[color] then
            table.insert(ordered, p)
        end
    end
    return ordered
end

-- Resolve player GUIDs from available sources: local player_pieces, Global var player_pieces_GUIDs, or global player_pieces_GUIDs
local function get_player_guid(color, key)
    -- try local player_pieces (used in ArcsPlayer.lua)
    if player_pieces and player_pieces[color] then
        -- direct key (e.g., area_zone, hand_zone)
        if player_pieces[color][key] then return player_pieces[color][key] end
        -- components table (e.g., score_board)
        if player_pieces[color]["components"] and player_pieces[color]["components"][key] then
            return player_pieces[color]["components"][key]
        end
    end

    -- try Global stored GUIDs
    local ok, pp_guids = pcall(function() return Global.getVar("player_pieces_GUIDs") end)
    if ok and pp_guids and pp_guids[color] then
        if pp_guids[color][key] then return pp_guids[color][key] end
        if pp_guids[color]["components"] and pp_guids[color]["components"][key] then return pp_guids[color]["components"][key] end
        -- some modules expose player_pieces_GUIDs as a global table
        if _G["player_pieces_GUIDs"] and _G["player_pieces_GUIDs"][color] then
            if _G["player_pieces_GUIDs"][color][key] then return _G["player_pieces_GUIDs"][color][key] end
        end
    end

    -- final fallback to global player_pieces_GUIDs
    if _G["player_pieces_GUIDs"] and _G["player_pieces_GUIDs"][color] then
        if _G["player_pieces_GUIDs"][color][key] then return _G["player_pieces_GUIDs"][color][key] end
        if _G["player_pieces_GUIDs"][color]["components"] and _G["player_pieces_GUIDs"][color]["components"][key] then
            return _G["player_pieces_GUIDs"][color]["components"][key]
        end
    end

    return nil
end

local SCORE_BUTTON_LABEL_INDICES = {
    power = 0,
    objective = 14,
    hand_size = 2,
    tycoon = 4,
    captives = 6,
    trophies = 8,
    keeper = 10,
    empath = 12,
}

local function read_score_button_labels(score_board, scores)
    if not score_board or type(score_board.getButtons) ~= "function" then
        return scores
    end

    local ok, buttons = pcall(function() return score_board.getButtons() end)
    if not ok or not buttons then
        return scores
    end

    local labels_by_index = {}
    for _, button in ipairs(buttons) do
        if button.index ~= nil then
            labels_by_index[button.index] = button.label
        end
    end

    for key, index in pairs(SCORE_BUTTON_LABEL_INDICES) do
        local label = labels_by_index[index]
        if label ~= nil and tostring(label) ~= "" then
            scores[key] = tostring(label)
        end
    end

    return scores
end

local function resolve_initiative_player_color()
    local initiative_guids = { initiative_GUID, seized_initiative_GUID }
    local seated = {}
    pcall(function()
        local players = Global.getVar("active_players") or Global.getTable("active_players") or {}
        seated = players
    end)

    -- broadcastToAll("Sheets: resolve_initiative_player_color() called, initiative_GUID=" .. tostring(initiative_GUID) .. ", seized=" .. tostring(seized_initiative_GUID), {0.8, 0.8, 0.2})

    -- First: scan each player's initiative zone for the marker
    for _, p in ipairs(seated) do
        local color = get_player_color(p)
        
        -- Try get_player_guid first (for normal setup), then fall back to global player_pieces_GUIDs (for custom setup)
        local zone_guid = get_player_guid(color, "initiative_zone")
        if not zone_guid and player_pieces_GUIDs and player_pieces_GUIDs[color] and player_pieces_GUIDs[color].initiative_zone then
            zone_guid = player_pieces_GUIDs[color].initiative_zone
        end
        
        -- broadcastToAll("Sheets: checking " .. tostring(color) .. " zone_guid=" .. tostring(zone_guid), {0.6, 0.6, 0.9})
        if zone_guid then
            local zone = getObjectFromGUID(zone_guid)
            if zone and type(zone.getObjects) == "function" then
                local ok_zone, objs = pcall(function() return zone.getObjects() end)
                if ok_zone and objs then
                    -- broadcastToAll("Sheets: zone has " .. tostring(#objs) .. " objects", {0.6, 0.6, 0.9})
                    for _, obj in ipairs(objs) do
                        local guid = nil
                        pcall(function() if obj.getGUID then guid = obj.getGUID() end end)
                        if not guid and obj.guid then guid = obj.guid end
                        if guid then
                            -- broadcastToAll("Sheets: found object guid=" .. tostring(guid), {0.6, 0.6, 0.9})
                            for _, target in ipairs(initiative_guids) do
                                if tostring(guid) == tostring(target) then
                                    -- broadcastToAll("Sheets: MATCHED initiative for " .. tostring(color), {0.2, 0.8, 0.2})
                                    return color
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Fallback: try to get the initiative objects directly by GUID and find which player zone contains them
    for _, init_guid in ipairs(initiative_guids) do
        local init_obj = getObjectFromGUID(tostring(init_guid))
        if init_obj then
            -- broadcastToAll("Sheets: found initiative object " .. tostring(init_guid) .. " directly", {0.8, 0.6, 0.2})
            -- Now check which player's initiative zone contains this object
            for _, p in ipairs(seated) do
                local color = get_player_color(p)
                local zone_guid = get_player_guid(color, "initiative_zone")
                if not zone_guid and player_pieces_GUIDs and player_pieces_GUIDs[color] and player_pieces_GUIDs[color].initiative_zone then
                    zone_guid = player_pieces_GUIDs[color].initiative_zone
                end
                if zone_guid then
                    local zone = getObjectFromGUID(zone_guid)
                    if zone and type(zone.getObjects) == "function" then
                        local ok_zone, objs = pcall(function() return zone.getObjects() end)
                        if ok_zone and objs then
                            for _, obj in ipairs(objs) do
                                local guid = nil
                                pcall(function() if obj.getGUID then guid = obj.getGUID() end end)
                                if not guid and obj.guid then guid = obj.guid end
                                if guid and tostring(guid) == tostring(init_guid) then
                                    -- broadcastToAll("Sheets: MATCHED initiative (fallback) for " .. tostring(color), {0.2, 0.8, 0.2})
                                    return color
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- broadcastToAll("Sheets: NO initiative player detected", {0.8, 0.2, 0.2})
    return nil
end

-- Return true if the given object appears to be a card (Card/Deck or tagged/ named as a card)
local function is_card_object(obj)
    if not obj then return false end
    -- Exclude objects that are actually player boards (some setups tag them)
    local ok_ex, is_player_board = pcall(function() if obj.hasTag then return obj.hasTag("player board") end end)
    if ok_ex and is_player_board then return false end
    local ok_ex2, is_player_board2 = pcall(function() if obj.hasTag then return obj.hasTag("playerboard") end end)
    if ok_ex2 and is_player_board2 then return false end
    local ok_ex3, is_player_board3 = pcall(function() if obj.hasTag then return obj.hasTag("Player Board") end end)
    if ok_ex3 and is_player_board3 then return false end
    local ok, typ = pcall(function() return obj.type end)
    if ok and typ then
        if typ == "Card" or typ == "Deck" then return true end
    end
    local okTag, hasCardTag = pcall(function() return obj.hasTag and obj.hasTag("Card") end)
    if okTag and hasCardTag then return true end
    local okName, name = pcall(function() return obj.getName and obj.getName() end)
    if okName and name and tostring(name) ~= "" then
        local lname = string.lower(tostring(name))
        if string.find(lname, "card") or string.find(lname, "action") then return true end
    end
    return false
end

-- Return string like "face-down" / "face-up" or nil if unknown
local function card_face_str(obj)
    if not obj then return nil end
    local is_down = nil
    pcall(function() is_down = obj.is_face_down end)
    if is_down == nil then pcall(function() is_down = obj.is_face_down() end) end
    if is_down == nil then return nil end
    if is_down == true then return "face-down" end
    return "face-up"
end

local function format_card_label(obj, label, area_obj)
    if not label or label == "" then return label end
    -- determine tag prefix (Leader/Fate) when present
    local prefix = ""
    pcall(function()
        if obj and obj.hasTag and obj.hasTag("Leader") then prefix = "Leader: " end
        if obj and obj.hasTag and obj.hasTag("Fate") then prefix = "Fate: " end
    end)
    -- fallback: check table-style tags (use pcall for userdata safety)
    if prefix == "" and obj then
        local ok_tags, tags = pcall(function() return obj.tags end)
        if ok_tags and tags and type(tags) == "table" then
            for _, t in ipairs(tags) do
                if tostring(t) == "Leader" then prefix = "Leader: " ; break end
                if tostring(t) == "Fate" then prefix = "Fate: " ; break end
            end
        end
    end
    -- don't duplicate if label already contains the prefix
    local upcheck = string.upper(tostring(label))
    if prefix ~= "" and (string.find(upcheck, "^LEADER") or string.find(upcheck, "^FATE")) then
        prefix = ""
    end
    local up = string.upper(tostring(label))
    -- Only append face state for specific cards
    if string.find(up, "IMPERIAL REGENT") or string.find(up, "OUTLAW") then
        local state = card_face_str(obj)
        if state then
            label = label .. " (" .. state .. ")"
        end
    end
    -- If provided area_obj matches the FIRST_REGENT_AREA_GUID, mark as first regent
    if area_obj then
        -- area_obj may be a zone; don't treat it as first regent. Detection is done per-object.
    end
    return prefix .. label
end

-- URL-encode a string for form-encoding
local function url_encode(str)
    if str == nil then return "" end
    str = tostring(str)
    -- normalize newlines
    str = str:gsub("\n", "\r\n")
    return (str:gsub("([^%w%-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end))
end

local function _broadcast_response(response)
    -- Prefer explicit error flag if present
    if response and response.is_error then
        local text = (response and response.text) and response.text or tostring(response)
        broadcastToAll("Sheets: send failed - " .. tostring(text), {1, 0, 0})
        return
    end

    -- If no explicit error, consider it successful (some WebRequest responses
    -- don't expose numeric responseCode). Show OK and optionally the text.
    local text = (response and response.text) and response.text or tostring(response)
    broadcastToAll("Sheets: sent OK", {0, 1, 0})
    if text and tostring(text) ~= "table: 0x0" and tostring(text) ~= "nil" and tostring(text) ~= "" then
        broadcastToAll("Sheets response: " .. tostring(text), {0, 1, 0})
    end
end

local function send_simple_test(player, value, id)
    -- Simple payload matching the Apps Script: send a single `word` field
    local payload = {
        word = "hello from TTS"
    }
    local body_json = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    -- Debug: show what we're about to send (shorten if extremely long)
    local dbg = body_json
    if #dbg > 1200 then dbg = dbg:sub(1, 1200) .. "... (truncated)" end
    broadcastToAll("Sheets: sending JSON payload (truncated): " .. tostring(dbg), {0.2,0.5,1})

    -- Ensure WebRequest API is available
    if not WebRequest or not WebRequest.custom then
        broadcastToAll("Sheets: WebRequest API not available in this environment", {1,0,0})
        return
    end

    -- Use WebRequest.custom with JSON body (matches the working example pattern)
    -- Append URL-encoded JSON as a `payload` query param too, to support appscripts
    local url_with_q = WEBHOOK_URL .. "?payload=" .. url_encode(body_json)
    local ok, err = pcall(function()
        WebRequest.custom(url_with_q, "POST", true, body_json, headers, function(response)
            _broadcast_response(response)
        end)
    end)
    if not ok then
        broadcastToAll("Sheets: WebRequest.custom error: " .. tostring(err), {1,0,0})
    end
    return
end

-- Expose as a global function so UI onClick can call it by name
_G["send_scores_to_sheet_ui"] = send_simple_test

-- Open a preview UI showing the payload to be sent (sample data for now)
local function generate_preview_xml(active)
    -- Prefer the stored game roster so players who leave mid-game still appear in the sheet payload.
    local roster = get_sheets_player_roster()
    if roster and type(roster) == "table" and #roster > 0 then
        local roster_colors = get_player_colors(roster)
        if last_preview_order_colors and same_color_set(last_preview_order_colors, roster_colors) then
            active = order_players_like(roster, last_preview_order_colors)
        else
            active = roster
            last_preview_order_colors = roster_colors
        end
    else
        active = active or {}
    end
    -- broadcastToAll("Sheets preview: generate_preview_xml active count=" .. tostring(#active), {0.6,0.6,0.9})

    -- Get game ID from Global
    local game_id = ""
    pcall(function()
        game_id = Global.getVar("game_id") or ""
    end)

    -- reset stored preview rows
    last_preview_rows = {}
    local rows = {}
    table.insert(rows, '<Panel preferredWidth="1500" preferredHeight="1" color="#FFFFFF" />')
    table.insert(rows, [[
        <HorizontalLayout spacing="8">
            <Panel preferredWidth="40" preferredHeight="18" color="#00000000" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Player" color="#dcdcdc" fontSize="16" preferredWidth="260" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Color" color="#dcdcdc" fontSize="16" preferredWidth="80" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Init" color="#dcdcdc" fontSize="16" preferredWidth="40" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Area" color="#dcdcdc" fontSize="16" preferredWidth="480" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Power" color="#dcdcdc" fontSize="16" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Objective" color="#dcdcdc" fontSize="16" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Hand#" color="#dcdcdc" fontSize="16" preferredWidth="70" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Tycoon" color="#dcdcdc" fontSize="16" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Captives" color="#dcdcdc" fontSize="16" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Trophies" color="#dcdcdc" fontSize="16" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Keeper" color="#dcdcdc" fontSize="16" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Empath" color="#dcdcdc" fontSize="16" preferredWidth="90" />
        </HorizontalLayout>
    ]])
    table.insert(rows, '<Panel preferredWidth="1500" preferredHeight="1" color="#FFFFFF" />')

    if #active == 0 then
        -- fallback sample row
        table.insert(rows, [[
        <HorizontalLayout spacing="8">
            <Panel preferredWidth="40" preferredHeight="18" color="#FF69B4" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Alice" color="white" fontSize="14" preferredWidth="260" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Pink" color="white" fontSize="14" preferredWidth="80" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="✓" color="white" fontSize="14" preferredWidth="40" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="Leader: Duke; Hand: Noble, Spy" color="white" fontSize="14" preferredWidth="480" />
        </HorizontalLayout>
        ]])
        table.insert(rows, '<Panel preferredWidth="1500" preferredHeight="1" color="#FFFFFF" />')
    else
        for _, p in ipairs(active) do
            local name = nil
            local power = ""
            local objective = ""
            local hand_size = ""
            local tycoon = ""
            local captives = ""
            local trophies = ""
            local keeper = ""
            local empath = ""

            local arcs_player = nil
            if type(p) == "table" and p.color then
                -- If the ordered players returned an ArcsPlayer-like table, try to
                -- resolve the authoritative ArcsPlayer instance (may have score_board refs)
                local okap, ap = pcall(function() return get_arcs_player(p.color) end)
                if okap and ap then
                    arcs_player = ap
                else
                    arcs_player = p
                end
                -- Try cached steam name first (survives player leaving), then live Player reference
                local cached_name = nil
                pcall(function() cached_name = Global.call("get_cached_steam_name", (arcs_player and arcs_player.color) or p.color) end)
                if cached_name and cached_name ~= "" and cached_name ~= ((arcs_player and arcs_player.color) or p.color) then
                    name = cached_name
                else
                    local ok, pl = pcall(function() return Player[(arcs_player and arcs_player.color) or p.color] end)
                    if ok and pl and pl.steam_name and pl.steam_name ~= "" then
                        name = pl.steam_name
                    else
                        name = (arcs_player and arcs_player.color) or p.color
                    end
                end
            elseif type(p) == "string" then
                -- try to resolve ArcsPlayer by color
                local ok, ap = pcall(function() return get_arcs_player(p) end)
                if ok and ap then
                    arcs_player = ap
                end
                -- Try cached steam name first, then live Player reference
                local cached_name = nil
                pcall(function() cached_name = Global.call("get_cached_steam_name", p) end)
                if cached_name and cached_name ~= "" and cached_name ~= p then
                    name = cached_name
                else
                    local ok2, pl = pcall(function() return Player[p] end)
                    if ok2 and pl and pl.steam_name and pl.steam_name ~= "" then name = pl.steam_name else name = p end
                end
            else
                name = tostring(p)
            end

            if arcs_player and type(arcs_player.update_score) == "function" then
                pcall(function() arcs_player:update_score() end)
                power = arcs_player.power or ""
                objective = arcs_player.objective or ""
                hand_size = arcs_player.hand_size or ""
                tycoon = arcs_player.tycoon or ""
                captives = arcs_player.captives or ""
                trophies = arcs_player.trophies or ""
                keeper = arcs_player.keeper or ""
                empath = arcs_player.empath or ""

                -- Try to read the actual labels from the player's score_board buttons
                local sb = arcs_player.score_board
                if not sb and arcs_player.color then
                    local sb_guid = get_player_guid(arcs_player.color, "score_board")
                    if sb_guid then
                        pcall(function() sb = getObjectFromGUID(sb_guid) end)
                    end
                end
                local score_labels = read_score_button_labels(sb, {
                    power = power,
                    objective = objective,
                    hand_size = hand_size,
                    tycoon = tycoon,
                    captives = captives,
                    trophies = trophies,
                    keeper = keeper,
                    empath = empath,
                })
                power = score_labels.power
                objective = score_labels.objective
                hand_size = score_labels.hand_size
                tycoon = score_labels.tycoon
                captives = score_labels.captives
                trophies = score_labels.trophies
                keeper = score_labels.keeper
                empath = score_labels.empath
            end

            -- Gather cards from the player's area and hand (use ActionCards.get_info when available)
            local cards_list = {}
            local function push_card_obj(obj, source, area_obj)
                if not obj then return end
                local added = false
                if ActionCards and type(ActionCards.get_info) == "function" then
                    local ok, info = pcall(function() return ActionCards.get_info(obj) end)
                    if ok and info and info.type then
                        local lbl = tostring(info.type) .. (info.number and ("#" .. tostring(info.number)) or "")
                        table.insert(cards_list, format_card_label(obj, lbl, area_obj))
                        added = true
                    end
                end
                if not added then
                        local nm = nil
                        local ok1 = pcall(function() if obj.getName then nm = obj.getName() end end)
                        if (not nm or tostring(nm) == "") and obj.name then nm = obj.name end
                        if ok1 and nm and tostring(nm) ~= "" then
                            table.insert(cards_list, format_card_label(obj, tostring(nm), area_obj))
                        added = true
                    end
                end
                if not added then
                        local desc = nil
                        local ok2 = pcall(function() if obj.getDescription then desc = obj.getDescription() end end)
                        if (not desc or tostring(desc) == "") and obj.description then desc = obj.description end
                        if ok2 and desc and tostring(desc) ~= "" then
                            table.insert(cards_list, format_card_label(obj, tostring(desc), area_obj))
                    end
                end
            end

            -- area_zone
            local area_zone_obj = nil
            pcall(function()
                if arcs_player and arcs_player.color then
                    local area_guid = get_player_guid(arcs_player.color, "area_zone")
                    if area_guid then area_zone_obj = getObjectFromGUID(area_guid) end
                end
            end)
            if area_zone_obj and type(area_zone_obj.getObjects) == "function" then
                local ok, objs = pcall(function() return area_zone_obj.getObjects() end)
                if ok and objs then
                    -- broadcastToAll("Sheets preview: found " .. tostring(#objs) .. " area objects for " .. tostring(name), {0.3,0.6,0.9})
                    for _, o in ipairs(objs) do
                        -- detect object GUID robustly
                        local og = nil
                        pcall(function() if o.getGUID then og = o.getGUID() end end)
                        if (not og) and o.guid then og = o.guid end
                        local is_first_regent_obj = og and tostring(og) == FIRST_REGENT_GUID
                        if is_first_regent_obj then
                            -- explicitly add a user-friendly label for the first regent
                            table.insert(cards_list, "First Regent")
                        elseif is_card_object(o) then
                            -- treat normal card objects as before
                            local nm = nil
                            pcall(function() if o.getName then nm = o.getName() end end)
                            if (not nm or tostring(nm) == "") and o.name then nm = o.name end
                            if nm and tostring(nm) ~= "" then
                                table.insert(cards_list, format_card_label(o, tostring(nm)))
                            else
                                push_card_obj(o, "area")
                            end
                        else
                            -- skip any other non-card objects
                        end
                    end
                else
                    -- broadcastToAll("Sheets preview: could not read area objects for " .. tostring(name), {1,0.4,0.2})
                end
            else
                -- broadcastToAll("Sheets preview: no area zone object for " .. tostring(name), {1,0.4,0.2})
            end

            -- hand_zone
            local hand_zone_obj = nil
            pcall(function()
                if arcs_player and arcs_player.color then
                    local hand_guid = get_player_guid(arcs_player.color, "hand_zone")
                    if hand_guid then hand_zone_obj = getObjectFromGUID(hand_guid) end
                end
            end)
            if hand_zone_obj and type(hand_zone_obj.getObjects) == "function" then
                local ok, objs = pcall(function() return hand_zone_obj.getObjects() end)
                if ok and objs then
                    -- broadcastToAll("Sheets preview: found " .. tostring(#objs) .. " hand objects for " .. tostring(name), {0.3,0.6,0.9})
                    for _, o in ipairs(objs) do
                        if is_card_object(o) then
                            push_card_obj(o, "hand", hand_zone_obj)
                        end
                    end
                else
                    -- broadcastToAll("Sheets preview: could not read hand objects for " .. tostring(name), {1,0.4,0.2})
                end
            else
                -- broadcastToAll("Sheets preview: no hand zone object for " .. tostring(name), {1,0.4,0.2})
            end

            -- initiative detection
            local initiative_player = resolve_initiative_player_color()
            local has_initiative = false
            if initiative_player and arcs_player and arcs_player.color and tostring(initiative_player) == tostring(arcs_player.color) then has_initiative = true end

            -- clean cards list: remove stray tokens like "active"/"area"/"hand" and empty entries
            local clean_cards = {}
            for _, c in ipairs(cards_list) do
                local ok, s = pcall(function() return tostring(c) end)
                if not ok then s = "" end
                s = s or ""
                s = s:gsub("^%s+", ""):gsub("%s+$", "")
                local ls = string.lower(s)
                if s ~= "" and ls ~= "active" and ls ~= "area" and ls ~= "hand" then
                    table.insert(clean_cards, s)
                end
            end

            -- store a structured row so send uses exactly the preview content (include cleaned cards array)
            local color_name = (arcs_player and arcs_player.color) or ((type(p) == "table" and p.color) and p.color) or (type(p) == "string" and p) or tostring(p)
            table.insert(last_preview_rows, {
                full_name = name,
                name = name,
                color = color_name,
                initiative = has_initiative,
                power = tostring(power),
                objective = tostring(objective),
                hand_size = tostring(hand_size),
                tycoon = tostring(tycoon),
                captives = tostring(captives),
                trophies = tostring(trophies),
                keeper = tostring(keeper),
                empath = tostring(empath),
                cards = clean_cards,
            })

            local init_display = has_initiative and "✓" or ""
            -- split cards into area / hand for display (best-effort)
            local area_str = table.concat(clean_cards, " | ")
            table.insert(rows, string.format([[ 
        <HorizontalLayout spacing="8">
            <Panel preferredWidth="40" preferredHeight="18" color="%s" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="260" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="80" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="40" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="480" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="70" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
            <Panel preferredWidth="1" preferredHeight="18" color="#FFFFFF" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="90" />
        </HorizontalLayout>
            ]], color_to_hex(((arcs_player and arcs_player.color) or ((type(p) == "table" and p.color) and p.color) or (type(p) == "string" and p) or tostring(p))), name, (arcs_player and arcs_player.color) or ((type(p) == "table" and p.color) and p.color) or (type(p) == "string" and p) or tostring(p), init_display, area_str, tostring(power), tostring(objective), tostring(hand_size), tostring(tycoon), tostring(captives), tostring(trophies), tostring(keeper), tostring(empath)))
            table.insert(rows, '<Panel preferredWidth="1500" preferredHeight="1" color="#FFFFFF" />')
        -- replace the fields above: show initiative marker as check if present
        end
    end

    local rows_xml = table.concat(rows, "\n")

    return string.format([[ 
    <Canvas>
        <Panel id="sheetsPreviewPanel" rectAlignment="MiddleCenter" allowDragging="true" width="1400" height="900" color="#222222CC" childForceExpandWidth="false" childForceExpandHeight="false">
            <VerticalLayout spacing="8" padding="10" childForceExpandHeight="false" childForceExpandWidth="false">
                <Text text="ARCS - Game Results Preview" fontSize="24" color="white" />
                <Text text="Game ID: %s - You can view collected data here: https://laurens1234.github.io/arcs-arsenal/data" fontSize="14" color="#dcdcdc" />
                <Text text="Send results to help collect game data." fontSize="13" color="#cfcfcf" />
                <Text text="You may submit these results at the end of the game or at the end of each Act." fontSize="13" color="#cfcfcf" />
                %s
                <HorizontalLayout spacing="8" childForceExpandWidth="false">
                    <Button text="Send Result" onClick="send_preview_to_sheet_ui" color="#2e8b57" textColor="white" width="120" height="36" preferredWidth="120" preferredHeight="36" fontSize="16" />
                    <Text text="Notes:" color="#dcdcdc" fontSize="14" preferredWidth="60" />
                    <InputField id="sheetsNotesInput" text="" characterLimit="500" contentType="TextArea" placeholder="Add notes here..." preferredWidth="400" preferredHeight="18" onValueChanged="update_notes_field" />
                    <Text text="Mode/Act:" color="#dcdcdc" fontSize="14" preferredWidth="40" />
                    <Dropdown id="sheetsActDropdown" onValueChanged="update_act_dropdown" preferredWidth="120" preferredHeight="28">
                        <Option value="basegame">Base</Option>
                        <Option value="Lost Vaults">Lost Vaults</Option>
                        <Option value="Act I">Act I</Option>
                        <Option value="Act II">Act II</Option>
                        <Option value="Act III">Act III</Option>
                        <Option value="Other">Other</Option>                        
                    </Dropdown>
                    <Toggle id="sheetsAnonymizeToggle" isOn="%s" onValueChanged="update_anonymize_checkbox" />
                    <Text text="Anonymize" color="#dcdcdc" fontSize="12" preferredWidth="80" />
                    <Panel preferredWidth="1" flexibleWidth="1" />
                    <Button text="Request Remove &#10;Last Submission" onClick="send_remove_request_ui" color="#bb1717d0" textColor="white" width="120" height="36" preferredWidth="120" preferredHeight="36" fontSize="14" />
                    <Button text="Close" onClick="loadCameraTimerMenu" color="#888888" textColor="white" width="80" height="36" preferredWidth="80" preferredHeight="36" fontSize="16" />
                </HorizontalLayout>
            </VerticalLayout>
        </Panel>
    </Canvas>
    ]], game_id, rows_xml, (last_anonymize_names and "true" or "false"))
end

local function update_notes_field(player, value, id)
    last_notes = tostring(value or "")
end

local function update_act_dropdown(player, value, id)
    last_selected_act = tostring(value or "basegame")
end

local function update_anonymize_checkbox(player, value, id)
    -- Debug: log what we actually received
   -- broadcastToAll("Sheets: update_anonymize_checkbox called with value=" .. tostring(value) .. " (type=" .. type(value) .. ")", {1, 1, 0})
    -- Ignore the initial UI setup call (player is empty when UI is first set)
    if not player or tostring(player) == "" then
        return
    end

    -- Handle various Toggle value formats coming from an actual user action
    if value == true or value == "true" or value == "True" or value == 1 or value == "1" then
        last_anonymize_names = true
        broadcastToAll("Sheets: anonymize names = TRUE", {0.2, 0.8, 0.2})
    else
        last_anonymize_names = false
        broadcastToAll("Sheets: anonymize names = FALSE", {0.8, 0.2, 0.2})
    end
end

local function open_preview(player, value, id)
    -- broadcastToAll("Sheets preview: open_preview called", {0.3,0.7,0.3})
    -- Clear tooltip so it doesn't persist
    pcall(function()
        UI.setAttribute("sheetsSendBtn", "tooltip", "")
        UI.setAttribute("sheetsSendBtn", "tooltipBackgroundColor", "")
    end)
    pcall(function() Global.call("refresh_player_steam_name_cache_from_seated") end)
    -- Prefer the stored game roster so a player leaving does not drop them from the sheet snapshot.
    local active = get_sheets_player_roster()
    -- broadcastToAll("Sheets preview: open_preview active count=" .. tostring(#active), {0.3,0.7,0.3})
    -- Debug: broadcast resolved names to help diagnose empty name issue
    local resolved = {}
    for _, p in ipairs(active) do
        local name = nil
        if type(p) == "table" and p.color then
            -- Try cached steam name first, then live Player reference
            local cached_name = nil
            pcall(function() cached_name = Global.call("get_cached_steam_name", p.color) end)
            if cached_name and cached_name ~= "" and cached_name ~= p.color then
                name = cached_name
            else
                local ok, pl = pcall(function() return Player[p.color] end)
                if ok and pl and pl.steam_name and pl.steam_name ~= "" then
                    name = pl.steam_name
                else
                    name = p.color
                end
            end
        elseif type(p) == "string" then
            -- Try cached steam name first, then live Player reference
            local cached_name = nil
            pcall(function() cached_name = Global.call("get_cached_steam_name", p) end)
            if cached_name and cached_name ~= "" and cached_name ~= p then
                name = cached_name
            else
                local ok, pl = pcall(function() return Player[p] end)
                if ok and pl and pl.steam_name and pl.steam_name ~= "" then name = pl.steam_name else name = p end
            end
        else
            name = tostring(p)
        end
        table.insert(resolved, name)
    end
    if #resolved == 0 then
        -- broadcastToAll("Sheets Preview: no active players found", {1,0.5,0})
    else
        -- broadcastToAll("Sheets Preview players: " .. table.concat(resolved, ", "), {0.2,0.8,0.2})
    end
    local previewXml = generate_preview_xml(active)
    -- Announce where collected game data/results can be viewed when opening preview
    pcall(function()
        broadcastToAll("All collected data / game results can be viewed here: https://laurens1234.github.io/arcs-arsenal/data")
    end)
    UI.setXml(previewXml)
end

_G["open_sheets_preview_ui"] = open_preview

-- Build payload from active players and send to the webhook (used by preview Send Now)
local function send_preview_to_sheet(player, value, id)
    pcall(function() Global.call("refresh_player_steam_name_cache_from_seated") end)
    local active = get_sheets_player_roster()
    local rows = {}
    for _, p in ipairs(active) do
        local color = nil
        local name = nil
        if type(p) == "table" and p.color then
            color = p.color
            local ok, pl = pcall(function() return Player[p.color] end)
            if ok and pl and pl.steam_name and pl.steam_name ~= "" then name = pl.steam_name else name = p.color end
        elseif type(p) == "string" then
            color = p
            local ok, pl = pcall(function() return Player[p] end)
            if ok and pl and pl.steam_name and pl.steam_name ~= "" then name = pl.steam_name else name = p end
        else
            name = tostring(p)
        end

        local arcs_player = nil
        if color then
            local ok, ap = pcall(function() return get_arcs_player(color) end)
            if ok and ap then arcs_player = ap end
        elseif type(p) == "table" and p.color then arcs_player = p end

        local power = ""; local objective = ""; local hand_size = ""; local tycoon = ""; local captives = ""; local trophies = ""; local keeper = ""; local empath = ""
        if arcs_player and type(arcs_player.update_score) == "function" then
            pcall(function() arcs_player:update_score() end)
            power = arcs_player.power or ""
            objective = arcs_player.objective or ""
            hand_size = arcs_player.hand_size or ""
            tycoon = arcs_player.tycoon or ""
            captives = arcs_player.captives or ""
            trophies = arcs_player.trophies or ""
            keeper = arcs_player.keeper or ""
            empath = arcs_player.empath or ""

            -- try to read actual score_board labels if present
            local sb = arcs_player.score_board
            if not sb and arcs_player.color then
                local sb_guid = get_player_guid(arcs_player.color, "score_board")
                if sb_guid then pcall(function() sb = getObjectFromGUID(sb_guid) end) end
            end
            local score_labels = read_score_button_labels(sb, {
                power = power,
                objective = objective,
                hand_size = hand_size,
                tycoon = tycoon,
                captives = captives,
                trophies = trophies,
                keeper = keeper,
                empath = empath,
            })
            power = score_labels.power
            objective = score_labels.objective
            hand_size = score_labels.hand_size
            tycoon = score_labels.tycoon
            captives = score_labels.captives
            trophies = score_labels.trophies
            keeper = score_labels.keeper
            empath = score_labels.empath
        end

        -- detect initiative for this row as well
        local initiative_player = resolve_initiative_player_color()
        local has_initiative = false
        if initiative_player and color and tostring(initiative_player) == tostring(color) then has_initiative = true end

        table.insert(rows, {
            full_name = name,
            name = name,
            color = color,
            initiative = has_initiative,
            power = power,
            objective = objective,
            hand_size = hand_size,
            tycoon = tycoon,
            captives = captives,
            trophies = trophies,
            keeper = keeper,
            empath = empath,
        })
    end

    -- Prefer using the last preview rows if available so the posted payload matches the preview
    local rows_to_send = nil
    if last_preview_rows and type(last_preview_rows) == "table" and #last_preview_rows > 0 then
        rows_to_send = last_preview_rows
    else
        rows_to_send = rows
    end

    -- Always refresh names from current cache/live seat state so seat-takeovers
    -- override any stale preview name values for the same color.
    if rows_to_send and type(rows_to_send) == "table" then
        for _, row in ipairs(rows_to_send) do
            local color = row and row.color
            if color and color ~= "" then
                local updated_name = nil
                local cached_name = nil
                pcall(function() cached_name = Global.call("get_cached_steam_name", color) end)
                if cached_name and cached_name ~= "" and cached_name ~= color then
                    updated_name = cached_name
                else
                    local ok, pl = pcall(function() return Player[color] end)
                    if ok and pl and pl.steam_name and pl.steam_name ~= "" then
                        updated_name = pl.steam_name
                    else
                        updated_name = color
                    end
                end
                row.full_name = updated_name
                row.name = updated_name
            end
        end
    end

    -- Apply anonymization if checkbox is enabled
    if last_anonymize_names and rows_to_send and type(rows_to_send) == "table" and #rows_to_send > 0 then
    --    broadcastToAll("Sheets: applying anonymization to " .. tostring(#rows_to_send) .. " rows", {0.2, 0.8, 0.2})
        local anon_rows = {}
        for i, row in ipairs(rows_to_send) do
            local anon_row = {}
            for k, v in pairs(row) do
                if k == "full_name" or k == "name" then
                    anon_row[k] = "Player " .. tostring(i)
                else
                    anon_row[k] = v
                end
            end
            table.insert(anon_rows, anon_row)
        end
        rows_to_send = anon_rows
    else
   --     broadcastToAll("Sheets: anonymize_names=" .. tostring(last_anonymize_names) .. ", rows=" .. tostring(rows_to_send and #rows_to_send or 0), {0.8, 0.6, 0.2})
    end

    -- Capture notes from the stored global
    local notes = last_notes or ""
    broadcastToAll("Sheets: notes being sent: " .. tostring(notes), {0.8, 0.8, 0.2})

    -- Get game ID from Global
    local game_id = ""
    pcall(function()
        game_id = Global.getVar("game_id") or ""
    end)
    broadcastToAll("Sheets: game_id being sent: " .. tostring(game_id), {0.8, 0.8, 0.2})

    local payload = { game_id = game_id, players = rows_to_send, notes = notes, act = last_selected_act }
    local body_json = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    -- Debug: show payload being sent (truncated)
    local dbg = body_json
    if #dbg > 1200 then dbg = dbg:sub(1,1200) .. "... (truncated)" end
    broadcastToAll("Sheets: sending JSON payload (truncated): " .. tostring(dbg), {0.2,0.5,1})

    if not WebRequest or not WebRequest.custom then
        broadcastToAll("Sheets: WebRequest API not available", {1,0,0})
        return
    end

    local url_with_q = WEBHOOK_URL .. "?payload=" .. url_encode(body_json)
    local ok, err = pcall(function()
        WebRequest.custom(url_with_q, "POST", true, body_json, headers, function(response)
            _broadcast_response(response)
        end)
    end)
    if not ok then broadcastToAll("Sheets: WebRequest.custom error: " .. tostring(err), {1,0,0}) end
    -- close preview after send
    pcall(function() loadCameraTimerMenu(true) end)
end

_G["send_preview_to_sheet_ui"] = send_preview_to_sheet
_G["update_notes_field"] = update_notes_field
_G["update_act_dropdown"] = update_act_dropdown
_G["update_anonymize_checkbox"] = update_anonymize_checkbox

local function send_remove_request(player, value, id)
    -- `player` is the color string of the requester when called from UI
    local requester_color = ""
    local requester_name = ""
    local pt = type(player)
    -- `player` may be a color string, a table, or a Player userdata object
    if pt == "string" then
        requester_color = tostring(player)
    elseif pt == "table" or pt == "userdata" then
        -- try to read `.color` and `.steam_name` safely
        pcall(function()
            if player.color then requester_color = tostring(player.color) end
        end)
        pcall(function()
            if player.steam_name and player.steam_name ~= "" then requester_name = player.steam_name end
        end)
        -- some userdata may offer getColor()
        if requester_color == "" then
            pcall(function()
                if player.getColor then requester_color = tostring(player.getColor()) end
            end)
        end
    else
        requester_color = tostring(player or "")
    end

    -- fallback: try Player[color] lookup for steam_name
    if (not requester_name or requester_name == "") and requester_color and requester_color ~= "" then
        pcall(function()
            local pl = Player[requester_color]
            if pl and pl.steam_name and pl.steam_name ~= "" then requester_name = pl.steam_name end
        end)
    end

    -- final fallback to something readable
    if not requester_name or requester_name == "" then
        if requester_color and requester_color ~= "" then requester_name = requester_color else requester_name = tostring(player or "") end
    end

    -- Apply anonymization to requester name if checkbox is enabled
    if last_anonymize_names then
        requester_name = "Requester"
    end

    local game_id = ""
    pcall(function() game_id = Global.getVar("game_id") or "" end)

    local payload = {
        action = "remove_request",
        game_id = game_id,
        notes = last_notes or "",
        requester = requester_name,
        requester_color = requester_color,
        timestamp = os.time()
    }
    local body_json = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    broadcastToAll("Sheets: sending remove request for game " .. tostring(game_id) .. " from " .. tostring(requester_name), {1,0.6,0.6})

    if not WebRequest or not WebRequest.custom then
        broadcastToAll("Sheets: WebRequest API not available; cannot send remove request", {1,0,0})
        return
    end

    local url_with_q = WEBHOOK_URL .. "?payload=" .. url_encode(body_json)
    local ok, err = pcall(function()
        WebRequest.custom(url_with_q, "POST", true, body_json, headers, function(response)
            if response and response.is_error then
                local text = (response and response.text) and response.text or tostring(response)
                broadcastToAll("Sheets: remove request failed - " .. tostring(text), {1,0,0})
            else
                broadcastToAll("Sheets: remove request sent", {0.8, 0.9, 1})
                if response and response.text then broadcastToAll("Sheets response: " .. tostring(response.text), {0.8,0.9,1}) end
            end
        end)
    end)
    if not ok then broadcastToAll("Sheets: WebRequest.custom error sending remove request: " .. tostring(err), {1,0,0}) end
    -- close preview after request
    pcall(function() loadCameraTimerMenu(true) end)
end

_G["send_remove_request_ui"] = send_remove_request

function SheetsSender.generateButtonXml()
    return [[
        <VerticalLayout
    id="sheetsSenderLayout"
    allowDragging="true"
    returnToOriginalPositionWhenReleased="false"
    rectAlignment="UpperRight"
    anchorMin="1 1"
    anchorMax="1 1"
    offsetXY="0 -150"
        width="105"
    height="60"
        childForceExpandHeight="false"
        childForceExpandWidth="false"
        >
        <Button
            id="sheetsSendBtn"
            onClick="open_sheets_preview_ui"
            text="Submit Results"
            textColor="white"
            color="#2e8b57"
            tooltipBackgroundColor="#2e8b57"
            tooltipTextColor="Black"
            width="95"
            height="40"
            preferredWidth="95"
            preferredHeight="40"
            fontSize="14"
            />
    </VerticalLayout>
    ]]
end

return SheetsSender
