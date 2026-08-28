-- Sends active players' steam names, colors and hand contents to a localhost overlay

local LOCAL_OVERLAY_URL = "http://127.0.0.1:3000/overlay" -- change if your overlay server listens elsewhere
local overlay_initialized = false

local SheetsSenderOverlay = {}

-- Simple helpers copied/adapted for this module
local function url_encode(str)
    if str == nil then return "" end
    str = tostring(str)
    str = str:gsub("\n", "\r\n")
    return (str:gsub("([^%w%-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end))
end

local function is_card_object(obj)
    if not obj then return false end
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

local function format_card_label(obj)
    if not obj then return "" end
    local name = ""
    local desc = ""
    if obj.getName then name = obj.getName() end
    if obj.getDescription then desc = obj.getDescription() end
    name = name and tostring(name) or ""
    desc = desc and tostring(desc) or ""
    local lname = string.lower(name)
    -- If the name is a generic placeholder (e.g., "Action Card"), prefer description
    if (lname == "action card" or lname == "card" or string.find(lname, "action card")) and desc ~= "" then
        return desc
    end
    -- If name empty but description present, use description
    if name == "" and desc ~= "" then return desc end
    -- If both present and different, include description in parentheses
    if name ~= "" and desc ~= "" and desc ~= name then
        return name .. " (" .. desc .. ")"
    end
    if name ~= "" then return name end
    if desc ~= "" then return desc end
    return tostring(obj.guid or (obj.getGUID and obj.getGUID()) or "object")
end

-- Try several sources to obtain the active players roster
local function get_active_players()
    local roster = nil
    roster = Global.getTable("active_players")
    if type(roster) == "table" and #roster > 0 then return roster end
    roster = Global.getVar("active_players")
    if type(roster) == "table" and #roster > 0 then return roster end
    local ordered = Global.call("getOrderedPlayers", {true})
    if type(ordered) == "table" and #ordered > 0 then return ordered end
    -- last fallback: try scanning Player table keys
    local players = {}
    for k, v in pairs(Player) do
        if type(k) == "string" and k ~= "White" and v.steam_name then
            table.insert(players, k)
        end
    end
    return players
end

-- Collect hand objects for a given player color; best-effort approach
local function collect_hand_for_color(color)
    local hand_labels = {}
    local hand_count = 0
    -- Try Player[color].getHandObjects() (works in many TTS versions)
    local pl = Player[color]
    if pl then
        local hand_objs = nil
        if pl.getHandObjects then
            hand_objs = pl.getHandObjects()
        end
        if type(hand_objs) == "table" and #hand_objs > 0 then
            for _, o in ipairs(hand_objs) do
                if is_card_object(o) then
                    table.insert(hand_labels, format_card_label(o))
                end
            end
            hand_count = #hand_objs
            return hand_labels, hand_count
        end
        -- Some Player userdata expose getHandCount
        if pl.getHandCount then
            local hc = pl.getHandCount()
            if type(hc) == "number" then hand_count = hc end
        end
    end

    -- Fallback: try to find a stored arcs player with hand_size (best-effort)
    if _G["get_arcs_player"] then
        local ap = get_arcs_player(color)
        if ap and type(ap.hand_size) ~= "nil" then
            hand_count = tonumber(ap.hand_size) or hand_count
        end
    end

    return hand_labels, hand_count
end

-- Build payload and send POST to localhost overlay
local function send_overlay_update(player, value, id)
    -- Initialize overlay on first call with setup instructions
    if not overlay_initialized then
        overlay_initialized = true
        broadcastToAll("Overlay: Active. Streamer: Open http://127.0.0.1:3000 in OBS Browser Source or your browser to display player hands.", {0.2, 0.8, 0.2})
    end

    local hide_cards = _G["overlay_cards_hidden"] == true

    -- Get turn order from Turns object
    local turn_order = {}
    local turn_result = Turns.getTurnOrder()
    if type(turn_result) == "table" then
        turn_order = turn_result
    end

    local roster = get_active_players() or {}
    local rows = {}
    for _, p in ipairs(roster) do
        local color = nil
        local steam_name = nil
        if type(p) == "table" and p.color then color = p.color
            local pl = Player[p.color]
            if pl and pl.steam_name and pl.steam_name ~= "" then steam_name = pl.steam_name else steam_name = p.color end
        elseif type(p) == "string" then
            color = p
            local pl = Player[p]
            if pl and pl.steam_name and pl.steam_name ~= "" then steam_name = pl.steam_name else steam_name = p end
        else
            steam_name = tostring(p)
            color = tostring(p)
        end

        local hand_labels, hand_count = collect_hand_for_color(color)

        table.insert(rows, {
            steam_name = steam_name or "",
            color = color or "",
            hand = hand_labels,
            hand_size = hand_count or 0,
        })
    end

    -- Include overlay alignment (left/right) if set in Global
    local overlay_align = _G["overlay_align"] or "left"
    local payload = { source = "tts", timestamp = os.time(), players = rows, turn_order = turn_order, align = overlay_align, hide_cards = hide_cards }
    local body_json = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    if not WebRequest or not WebRequest.custom then
        broadcastToAll("Overlay sender: WebRequest API not available", {1,0,0})
        return
    end

    -- Send asynchronously to the local overlay server
    WebRequest.custom(LOCAL_OVERLAY_URL, "POST", true, body_json, headers, function(response)
        if response and response.is_error then
            local text = (response and response.text) and response.text or tostring(response)
            broadcastToAll("Overlay send failed - " .. tostring(text), {1,0,0})
        else
           -- broadcastToAll("Overlay: update sent", {0.2, 0.8, 0.2})
        end
    end)
end

_G["send_overlay_update_ui"] = send_overlay_update

local function clear_overlay()
    local payload = { source = "tts", timestamp = os.time(), players = {}, turn_order = {}, align = (_G["overlay_align"] or "left"), hide_cards = true }
    local body_json = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    if not WebRequest or not WebRequest.custom then
        return
    end

    WebRequest.custom(LOCAL_OVERLAY_URL, "POST", true, body_json, headers, function(_) end)
end

_G["clear_overlay_ui"] = clear_overlay

return SheetsSenderOverlay
