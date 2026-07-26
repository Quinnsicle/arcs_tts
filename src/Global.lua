local authors = "Quinnsicle, Scyth02, McChew, fallspectrum, Laurens"
local version = "1.0"
local game_id = "" -- unique ID for this game session, generated on first load

require("src/GUIDs")

available_colors = {"White", "Yellow", "Red", "Teal", "Pink"}

----------------------------------------------------
-- [DEBUG] REMEMBER TO SET TO FALSE BEFORE RELEASE
----------------------------------------------------
debug = true
debug_player_count = 2
----------------------------------------------------

with_leaders = false
with_more_to_explore = false
is_face_up_discard_active = false
with_miniatures = false
with_laurens_custom_leader = false
with_pnp2_lost_vaults = false
with_pnp3_leaders = false
dont_use_base_and_pack_leaders = false
use_scavengers_scouts_deck = false
is_auto_end_round_enabled = false -- toggle end round
is_basegame_setup = false
turn_count = 0
leader_draft_count = nil
lore_draft_count = nil

oop_components = {
  {
    Sector = {
      pos = {-0.16, 0.97, -1.02},
      rot = {0, 180, -0.01},
      scale = {2.48, 1, 2.48},
      img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769502/1D85B9468BB538D788FCF7576A05606918CD0DD4/"
    },
    Gate = {
      pos = {-0.04, 0.97, -0.63},
      rot = {0, 189.24, -0.01},
      scale = {0.71, 1, 0.71},
      img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769214/A4AD66554742C2FFA93612948C38641B813947FB/"
    }
  }, {
    Sector = {
      pos = {-0.50, 0.97, -0.64},
      rot = {0, 180, -0.01},
      scale = {2.48, 1, 2.48},
      img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769605/A40A0C79B27F1F1C45E0570E46BA8A7B253F356E/"
    },
    Gate = {
      pos = {-0.23, 0.97, -0.21},
      rot = {0, 252.52, 0},
      scale = {0.44, 1, 0.44},
      img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
    }
  }, {
    Sector = {
      pos = {-0.45, 0.97, 0.73},
      rot = {0, 179.99, -0.01},
      scale = {2.36, 1, 2.36},
      img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769710/C408A11914F7F4DEA83686851730DDF10A8BD5D4/"
    },
    Gate = {
      pos = {-0.2, 0.97, 0.28},
      rot = {0, 305.16, 0},
      scale = {0.44, 1, 0.44},
      img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
    }
  }, {
    Sector = {
      pos = {0.17, 0.97, 0.90},
      rot = {0, 179, -0.01},
      scale = {2.54, 1, 2.54},
      img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769816/0AA42154550040133E7D6740F85CD487D5F6967B/"
    },
    Gate = {
      pos = {0.05, 0.97, 0.52},
      rot = {-0.01, 12.02, 0},
      scale = {0.71, 1, 0.71},
      img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769214/A4AD66554742C2FFA93612948C38641B813947FB/"
    }
  }, {
    Sector = {
      pos = {0.5, 0.97, 0.55},
      rot = {0, 179.99, -0.01},
      scale = {2.48, 1, 2.48},
      img = "http://cloud-3.steamusercontent.com/ugc/2313225941445770194/8600421030523070B8E2F05CECC3281DF24989AC/"
    },
    Gate = {
      pos = {0.24, 0.97, 0.1},
      rot = {-0.01, 72.87, -0.01},
      scale = {0.44, 1, 0.44},
      img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
    }
  }, {
    Sector = {
      pos = {0.46, 0.97, -0.82},
      rot = {0, 180.00, -0.01},
      scale = {2.29, 1, 2.29},
      img = "http://cloud-3.steamusercontent.com/ugc/2313225941445770362/76677A077FC1D6CD3672DCC036646ABFD2881F62/"
    },
    Gate = {
      pos = {0.2, 0.97, -0.39},
      rot = {-0.01, 125.02, -0.01},
      scale = {0.44, 1, 0.44},
      img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
    }
  }
}

initiative_player_position = {-2, 0, 0}

active_players = {}
starting_players = {}

-- Cache player steam names early so they survive if players leave before submission
local player_steam_name_cache = {}
function cache_player_steam_names()
    player_steam_name_cache = {}
    local seated = getSeatedPlayers()
    if seated and #seated > 0 then
        for _, color in ipairs(seated) do
            local ok, player = pcall(function() return Player[color] end)
            if ok and player and player.steam_name and player.steam_name ~= "" then
                player_steam_name_cache[color] = player.steam_name
            else
                player_steam_name_cache[color] = color
            end
        end
    end
    Global.setVar("player_steam_name_cache", player_steam_name_cache)
end

  -- Update cache from currently seated players without clearing existing entries.
  -- This preserves names for disconnected players while allowing seat-takeover overrides.
  function refresh_player_steam_name_cache_from_seated()
    local cache = Global.getVar("player_steam_name_cache") or player_steam_name_cache or {}
    local seated = getSeatedPlayers()
    if seated and #seated > 0 then
      for _, color in ipairs(seated) do
        local ok, player = pcall(function() return Player[color] end)
        if ok and player and player.steam_name and player.steam_name ~= "" then
          cache[color] = player.steam_name
        else
          cache[color] = color
        end
      end
    end
    player_steam_name_cache = cache
    Global.setVar("player_steam_name_cache", player_steam_name_cache)
  end

  local function update_cached_steam_name_for_color(color)
    if not color or color == "" or color == "Grey" then return end
    local cache = Global.getVar("player_steam_name_cache") or player_steam_name_cache or {}
    local ok, player = pcall(function() return Player[color] end)
    if ok and player and player.steam_name and player.steam_name ~= "" then
      cache[color] = player.steam_name
    else
      cache[color] = color
    end
    player_steam_name_cache = cache
    Global.setVar("player_steam_name_cache", player_steam_name_cache)
  end

  function onPlayerConnect(player)
    local color = nil
    pcall(function()
      if player and player.color then color = tostring(player.color) end
    end)
    if color and color ~= "" and color ~= "Grey" then
      update_cached_steam_name_for_color(color)
    end
  end

  function onPlayerChangeColor(player_color)
    local color = tostring(player_color or "")
    if color ~= "" and color ~= "Grey" then
      update_cached_steam_name_for_color(color)
    end
    Wait.time(function()
      refresh_player_steam_name_cache_from_seated()
    end, 0.2)
  end

-- Retrieve cached steam name for a player, fallback to color if not cached
function get_cached_steam_name(color)
    local cache = Global.getVar("player_steam_name_cache") or {}
    return cache[color] or color
end

active_ambitions = {
    c9e0ee = "",
    a9b02a = "",
    b0b4d0 = ""
}

zoneWaits = {}
-- track which deck objects we've already patched with the draw-bottom menu
draw_bottom_patched = {}
local OverlayChatCommands = require("src/events/OverlayChatCommands")
local DropActionEvents = require("src/events/DropActionEvents")
local score_ambitions_run_id = 0

-- Scan the action deck zone periodically and attach the "Draw bottom card" menu
function scan_action_deck_zone()
  local zone = getObjectFromGUID(action_deck_zone_GUID)
  if not zone then return end

  local found = {}
  local objs = zone.getObjects()
  if objs then
    for _, obj in ipairs(objs) do
      local is_deck = false
      -- prefer the stable tag, fall back to name property/method
      if obj.tag and obj.tag == "Deck" then
        is_deck = true
      elseif obj.getName and obj.getName() == "Deck" then
        is_deck = true
      elseif obj.name == "Deck" then
        is_deck = true
      end
      if is_deck then
        local guid = nil
        if obj.getGUID then guid = obj.getGUID() end
        if not guid and obj.guid then guid = obj.guid end
        if guid then
          found[guid] = true
          if not draw_bottom_patched[guid] then
            pcall(function()
              obj.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)
            end)
            draw_bottom_patched[guid] = true
          end
        end
      end
    end
  end

  -- Remove tracking for decks that have left or been destroyed
  for guid, _ in pairs(draw_bottom_patched) do
    if not found[guid] then
      draw_bottom_patched[guid] = nil
    end
  end
end
 
-- Chat commands for overlay control:
--  !overlay start   -> enable automatic sending each turn
--  !overlay stop    -> disable automatic sending
--  !overlay once    -> send one immediate update
--  !overlay status  -> show current state
--  !overlay help    -> show this command list
function onChat(message, player)
  if OverlayChatCommands.handle(message) then
    return
  end
end

function schedule_scan()
  scan_action_deck_zone()
  Wait.time(schedule_scan, 2)
end
----------------------------------------------------
AmbitionMarkers = require("src/AmbitionMarkers")
local ActionCards = require("src/ActionCards")
local ArcsPlayer = require("src/ArcsPlayer")
local BaseGame = require("src/BaseGame")
local Campaign = require("src/Campaign")
local Control = require("src/Control")
local Counters = require("src/Counters")
local Initiative = require("src/InitiativeMarker")
local RoundManager = require("src/RoundManager")
local SetupControl = require("src/SetupControl")
local Supplies = require("src/Supplies")
local Camera = require("src/Camera")
local Timer = require("src/Timer")
local LOG = require("src/LOG")
local SheetsSender = require("src/SheetsSender")
local ErrataFaqService = require("src/integrations/ErrataFaqService")
local SheetsSenderOverlay = nil

-- Whether to automatically send overlay updates each turn when enabled
overlay_sending_enabled = false
overlay_cards_hidden = false
-- Overlay alignment: 'left' (default) or 'right'
overlay_align = "left"

-- Try to require overlay sender if present (optional)
SheetsSenderOverlay = require("src/SheetsSenderOverlay")

-- Generate a unique ID for this game session
local function generate_game_id()
    local seed = os.time() * 1000 + math.random(1, 999)
    return string.format("%X", seed)
end

-- Proxy to refresh ambitions from other script contexts.
-- Some object scripts cannot safely call Global-setter operations
-- directly, so call this function via `Global.call('ambition_refresh_proxy')`.
function ambition_refresh_proxy()
  pcall(function() AmbitionMarkers.refresh_all_ambitions() end)
end

-- Mark a specific ambition marker GUID as undeclared in the global ambitions map.
-- Called via `Global.call('ambition_set_marker_undeclared', guid)` from other scripts.
function ambition_set_marker_undeclared(guid)
  if not guid then return end
  pcall(function()
    local active = Global.getVar('active_ambitions') or {}
    active[guid] = ""
    Global.setVar('active_ambitions', active)
    pcall(function() Global.call('update_player_scores') end)
  end)
end

function assignPlayerToAvailableColor(player, color)
    local color = table.remove(available_colors, 1)
    broadcastToAll("\nAssigning " .. player.steam_name .. " to color " .. color)
    player.changeColor(color)
end

function get_arcs_player(color)
    for _, p in ipairs(active_players) do
        if (p.color == color) then
            return p
        end
    end
end

DropActionEvents.configure({
    get_arcs_player = get_arcs_player,
    get_action_cards = function() return ActionCards end,
    ambition_get_info = function(obj) return AmbitionMarkers.get_ambition_info(obj) end,
    log_warning = function(message) LOG.WARNING(message) end,
    log_debug = function(message) LOG.DEBUG(message) end,
    action_card_zone_GUID = action_card_zone_GUID,
    seize_zone_GUID = seize_zone_GUID,
    zone_waits = zoneWaits
})

function update_player_scores()
    for _, p in ipairs(active_players) do
        p:update_score()
    end
    -- After updating player score widgets, compute detailed ambition point estimates
    -- (stored in Global but NOT automatically broadcast; use context menu on markers to show)
    local ok, breakdown = pcall(function()
        local AmbitionMarkers = AmbitionMarkers
        if AmbitionMarkers and AmbitionMarkers.build_detailed_estimates then
            return AmbitionMarkers:build_detailed_estimates()
        end
        return nil
    end)
    if ok and breakdown then
        Global.setVar("ambition_point_estimates_detailed", breakdown)
    end
end

-- Helper function to convert player color name to RGB
local function color_name_to_rgb(color_name)
    local color_map = {
    White = {1, 1, 1},
    Brown = {0.443, 0.231, 0.09},
    Red = {0.856, 0.1, 0.094},
    Orange = {0.956, 0.392, 0.113},
    Yellow = {0.905, 0.898, 0.172},
    Green = {0.192, 0.701, 0.168},
    Teal = {0.129, 0.694, 0.607},
    Blue = {0.118, 0.53, 1},
    Purple = {0.627, 0.125, 0.941},
    Pink = {0.96, 0.439, 0.807},
    Grey = {0.5, 0.5, 0.5},
    Black = {0.25, 0.25, 0.25}
    }
  return color_map[color_name] or {0.6, 1, 0.6}
end

-- Print a detailed ambition estimates breakdown to chat.
function print_ambition_estimates()
    -- ensure player scores are up-to-date
    Global.call("update_player_scores")
    local breakdown = Global.getVar("ambition_point_estimates_detailed")

    if not breakdown then
        broadcastToAll("Could not compute ambition estimates", {1, 0.4, 0.4})
        return
    end

    -- Title
    broadcastToAll("=== Ambition Power Gain ===", {0.35, 0.7, 1})
    
    -- Totals: show gain and projected total (current + gain)
    local total_parts = {}
    for color, pts in pairs(breakdown.totals or {}) do
      local gain = tonumber(pts) or 0
      -- get current power from ArcsPlayer instance if available
      local current = 0
      local ap = get_arcs_player(color)
      if ap and ap.power ~= nil then
        current = ap.power
      end
      local projected = current + gain
      table.insert(total_parts, { color = color, gain = gain, current = current, projected = projected })
    end
    if #total_parts > 0 then
      broadcastToAll("TOTALS:", {0.6, 1, 0.6})
      for _, entry in ipairs(total_parts) do
        local player_color_rgb = color_name_to_rgb(entry.color)
        broadcastToAll("  " .. entry.color .. ": " .. tostring(entry.gain) .. " (" .. tostring(entry.current) .. " → " .. tostring(entry.projected) .. ")", player_color_rgb)
      end
    else
      broadcastToAll("No Ambition points projected.", {0.8, 0.8, 0.8})
      return
    end
    
    broadcastToAll(" ", {0.9, 0.9, 0.9})

    -- Group tokens by ambition name
    local grouped = {}
    for _, token in ipairs(breakdown.tokens or {}) do
        local ambition_name = token.ambition or ""
        if not grouped[ambition_name] then
            grouped[ambition_name] = {
                prize_sets = {},  -- list of prize arrays from each marker
                per_player = {}
            }
        end
        -- Collect all prize sets
        if #(token.prizes or {}) > 0 then
            table.insert(grouped[ambition_name].prize_sets, token.prizes)
        end
        -- Sum per-player points
        for color, pts in pairs(token.per_player or {}) do
            grouped[ambition_name].per_player[color] = (grouped[ambition_name].per_player[color] or 0) + pts
        end
    end

    -- Output grouped by ambition in order
    local ambition_order = {"Tycoon", "Tyrant", "Warlord", "Keeper", "Empath"}
    local count = 0
    for _, ambition_name in ipairs(ambition_order) do
        if grouped[ambition_name] then
            count = count + 1
            local entry = grouped[ambition_name]
            
            broadcastToAll(ambition_name .. ":", {0.45, 0.8, 1})
            
            -- Sort players by their points in descending order
            local player_scores = {}
            for color, pts in pairs(entry.per_player or {}) do 
                table.insert(player_scores, { color = color, points = pts, ambition = ambition_name })
            end
            table.sort(player_scores, function(a, b) return a.points > b.points end)
            
            -- Display results by place
            local place_labels = {[1] = "1st", [2] = "2nd", [3] = "3rd"}
            for place, entry_data in ipairs(player_scores) do
                local color = entry_data.color
                local pts = entry_data.points

              local note = ""
              if breakdown.ambition_notes and breakdown.ambition_notes[ambition_name] and breakdown.ambition_notes[ambition_name][color] then
                note = " " .. breakdown.ambition_notes[ambition_name][color]
              end

              -- Show 0-point entries only when they have an explanation (for example, demoted or blocked leaders)
              if pts > 0 or note ~= "" then
                local bonus = 0
                if breakdown.ambition_bonuses and breakdown.ambition_bonuses[ambition_name] and breakdown.ambition_bonuses[ambition_name][color] then
                  bonus = breakdown.ambition_bonuses[ambition_name][color]
                end

                local place_label = place_labels[place] or place .. "th"
                local bonus_text = ""
                if bonus > 0 then
                  bonus_text = " (+" .. tostring(bonus) .. " city bonus)"
                end

                local player_color_rgb = color_name_to_rgb(color)
                broadcastToAll("  " .. place_label .. ": " .. color .. " → " .. tostring(pts) .. bonus_text .. note, player_color_rgb)
              end
            end
            
            broadcastToAll(" ", {0.9, 0.9, 0.9})
        end
    end
end

-- Callback function for ambition marker context menu
function show_ambition_scores_menu(player_color, position, clicked_object)
    Global.call("print_ambition_estimates")
end

-- Reset/reseed ambition markers:
-- 1) Return all markers to their base slots,
-- 2) Flip the marker with the lowest current first-power,
-- 3) Move the top 3 markers by first-power to staging positions.
function reset_ambition_markers_menu(player_color, position, clicked_object)
  local reach_map = getObjectFromGUID(reach_board_GUID)
  if not reach_map then
    broadcastToColor("Could not reset ambition markers: reach board not found.", player_color or "White", {1, 0.4, 0.4})
    return
  end

  if not ambition_marker_GUIDs or #ambition_marker_GUIDs == 0 then
    broadcastToColor("Could not reset ambition markers: marker GUID list is empty.", player_color or "White", {1, 0.4, 0.4})
    return
  end

  local base_slots = {
    [1] = Vector({-0.83, 0.2, -1.07}),
    [2] = Vector({-0.92, 0.2, -1.07}),
    [3] = Vector({-1.00, 0.21, -1.07}),
    [4] = Vector({-0.83, 0.2, -1.07}),
    [5] = Vector({-0.92, 0.2, -1.07}),
    [6] = Vector({-1.00, 0.21, -1.07})
  }

  local first_power_by_index = {
    [1] = { [false] = 5, [true] = 9 },
    [2] = { [false] = 3, [true] = 6 },
    [3] = { [false] = 2, [true] = 4 },
    [4] = { [false] = 10, [true] = 6 },
    [5] = { [false] = 7, [true] = 4 },
    [6] = { [false] = 3, [true] = 5 }
  }

  local staging_positions = {
    Vector({16.28, 1.08, 5.81}),
    Vector({17.61, 1.08, 5.81}),
    Vector({18.94, 1.08, 5.82})
  }

  local function marker_first_power(idx, obj)
    local face = false
    if obj and obj.is_face_down ~= nil then face = obj.is_face_down end
    local by_face = first_power_by_index[idx] or {}
    return by_face[face] or 0
  end

  local function marker_first_power_with_face(idx, face_down)
    local by_face = first_power_by_index[idx] or {}
    return by_face[face_down] or 0
  end

  local marker_entries = {}

  -- Choose which trio to seed based on active player count:
  -- <5 players => first 3 marker GUIDs, >=5 players => last 3 marker GUIDs.
  local active_count = 0
  if type(active_players) == "table" then
    active_count = #active_players
  end
  if active_count == 0 then
    active_count = #getSeatedPlayers()
  end

  local selected = {}
  local want_low = (active_count >= 5) and 4 or 1
  local want_high = (active_count >= 5) and 6 or 3
  -- Only use the selected trio for this player count.
  for i = want_low, want_high do
    local guid = ambition_marker_GUIDs[i]
    local obj = guid and getObjectFromGUID(guid) or nil
    if obj and obj.getPosition then
      -- Return selected marker to its base slot first.
      local slot_local = base_slots[i] or base_slots[1]
      local world = reach_map.positionToWorld(slot_local)
      world.y = world.y + 0.45
      obj.setPositionSmooth(world)
      local entry = { idx = i, guid = guid, obj = obj }
      table.insert(marker_entries, entry)
      table.insert(selected, entry)
    end
  end

  if #selected == 0 then
    broadcastToColor("No selected ambition markers found for this player count.", player_color or "White", {1, 0.4, 0.4})
    return
  end

  -- Flip the lowest-power marker, but only if it is not already flipped.
  local lowest = nil
  for _, entry in ipairs(selected) do
    local is_flipped = (entry.obj and entry.obj.is_face_down == true)
    if not is_flipped then
      local p = marker_first_power(entry.idx, entry.obj)
      if not lowest or p < lowest.power then
        lowest = { entry = entry, power = p }
      end
    end
  end
  local flipped_guid = nil
  if lowest and lowest.entry and lowest.entry.obj and lowest.entry.obj.flip then
    pcall(function() lowest.entry.obj.flip() end)
    flipped_guid = lowest.entry.guid
  end

  -- Re-rank selected trio based on POST-FLIP values (deterministic; doesn't depend on flip timing).
  local projected_power = {}
  for _, entry in ipairs(selected) do
    local face = false
    if entry.obj and entry.obj.is_face_down ~= nil then face = entry.obj.is_face_down end
    if flipped_guid and flipped_guid == entry.guid then
      face = not face
    end
    projected_power[entry.guid] = marker_first_power_with_face(entry.idx, face)
  end

  table.sort(selected, function(a, b)
    local pa = projected_power[a.guid] or 0
    local pb = projected_power[b.guid] or 0
    if pa == pb then
      return a.idx < b.idx
    end
    return pa > pb
  end)

  for i = 1, math.min(3, #selected) do
    local entry = selected[i]
    local target = staging_positions[i]
    if entry and entry.obj and target then
      entry.obj.setPositionSmooth(target)
    end
  end

  -- Also move chapter pawn to the right when resetting ambition markers.
  -- If pawn is high (y > 1.1), use a smaller shift to align with snaps.
  local chapter_pawn = getObjectFromGUID(chapter_pawn_GUID)
  if chapter_pawn and chapter_pawn.getPosition then
    local cp = chapter_pawn.getPosition()
    local chapter_shift = (cp.y and cp.y > 1.1) and 0.83333 or 0.9075
    cp.x = cp.x + chapter_shift
    chapter_pawn.use_snap_points = true
    chapter_pawn.setPositionSmooth(cp, false, true)
  end

  Wait.time(function()
    pcall(function() AmbitionMarkers.refresh_all_ambitions() end)
  end, 0.8)

  broadcastToAll("Ambition markers reset and re-seeded.", {0.6, 1, 0.6})
end

-- Compute ambition gains and move each player's power cube to the right by total gain.
function apply_ambition_scores_to_power_menu(player_color, position, clicked_object)
  score_ambitions_run_id = score_ambitions_run_id + 1
  local run_id = score_ambitions_run_id
  Global.call("update_player_scores")
  local breakdown = Global.getVar("ambition_point_estimates_detailed")
  if not breakdown or not breakdown.totals then
    broadcastToColor("Could not compute ambition scores.", player_color or "White", {1, 0.4, 0.4})
    return
  end

  pcall(function()
    Global.call("print_ambition_estimates")
  end)

  local moved_parts = {}
  local power_step = 0.655
  local power_zero_x = -13.26
  local power_cubes = getObjectsWithTag("power") or {}
  local function power_from_x(x)
    local p = math.floor((x + 13.26) / 0.655)
    if p < 0 then p = 0 end
    return p
  end
  local function x_from_power(power_value)
    -- Small epsilon keeps us inside the intended floor bucket.
    return power_zero_x + (power_value * power_step) + 0.001
  end

  for color, gain in pairs(breakdown.totals) do
    local delta = tonumber(gain) or 0
    if delta ~= 0 then
      local cube = nil
      local color_tag = tostring(color) .. "Piece"
      for _, obj in ipairs(power_cubes) do
        if obj and obj.hasTag and obj.hasTag(color_tag) then
          cube = obj
          break
        end
      end

      if cube and cube.getPosition then
        local pos = cube.getPosition()
        local start_power = power_from_x(pos.x)
        local target_power = start_power + delta
        if target_power < 0 then target_power = 0 end
        pos.x = x_from_power(target_power)
        local end_power = power_from_x(pos.x)
        cube.setPosition(pos)
        table.insert(moved_parts, tostring(color) .. ": " .. tostring(start_power) .. " -> " .. tostring(end_power) .. " (+" .. tostring(delta) .. ")")
      else
        table.insert(moved_parts, tostring(color) .. ": no power cube found")
      end
    end
  end

  if #moved_parts == 0 then
    broadcastToAll("No ambition power gain to apply.", {0.8, 0.8, 0.8})
  else
    -- Recompute displayed scores after moving power cubes.
    -- Run multiple delayed passes to handle slower physics/snap settling.
    local refresh_delays = {0.35, 0.9, 1.8}
    for _, delay in ipairs(refresh_delays) do
      Wait.time(function()
        Global.call("update_player_scores")
      end, delay)
    end

    -- After score updates settle, check win threshold and prompt result submission.
    Wait.time(function()
      if run_id ~= score_ambitions_run_id then
        return
      end

      pcall(function()
        Global.call("update_player_scores")
      end)

      -- Skip win-congrats + submission prompt during campaign games.
      local is_campaign_game = false
      pcall(function()
        local campaign_rules = getObjectFromGUID(Campaign.guids.rules)
        if campaign_rules and campaign_rules.getDescription and campaign_rules.getDescription() == "active" then
          is_campaign_game = true
        end
      end)
      if is_campaign_game then
        return
      end

      local player_count = #active_players
      local win_threshold = 27
      if player_count == 2 then
        win_threshold = 33
      elseif player_count == 3 then
        win_threshold = 30
      end

      local contenders = {}
      for _, p in ipairs(active_players) do
        local score = tonumber(p and p.power) or 0
        if score > win_threshold then
          table.insert(contenders, { color = tostring(p.color or "Player"), score = score })
        end
      end

      if #contenders == 0 then
        return
      end

      local best_score = -999999
      for _, c in ipairs(contenders) do
        if c.score > best_score then
          best_score = c.score
        end
      end

      local tied = {}
      for _, c in ipairs(contenders) do
        if c.score == best_score then
          table.insert(tied, c)
        end
      end

      local winner = tied[1]
      if #tied > 1 then
        local initiative_color = tostring(initiative_player or "")
        if initiative_color ~= "" then
          for _, c in ipairs(tied) do
            if c.color == initiative_color then
              winner = c
              break
            end
          end

          if winner == tied[1] and winner.color ~= initiative_color then
            local tied_by_color = {}
            for _, c in ipairs(tied) do
              tied_by_color[c.color] = c
            end
            local ordered = getOrderedPlayersStartingWith(initiative_color)
            for _, p in ipairs(ordered or {}) do
              local color = tostring(p and p.color or "")
              if tied_by_color[color] then
                winner = tied_by_color[color]
                break
              end
            end
          end
        end
      end

      if winner then
        broadcastToAll("Congrats " .. winner.color .. " - you win with " .. tostring(winner.score) .. " Power!", Color.Green)
      end

      if _G["open_sheets_preview_ui"] then
        pcall(function()
          _G["open_sheets_preview_ui"](player_color, "", "")
        end)
      end

      broadcastToAll("Do you want to submit the game result now? The Sheets window is open.", {0.6, 1, 0.6})
    end, 2.1)
  end
end

-- Attach context menu items to all ambition markers.
function attach_ambition_marker_menus()
    if not ambition_marker_GUIDs or #ambition_marker_GUIDs == 0 then
        print("[DEBUG] attach_ambition_marker_menus: ambition_marker_GUIDs is empty or nil")
        return
    end
    
    local function try_attach(attempt)
        attempt = attempt or 1
        local attached_count = 0
        local markers_found = 0
        
        for i = 1, #ambition_marker_GUIDs do
            local guid = ambition_marker_GUIDs[i]
            local marker = getObjectFromGUID(guid)
            if marker then
                markers_found = markers_found + 1
                local ok, err = pcall(function()
                    marker.addContextMenuItem("Show Ambition Scores", show_ambition_scores_menu)
                marker.addContextMenuItem("Score Ambitions", apply_ambition_scores_to_power_menu)
                marker.addContextMenuItem("Reset Markers", reset_ambition_markers_menu)
                end)
                if ok then
                    attached_count = attached_count + 1
                else
                    print("[DEBUG] Failed to attach menu to marker " .. guid .. ": " .. tostring(err))
                end
            end
        end
        
        -- Also attach to chapter pawn
        local chapter_pawn = getObjectFromGUID(chapter_pawn_GUID)
        if chapter_pawn then
            markers_found = markers_found + 1
            local ok, err = pcall(function()
                chapter_pawn.addContextMenuItem("Show Ambition Scores", show_ambition_scores_menu)
          chapter_pawn.addContextMenuItem("Score Ambitions", apply_ambition_scores_to_power_menu)
          chapter_pawn.addContextMenuItem("Reset Markers", reset_ambition_markers_menu)
            end)
            if ok then
                attached_count = attached_count + 1
            else
                print("[DEBUG] Failed to attach menu to chapter pawn: " .. tostring(err))
            end
        end
        
        LOG.DEBUG("attempt " .. attempt .. "] Found " .. markers_found .. " objects, attached to " .. attached_count)
        
        -- If we didn't find all markers, retry in a moment
        if markers_found < (#ambition_marker_GUIDs + 1) and attempt < 5 then
            Wait.time(function()
                try_attach(attempt + 1)
            end, 0.5)
        end
    end
    
    try_attach(1)
end


function onObjectDrop(player_color, object) -- this is being called from orig later to fix other edifice tokens spawn
    DropActionEvents.handle_object_drop(player_color, object)
end

function onPlayerAction(player, action, targets)
    DropActionEvents.handle_player_action(player, action, targets, onObjectDrop)
end

function onObjectEnterScriptingZone(zone, object)
  if not zone or not object then return end

  -- Only care about decks entering the action deck zone
  if zone.getGUID and zone.getGUID() == action_deck_zone_GUID then
    local is_deck = false
    if object.tag and object.tag == "Deck" then is_deck = true end
    if object.getName and object.getName() == "Deck" then is_deck = true end
    if object.name == "Deck" then is_deck = true end
    if not is_deck then return end
    local guid = nil
    if object.getGUID then guid = object.getGUID() end
    if not guid and object.guid then guid = object.guid end
    if not guid then return end
    if draw_bottom_patched[guid] then return end
    pcall(function()
      object.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)
    end)
    draw_bottom_patched[guid] = true
    LOG.DEBUG("Attached Draw-bottom to deck " .. guid)
  end
end

function onPlayerTurn(player, previous_player)

    turn_count = turn_count + 1
    if is_auto_end_round_enabled then
        if turn_count > #getSeatedPlayers() then
            RoundManager.endRound() -- turn count is reset within RoundManager.endRound()
        end
    end
  -- If overlay sending is enabled, push an update each time the turn advances
  if overlay_sending_enabled then
    if _G["send_overlay_update_ui"] then
      pcall(function() _G["send_overlay_update_ui"]() end)
    end
  end

end

local function is_overlay_hand_card(obj)
  if not obj then return false end
  local tag = obj.tag or obj.type
  return tag == "Card" or tag == "Deck"
end

function onObjectEnterZone(zone, object)
    Counters.update(zone)

    local zone_name = zone.getName()
    if (zone_name == "player" or zone_name == "trophies" or zone_name ==
        "captives" or zone_name == "hand") then
        local zone_color = zone.getDescription()
        for _, p in ipairs(active_players) do
            if (p.color == zone_color) then
                p:update_score()
            end
        end
    end

    if ((object.getGUID() == initiative_GUID or object.getGUID() ==
        seized_initiative_GUID) and zone_name == "initiative_zone") then
        local zone_color = zone.getDescription()
        Global.setVar("initiative_player", zone_color)
    end

    if zone_name == "hand" and overlay_sending_enabled and is_overlay_hand_card(object) then
      if _G["send_overlay_update_ui"] then
        _G["send_overlay_update_ui"]()
      end
    end
end

function onObjectSpawn(object)
    Initiative.add_menu()
    Supplies.addMenuToObject(object)
  ErrataFaqService.add_menu_to_card(object)
  -- If the zero marker spawns (or finishes loading), ensure its ambition button is attached
  local ok, guid = pcall(function() return object.getGUID and object.getGUID() end)
  if ok and guid and guid == zero_marker_GUID then
    pcall(function() AmbitionMarkers.add_button() end)
  end
end

function onObjectLeaveZone(zone, object)
    Counters.update(zone)

    local zone_name = zone.getName()
    if (zone_name == "player" or zone_name == "trophies" or zone_name ==
        "captives" or zone_name == "hand") then
        local zone_color = zone.getDescription()
        for _, p in ipairs(active_players) do
            if (p.color == zone_color) then
                p:update_score()
            end
        end
    end

    -- create a unique wait ID
    local wait_id = zone.getGUID() .. object.getGUID()

    -- check for and remove the Wait.condition if it exists
    if zoneWaits[wait_id] then
        Wait.stop(zoneWaits[wait_id])
    end

    if zone_name == "hand" and overlay_sending_enabled and is_overlay_hand_card(object) then
      if _G["send_overlay_update_ui"] then
        _G["send_overlay_update_ui"]()
      end
    end
end

function onObjectEnterContainer(container, object)
    Counters.update(container)
end

function onObjectLeaveContainer(container, leave_object)
    Counters.update(container)
    local container_tags = container.getTags()
    if #container_tags > 0 then
        if container.type == "Bag" or container.type == "Infinite" then
            leave_object.setTags(container.getTags())

            -- set snap
            leave_object.use_snap_points = true

            -- ships pulled from supply should always be fresh
            Wait.time(function()
                if leave_object.hasTag('Ship') and leave_object.getStateId() == 2 then
                    leave_object.setState(1)
                end
            end, 0.1)
        end
    end
end

function onObjectNumberTyped(number_object, player_color, number_typed)
    if number_object.type == "Deck" then
        print(player_color .. " tried to deal a card to themselves from top of deck, which is unusual, please do it manually")
        return true
    end

    if number_object.hasTag("Action") then
        if number_typed == 1 then
            local player_pieces = {
                ["White"] = {
                    hand_zone = "c832bf"
                },
                ["Yellow"] = {
                    hand_zone = "856b9d"
                },
                ["Teal"] = {
                    hand_zone = "c9dd8d"
                },
                ["Red"] = {
                    hand_zone = "54730a"
                },
                ["Pink"] = {
                    hand_zone = "965437"
                }
            }
            local hand_zone_guid = player_pieces[player_color].hand_zone
            local hand_zone = getObjectFromGUID(hand_zone_guid)
            local hand_pos = hand_zone.getPosition()

            local card_rotation = number_object.getRotation()
            number_object.setPositionSmooth(hand_pos, false, false)
            Wait.time(function()
                number_object.setRotation({0, 180, card_rotation[3]})
            end, 0.25)
            -- we set a slight delay on turning the card face up in hand
            -- this avoids revealing the card when it passes through the played zone
            Wait.time(function()
                number_object.setRotation({0, 180, 0})
            end, 0.75)

        elseif number_typed >= 2 then
            print(player_color .. ", you're only allowed to pull 1 card at a time to yourself, use key 1 only")
        end
        return true
    end
end

function tryObjectEnterContainer(container, object)
  -- Only block objects from entering if the container is a locked Bag/Infinite.
  -- Otherwise allow entry. This prevents unrelated stacking restrictions
  -- from interfering with normal table interactions.

  if not container then return false end

  local ctype = container.type
  if not ctype then
    return true
  end

  -- Only enforce for Bags/Infinite containers
  if ctype ~= "Bag" and ctype ~= "Infinite" then
    return true
  end

  -- If bag is unlocked, allow entry
  local locked = false
  if container.getLock then
    local ok, res = pcall(function() return container.getLock() end)
    if ok and res then locked = true end
  end
  if not locked then return true end

  -- For locked bags, require at least one matching tag (preserve original behavior)
  -- First, enforce supply-bag color matching for ships/agents/starports.
  -- If the container GUID matches any player supply bag, only allow objects
  -- whose name contains that color (e.g., 'White Agent', 'Red Ship').
  local ok_guid, cguid = pcall(function() return container.getGUID and container.getGUID() or container.guid end)
    if ok_guid and cguid then
      -- If this is the imperial ships supply, only allow Imperial Ship objects
      if cguid == imperial_ships_GUID then
        local ok_name, name = pcall(function() return object.getName and object.getName() end)
        if not ok_name or not name then
          return false
        end
        local name_lower = string.lower(tostring(name))
        if string.find(name_lower, "imperial ship") then
          return true
        else
          return false
        end
      end

      for color, tbl in pairs(player_pieces_GUIDs) do
      -- check keys that represent supply bags
      local bag_keys = {"agents", "mini_agents", "ships", "mini_ships", "starports"}
      -- map bag key to allowed object type
      local allowed_type_for_key = {
        agents = "agent",
        mini_agents = "agent",
        ships = "ship",
        mini_ships = "ship",
        starports = "starport",
      }
      for _, key in ipairs(bag_keys) do
        local bag_guid = tbl[key]
        if bag_guid and bag_guid == cguid then
          -- enforce color and type match based on object name
          local ok_name, name = pcall(function() return object.getName and object.getName() end)
          if not ok_name or not name then
            return false
          end
          local name_lower = string.lower(tostring(name))
          local color_lower = string.lower(color)
          -- color must match
          if not string.find(name_lower, color_lower) then
            return false
          end
          -- determine object type from name
          local obj_type = nil
          if string.find(name_lower, "ship") then obj_type = "ship" end
          if string.find(name_lower, "agent") then obj_type = "agent" end
          if string.find(name_lower, "starport") then obj_type = "starport" end
          -- disallow placing when type doesn't match bag purpose
          local allowed = allowed_type_for_key[key]
          if allowed then
            if obj_type == allowed then
              return true
            else
              return false
            end
          end
          -- if no specific allowed type, fall back to color-only match
          return true
        end
      end
    end
  end

  -- Fallback: For other locked bags, require at least one matching tag (preserve original behavior)
  for _, tag in ipairs(container.getTags()) do
    if tag == "TealPiece" or tag == "YellowPiece" or tag == "RedPiece" or tag ==
      "WhitePiece" or tag == "lock" then
      goto continue
    end

    if object.hasTag and object.hasTag(tag) then
      return true
    end
    ::continue::
  end

  return false

  --[[ Original implementation (commented out per request):
  -- allow objects with at least one shared container tag to enter, with exceptions
  for _, tag in ipairs(container.getTags()) do
    if tag == "TealPiece" or tag == "YellowPiece" or tag == "RedPiece" or tag ==
      "WhitePiece" or tag == "lock" then
      goto continue
    end
            
    if object.hasTag(tag) then
      return true
    end
    ::continue::
  end

  return false -- stop card deck stop stacking function or bag stop
  ]]--
end

----------------------------------------------------
-- returns a table of colors in order
function getOrderedPlayers(silent)
  local seated_players = getSeatedPlayers()
    if (debug and #seated_players == 1) then
        broadcastToAll("\nDebugging enabled for " .. debug_player_count ..
                           " players.")
        if (debug_player_count > 3) then
          seated_players = {"White", "Yellow", "Teal", "Red", "Pink"}
        else
          local all_colors = {"White", "Yellow", "Teal", "Red", "Pink"}
            -- remove seated players from all_colors
            for _, seated in ipairs(seated_players) do
                for i, all in ipairs(all_colors) do
                    if (seated == all) then
                        table.remove(all_colors, i)
                    end
                end
            end
            -- insert random color in seated_players
            for i = 1, debug_player_count - 1, 1 do
                local rng = math.random(#all_colors)
                local random_color = all_colors[rng]
                table.insert(seated_players, random_color)
                table.remove(all_colors, rng)
            end
        end
    end

    local player_count = #seated_players
    if (player_count > 5 or player_count < 2) then
      if not silent then
        msg = "This multiplayer game will only start with 2-5 players. " ..
          "\nTo explore the mod solo, return to main menu, create the game as 'hotseat', " ..
          "load the mod from the Games menu, then pick player colors last."
        broadcastToAll(msg, {
            r = 1,
            g = 0,
            b = 0
        })
      end
      return {""}
    end

    local clockwise_order = {"White", "Pink", "Yellow", "Teal", "Red"}
    local ordered_players = {}
    local start_index = math.random(player_count)

    for i = 1, #clockwise_order do
        local color = clockwise_order[(start_index + i - 2) % #clockwise_order +
                          1]
        for _, seated_color in ipairs(seated_players) do
            if color == seated_color then
                table.insert(ordered_players, ArcsPlayer:new{
                    color = color
                })
                break
            end
        end
    end

   -- broadcastToAll("Randomly choosing first player...", Color.Purple)

    return ordered_players
end


  -- Returns ordered players but rotated so that `start` is first.
  -- `start` may be a color string (e.g., "Red") or a 1-based index.
  function getOrderedPlayersStartingWith(start)
    local ordered = getOrderedPlayers()
    if not start or #ordered == 0 then return ordered end

    local start_index = nil
    if type(start) == "string" then
      for i, p in ipairs(ordered) do
        if p.color == start then start_index = i; break end
      end
    elseif type(start) == "number" then
      if start >= 1 and start <= #ordered then start_index = start end
    end

    if not start_index then return ordered end

    local rotated = {}
    for j = start_index, #ordered do table.insert(rotated, ordered[j]) end
    for j = 1, start_index - 1 do table.insert(rotated, ordered[j]) end
    return rotated
  end


----------------------------------------------------

starting_locations = {
    [frontiers_2P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            },
            D = {
                cluster = 3,
                system = "c"
            }
        },
        [2] = {
            A = {
                cluster = 3,
                system = "a"
            },
            B = {
                cluster = 5,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            },
            D = {
                cluster = 4,
                system = "a"
            }
        }
    },
    [homelands_2P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "a"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            },
            D = {
                cluster = 5,
                system = "c"
            }
        },
        [2] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 3,
                system = "gate"
            },
            D = {
                cluster = 2,
                system = "a"
            }
        }
    },
    [mix_up_1_2P_GUID] = {
        [1] = {
            A = {
                cluster = 4,
                system = "b"
            },
            B = {
                cluster = 3,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            },
            D = {
                cluster = 6,
                system = "a"
            }
        },
        [2] = {
            A = {
                cluster = 6,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "c"
            },
            C = {
                cluster = 4,
                system = "gate"
            },
            D = {
                cluster = 1,
                system = "b"
            }
        }
    },
    [mix_up_2_2P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "b"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 3,
                system = "gate"
            },
            D = {
                cluster = 6,
                system = "b"
            }
        },
        [2] = {
            A = {
                cluster = 2,
                system = "b"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            },
            D = {
                cluster = 3,
                system = "c"
            }
        }
    },
    [homelands_3P_GUID] = {
        [1] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "b"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        }
    },
    [frontiers_3P_GUID] = {
        [1] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 6,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 1,
                system = "b"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 4,
                system = "b"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        }
    },
    [core_conflict_3P_GUID] = {
        [1] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 2,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 1,
                system = "b"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        }
    },
    [mix_up_3P_GUID] = {
        [1] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "b"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    [frontiers_4P_GUID] = {
        [1] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "b"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 6,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 4,
                system = "b"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 6,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        }
    },
    [mix_up_1_4P_GUID] = {
        [1] = {
            A = {
                cluster = 4,
                system = "a"
            },
            B = {
                cluster = 6,
                system = "c"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 4,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "c"
            },
            C = {
                cluster = 6,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 5,
                system = "a"
            },
            B = {
                cluster = 1,
                system = "c"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 6,
                system = "a"
            },
            B = {
                cluster = 1,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    [mix_up_2_4P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 1,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    [mix_up_3_4P_GUID] = {
        [1] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 4,
                system = "a"
            },
            B = {
                cluster = 2,
                system = "b"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    -- 5P starting locations
    [frontiers_5P_GUID] = {
      [1] = {
        A = {cluster = 1, system = "c"},
        B = {cluster = 3, system = "b"}, 
        C = {cluster = 2, system = "gate"}
      },
      [2] = {
        A = { cluster = 2, system = "c" },
        B = { cluster = 6, system = "c" },
        C = { cluster = 3, system = "gate" }
      },
      [3] = {
        A = { cluster = 4, system = "b" },
        B = { cluster = 2, system = "a" },
        C = { cluster = 6, system = "gate" }
      },
      [4] = {
        A = { cluster = 1, system = "a" },
        B = { cluster = 6, system = "a" },
        C = { cluster = 4, system = "gate" }
      },
      [5] = {
        A = { cluster = 5, system = "c" },
        B = { cluster = 4, system = "c" },
        C = { cluster = 1, system = "gate" }
      }
    },
    [empires_5P_GUID] = {
      [1] = {
        A = { cluster = 1, system = "c" },
        B = { cluster = 1, system = "b" },
        C = { cluster = 6, system = "gate" }
      },
      [2] = {
        A = { cluster = 2, system = "c" },
        B = { cluster = 2, system = "b" },
        C = { cluster = 6, system = "gate" }
      },
      [3] = {
        A = { cluster = 3, system = "c" },
        B = { cluster = 3, system = "b" },
        C = { cluster = 6, system = "gate" }
      },
      [4] = {
        A = { cluster = 4, system = "a" },
        B = { cluster = 4, system = "c" },
        C = { cluster = 6, system = "gate" }
      },
      [5] = {
        A = { cluster = 5, system = "b" },
        B = { cluster = 5, system = "a" },
        C = { cluster = 6, system = "gate" }
      }
    },
    [mix_up_1_5P_GUID] = {
      [1] = {
        A = { cluster = 6, system = "c" },
        B = { cluster = 4, system = "a" },
        C = { cluster = 1, system = "gate" }
      },
      [2] = {
        A = { cluster = 4, system = "c" },
        B = { cluster = 5, system = "c" },
        C = { cluster = 3, system = "gate" }
      },
      [3] = {
        A = { cluster = 5, system = "a" },
        B = { cluster = 3, system = "c" },
        C = { cluster = 4, system = "gate" }
      },
      [4] = {
        A = { cluster = 6, system = "a" },
        B = { cluster = 1, system = "a" },
        C = { cluster = 5, system = "gate" }
      },
      [5] = {
        A = { cluster = 1, system = "c" },
        B = { cluster = 3, system = "b" },
        C = { cluster = 6, system = "gate" }
      }
    },
    [mix_up_2_5P_GUID] = {
      [1] = {
        A = { cluster = 5, system = "c" },
        B = { cluster = 3, system = "a" },
        C = { cluster = 1, system = "gate" }
      },
      [2] = {
        A = { cluster = 3, system = "c" },
        B = { cluster = 5, system = "b" },
        C = { cluster = 2, system = "gate" }
      },
      [3] = {
        A = { cluster = 4, system = "c" },
        B = { cluster = 1, system = "c" },
        C = { cluster = 3, system = "gate" }
      },
      [4] = {
        A = { cluster = 1, system = "a" },
        B = { cluster = 2, system = "a" },
        C = { cluster = 5, system = "gate" }
      },
      [5] = {
        A = { cluster = 2, system = "b" },
        B = { cluster = 6, system = "b" },
        C = { cluster = 4, system = "gate" }
      }
    },
    [extension_5P_GUID] = {
      [1] = {
        A = { cluster = 2, system = "c" },
        B = { cluster = 3, system = "b" },
        C = { cluster = 2, system = "gate" }
      },
      [2] = {
        A = { cluster = 1, system = "c" },
        B = { cluster = 2, system = "a" },
        C = { cluster = 1, system = "gate" }
      },
      [3] = {
        A = { cluster = 3, system = "c" },
        B = { cluster = 5, system = "a" },
        C = { cluster = 3, system = "gate" }
      },
      [4] = {
        A = { cluster = 5, system = "c" },
        B = { cluster = 6, system = "c" },
        C = { cluster = 5, system = "gate" }
      },
      [5] = {
        A = { cluster = 6, system = "b" },
        B = { cluster = 1, system = "b" },
        C = { cluster = 6, system = "gate" }
      }
    }
}
  
starting_pieces = {
    Default = {
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        }
    },
    ["bcc792"] = { -- Elder
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"relic", "material"}
    },
    ["a7e9eb"] = { -- Fuel-Drinker
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "fuel"}
    },
    ["8109e1"] = { -- Upstart
        A = {
            building = "city",
            ships = 4
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "material"}
    },
    ["aa0e68"] = { -- Mystic
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "relic"}
    },
    ["c37bb3"] = { -- Demagogue
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "weapon"}
    },
    ["996b9d"] = { -- Feastbringer
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "city",
            ships = 3
        },
        C = {
            ships = 3
        },
        D = {
            ships = 3
        },
        resources = {"relic", "material"}
    },
    ["da8b99"] = { -- Rebel
        A = {
            building = "starport",
            ships = 4
        },
        B = {
            ships = 4
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"material", "weapon"}
    },
    ["639b42"] = { -- Warrior
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"weapon", "material"}
    },
    ["1848eb"] = { -- Noble
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "psionic"}
    },
    ["2a5b6f"] = { -- Archivist
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "city",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"relic", "relic"}
    },
    ["942aaa"] = { -- Quartermaster
        A = {
            building = "starport",
            ships = 4
        },
        B = {
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "weapon"}
    },
    ["4363db"] = { -- Agitator
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 4
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "material"}
    },
    ["003bc2"] = { -- Anarchist
        A = {
            ships = 4
        },
        B = {
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"relic", "weapon"}
    },
    ["843e46"] = { -- Shaper
        A = {
            building = "city",
            ships = 3
        },
        B = {
            ships = 3
        },
        C = {
            ships = 3
        },
        D = {
            ships = 3
        },
        resources = {"relic", "material"}
    },
    ["a1b65d"] = { -- Corsair
        A = {
            building = "starport",
            ships = 4
        },
        B = {
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "weapon"}
    },
    ["2409c0"] = { -- Overseer
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "material"}
    }
}

-- params = {obj, is_visible}
function move_and_lock_object(params)
    local y_pos = params.is_visible and 1 or -2
    local pos = params.obj.getPosition()
    pos.y = y_pos
    params.obj.setPosition(pos)
    if (params.obj.hasTag("Lock")) then
        params.obj.locked = true
    else
        params.obj.locked = not params.is_visible
    end
    -- Ensure the lost-vaults rules object remains locked when it is made visible
    pcall(function()
      local obj_guid = nil
      if params.obj.getGUID then obj_guid = params.obj.getGUID() elseif params.obj.guid then obj_guid = params.obj.guid end
      if obj_guid and lost_vaults_rules_GUID and obj_guid == lost_vaults_rules_GUID and params.is_visible then
        params.obj.locked = true
      end
    end)
end

function set_active_players(players)
    active_players = players
end

function save_game_starting_players()
  starting_players = {}
  if type(active_players) ~= "table" then
    Global.setVar("starting_players", starting_players)
    return
  end

  for _, player in ipairs(active_players) do
    table.insert(starting_players, player)
  end

  Global.setVar("starting_players", starting_players)
  
  -- Cache player steam names at the point of setup
  cache_player_steam_names()
end

function setup_custom_game()

    BaseGame.destroy_grey_setup_menu_objects()

    -- Build active_players from seated players if present; otherwise use all five.
    active_players = {}
    local seated = getSeatedPlayers()
    if seated and #seated > 0 then
      for _, color in ipairs(seated) do
        table.insert(active_players, ArcsPlayer:new{ color = color })
      end
    else
      for _, v in ipairs({"Red", "White", "Yellow", "Teal", "Pink"}) do
        table.insert(active_players, ArcsPlayer:new{ color = v })
      end
    end
    
    -- Cache player steam names early so they survive if players leave
    cache_player_steam_names()
    
    local active_player_colors = {}
    for _, v in ipairs(active_players) do
      table.insert(active_player_colors, v.color)
      ArcsPlayer.components_visibility(v.color, true, true)
    end

    with_miniatures = Global.getVar("with_miniatures")
    BaseGame.setup_or_destroy_miniatures(with_miniatures, active_players)

    local player_count = #active_players
    local p = {
      is_campaign = true,
      is_4p = (player_count >= 4),
      leaders_and_lore = true,
      leaders_and_lore_expansion = true,
      with_faceup_discard = true,
      with_miniatures = with_miniatures,
      players = active_player_colors
    }
    set_game_in_progress(p)

    BaseGame.base_exclusive_components_visibility(true)
    BaseGame.setupOutOfPlayForCustom()
    if player_count >= 5 then -- also happens for 4? -- fix this?
      BaseGame.adjust_action_deck_for_5p()
    end

    -- Ensure initiative is initialized for custom setups: scan each player's initiative zone
    pcall(function()
      local initiative_guids = { initiative_GUID, seized_initiative_GUID }
      for _, p in ipairs(active_players) do
        local color = p.color
        local zone_guid = nil
        -- try player_pieces_GUIDs table first (works for custom setups)
        if player_pieces_GUIDs and player_pieces_GUIDs[color] and player_pieces_GUIDs[color].initiative_zone then
          zone_guid = player_pieces_GUIDs[color].initiative_zone
        end
        -- fallback: try arcs player's components if present
        if not zone_guid and p.components and p.components.initiative_zone then zone_guid = p.components.initiative_zone end
        if zone_guid then
          local zone = getObjectFromGUID(zone_guid)
          if zone and type(zone.getObjects) == "function" then
            local ok, objs = pcall(function() return zone.getObjects() end)
            if ok and objs then
              for _, obj in ipairs(objs) do
                local guid = nil
                pcall(function() if obj.getGUID then guid = obj.getGUID() end end)
                if not guid and obj.guid then guid = obj.guid end
                if guid then
                  for _, target in ipairs(initiative_guids) do
                    if tostring(guid) == tostring(target) then
                      initiative_player = color
                      Global.setVar("initiative_player", initiative_player)
                      broadcastToAll("Initiative initialized to " .. tostring(color) .. " (custom setup)", {0.2,0.8,0.2})
                      return
                    end
                  end
                end
              end
            end
          end
        end
      end
    end)

    -- Attach context menus to ambition markers for new custom game setups
    pcall(function() attach_ambition_marker_menus() end)
end

----------------------------------------------------
-- params = {
--     is_campaign = false,
--     is_4p = #active_players == 4,
--     leaders_and_lore = with_leaders,
--     leaders_and_lore_expansion = with_ll_expansion,
--     faceup_discard = ActionCards.is_face_up_discard_active(),
--     players = active_players
-- }
function set_game_in_progress(params)
    Counters.setup()
    local reach_board = getObjectFromGUID(reach_board_GUID)
    reach_board.setDescription("in progress")

    local visibility = {"Red", "White", "Yellow", "Teal", "Black", "Pink", "Grey"}

    if (params.with_faceup_discard) then
        ActionCards.faceup_discard_visibility(true)
        local fud_marker = getObjectFromGUID(FUDiscard_marker_GUID)
        fud_marker.setDescription("active")
    end

    BaseGame.core_components_visibility(true)
    if (params.is_campaign) then
        local campaign_rules = getObjectFromGUID(Campaign.guids.rules)
        campaign_rules.setDescription("active")

        Campaign.components_visibility(true)
        BaseGame.lore_visibility(true, params.leaders_and_lore_expansion)
    else
        BaseGame.base_exclusive_components_visibility(true)
    end
    if (params.is_4p or player_count) then
        BaseGame.four_player_cards_visibility(true)
    end
    if (params.leaders_and_lore) then
        BaseGame.leaders_visibility(true, params.leaders_and_lore_expansion)
        BaseGame.lore_visibility(true, params.leaders_and_lore_expansion)
    end

    -- player components visibility
    for _, color in ipairs(params.players) do
        ArcsPlayer.components_visibility(color, true, params.is_campaign)
        local player_board = getObjectFromGUID(
            player_pieces_GUIDs[color].player_board)
        player_board.setDescription("active")
    end
    -- for _, v in ipairs(getOrderedPlayers()) do
    --     ArcsPlayer.components_visibility(v.color, true, params.is_campaign)
    --     local player_board = getObjectFromGUID(v.components.board)
    --     player_board.setDescription("active")
    -- end
end

function onLoad(script_state)
  overlay_sending_enabled = false
  overlay_cards_hidden = false
  overlay_align = "left"
  pcall(function()
    if _G["clear_overlay_ui"] then
      _G["clear_overlay_ui"]()
    end
  end)

  -- Restore persistent state saved by onSave (if present)
  local loaded_state = nil
  if script_state and script_state ~= "" then
    local ok, state = pcall(function()
      return JSON.decode(script_state)
    end)
    if ok and state then
      -- Don't immediately overwrite `game_id` here: onLoad can be invoked
      -- during a script reload as well as when loading a saved game. We'll
      -- apply the saved `game_id` only if the table is actually loading a
      -- game in-progress (detected below by the reach board description).
      loaded_state = state
      if state.initiative then
        initiative_player = state.initiative.player or initiative_player
        initiative_player_position = state.initiative.position or initiative_player_position
      end
      if state.settings then
        is_face_up_discard_active = state.settings.is_face_up_discard_active or is_face_up_discard_active
        is_basegame_setup = state.settings.is_basegame_setup or is_basegame_setup
       end
       if state.player_steam_name_cache then
         player_steam_name_cache = state.player_steam_name_cache
         Global.setVar("player_steam_name_cache", player_steam_name_cache)
      end
    end
  end
  -- Generate a new game ID if not already present
  if not game_id or game_id == "" then
    game_id = generate_game_id()
    LOG.INFO("Game ID: " .. game_id, {0.8, 0.8, 0.2})
  end
  -- Store initial game_id in Global so other modules can access it.
  -- If we later detect we're loading a saved 'in progress' game, we'll
  -- override this with the saved ID below.
  Global.setVar("game_id", game_id)
    -- create a blank table to store the Wait.conditions in
    zoneWaits = {}

    -- Hide/disable helper snaps object at startup.
    pcall(function() BaseGame.hide_and_disable_5p_snaps() end)

    Initiative.add_menu()

    -- Reattach supply/context menus for all existing objects after load
    Supplies.addMenuToAllObjects()
    -- Recreate visible counters (numbers) on supply containers and similar
    Counters.setup()

    -- Ensure zero marker ambition button exists at startup
    pcall(function() AmbitionMarkers.add_button() end)

    -- Attach context menus to ambition markers and chapter pawn (always available)
    pcall(function() attach_ambition_marker_menus() end)

    -- start periodic scan to ensure Draw-bottom is attached to any new decks
    schedule_scan()

    local reach_board = getObjectFromGUID(reach_board_GUID)
    if (reach_board.getDescription() == "in progress") then
        -- If we have a saved state and it contains a game_id, use it now.
        if loaded_state and loaded_state.game_id then
          game_id = loaded_state.game_id
          LOG.INFO("Restored Game ID: " .. game_id, {0.2, 0.8, 0.8})
          Global.setVar("game_id", game_id)
        end
        broadcastToAll("Loading game in progress")
        active_players = {}
        local loaded_colors = nil
        if loaded_state and type(loaded_state.active_player_colors) == "table" and #loaded_state.active_player_colors > 0 then
          loaded_colors = loaded_state.active_player_colors
        end

        if loaded_colors then
          for _, v in ipairs(loaded_colors) do
            if v and v ~= "" then
              local arcs_player = ArcsPlayer:new{ color = v }
              table.insert(active_players, arcs_player)
            end
          end
        else
          for _, v in ipairs({"Red", "White", "Yellow", "Teal", "Pink"}) do
            local player_board = getObjectFromGUID(
                player_pieces_GUIDs[v].player_board)
            if player_board and (player_board.getDescription() == "active") then
                local arcs_player = ArcsPlayer:new{
                    color = v
                }
                table.insert(active_players, arcs_player)
            end
          end
        end

        -- Rebuild starting_players from restored active players so external modules
        -- keep a stable roster even if players disconnect.
        starting_players = {}
        for _, p in ipairs(active_players) do
          table.insert(starting_players, p)
        end
        Global.setVar("starting_players", starting_players)
              -- Update cache with currently seated players (preserves saved names as fallback)
              local seated = getSeatedPlayers()
              if seated and #seated > 0 then
                for _, color in ipairs(seated) do
                  local ok, player = pcall(function() return Player[color] end)
                  if ok and player and player.steam_name and player.steam_name ~= "" then
                    player_steam_name_cache[color] = player.steam_name
                    Global.setVar("player_steam_name_cache", player_steam_name_cache)
                  end
                end
              end

        -- Ensure player boards for colors not active remain hidden
        local all_colors = {"Red", "White", "Yellow", "Teal", "Pink"}
        for _, col in ipairs(all_colors) do
          local pb = getObjectFromGUID(player_pieces_GUIDs[col].player_board)
          if pb then
            if pb.getDescription() == "active" then
              ArcsPlayer.components_visibility(col, true, false)
            else
              ArcsPlayer.components_visibility(col, false, false)
            end
          end
        end

        -- Ensure 4p action cards visibility matches active player count
        local player_count = #active_players
        if player_count >= 4 then
          BaseGame.four_player_cards_visibility(true)
        else
          BaseGame.four_player_cards_visibility(false)
        end

        -- Safe reattachment of various UI helpers and object onload handlers
        local setup_obj = getObjectFromGUID(SetupControl.setup_control_guid)
        if setup_obj then pcall(function() setup_obj.call("onload") end) end

        local ctrl_obj = getObjectFromGUID(Global.getVar("control_GUID"))
        if ctrl_obj then pcall(function() ctrl_obj.call("onload") end) end

        pcall(function() AmbitionMarkers.add_button() end)
        pcall(function() LawBook.setup() end)

        -- for _, tag in ipairs({"DiceCounter", "DiceBoard"}) do
        --   for _, o in pairs(getObjectsWithTag(tag)) do
        --     pcall(function() o.call("onload") end)
        --     pcall(function() o.call("onLoad") end)
        --   end
        -- end

    elseif debug then
        Campaign.components_visibility(true)
        BaseGame.components_visibility({
            is_visible = true,
            is_campaign = true,
            is_4p = true,
            leaders_and_lore = true,
            leaders_and_lore_expansion = true,
            with_faceup_discard = true
        })
    else
        -- Hide components
        Campaign.components_visibility(false)
        BaseGame.components_visibility({
            is_visible = false,
            is_campaign = false,
            is_4p = true,
            leaders_and_lore = true,
            leaders_and_lore_expansion = true -- ,
            -- faceup_discard = true
        })

        for _, v in pairs(available_colors) do
            ArcsPlayer.components_visibility(v, false, false)
        end
    end

    local action_deck = ActionCards.get_action_deck()
    if action_deck then
      action_deck.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)
    else
      LOG.WARNING("Global.onload: action deck not found; skipping Draw bottom card menu")
    end
    ErrataFaqService.proactive_fetch(LOG.INFO, LOG.WARNING)
    Wait.time(function()
      ErrataFaqService.scan_cards_for_menu()
    end, 2)

    for _, obj in pairs(getObjectsWithTag("Noninteractable")) do
        obj.locked = true
        obj.interactable = false
    end

    if (not debug) then
        local face_up_discard_action_deck = getObjectFromGUID(
            face_up_discard_action_deck_GUID)
        face_up_discard_action_deck.setInvisibleTo({
            "Red", "White", "Yellow", "Pink", "Teal", "Black", "Grey"
        })
        face_up_discard_action_deck.interactable = false
        face_up_discard_action_deck.locked = false -- set this to false otherwise it breaks
    end

    -- Initialize turn system
    Turns.enable = true
    Turns.pass_turns = true

    -- Initialize timer system
    resetTimer() -- Reset all player timers
    loadCameraTimerMenu(false) -- Load the UI with menu closed initially
end

  function onSave()
    local active_player_colors = {}
    for _, p in ipairs(active_players or {}) do
      if p and p.color and p.color ~= "" then
        table.insert(active_player_colors, p.color)
      end
    end

    local state = {
      game_id = game_id,
      initiative = {
        player = initiative_player,
        position = initiative_player_position
      },
      settings = {
        is_face_up_discard_active = is_face_up_discard_active,
        is_basegame_setup = is_basegame_setup
       },
       player_steam_name_cache = player_steam_name_cache or {},
       active_player_colors = active_player_colors
    }
    return JSON.encode(state)
  end


-- Generated by tools/yml_to_lua.py from leaders.yml
require("assets/leaders_starting_pieces")
--manually put in here:
require("assets/leaders_pnp2_starting")

--lost vaults markers

-- When a card is flipped face-up or dropped face-up on the table, check the
-- Lost Vaults marker bag and move a matching marker (by name) to the card's
-- position if one exists in the bag. Exposed on _G so other scripts can call it.
_G.place_lost_vaults_marker_for_card = function(card)
    if not card or not card.getName or not card.getPosition then return end
    local ok, name = pcall(function() return card.getName() end)
    if not ok or not name or name == "" then return end

    -- Check whether the card is face-down; be tolerant of API shapes.
    local is_down = nil
    pcall(function() is_down = card.is_face_down end)
    if is_down == nil then pcall(function() is_down = card.is_face_down() end) end
    if is_down == true then return end

    local okpos, pos = pcall(function() return card.getPosition() end)
    if not okpos or not pos then return end

    local bag_guid = Global.getVar("lost_vaults_marker_bag_GUID") or "7f3e2f"
    local bag = getObjectFromGUID(bag_guid)
    if not bag or not bag.getObjects then return end

    local contents = bag.getObjects()
    for _, item in ipairs(contents) do
        if item and item.name and item.name == name then
            pcall(function()
                if bag.takeObject then
                  -- compute how many existing markers with this name are near the target
                  local existing = 0
                  local all_objs = getAllObjects()
                  for _, o in ipairs(all_objs) do
                    local okn, oname = pcall(function() return (o.getName and o.getName()) or o.name end)
                    if okn and oname and oname == name then
                      local okp, opos = pcall(function() return o.getPosition() end)
                      if okp and opos then
                        local dx = opos.x - pos.x
                        local dz = opos.z - pos.z
                        if (dx * dx + dz * dz) < 0.5 then existing = existing + 1 end
                      end
                    end
                  end
                  local place_x = pos.x + (existing * 0.4)
                  local place_z = pos.z + (existing * 0.2)
                  bag.takeObject({
                    guid = item.guid,
                    position = {place_x, pos.y + 0.5, place_z},
                    callback_function = function(taken)
                      Wait.frames(function()
                        if taken then
                          pcall(function()
                            if taken.setRotation then taken.setRotation({0, 180, 0}) end
                          end)
                          if taken.setPositionSmooth then
                            taken.setPositionSmooth({place_x, pos.y + 0.5, place_z})
                          elseif taken.setPosition then
                            taken.setPosition({place_x, pos.y + 0.5, place_z})
                          end
                        end
                      end, 1)
                    end
                  })
                end
            end)
            break
        end
    end
end


-- Chain custom logic with any existing handlers for onObjectDrop/onObjectFlip
local orig_onObjectDrop = onObjectDrop
local orig_onObjectFlip = onObjectFlip

function onObjectDrop(player_color, obj)
  if orig_onObjectDrop and orig_onObjectDrop ~= onObjectDrop then
    pcall(function() orig_onObjectDrop(player_color, obj) end)
  end
  pcall(function() _G.place_lost_vaults_marker_for_card(obj) end)
  pcall(function() _G.place_veil_on_loom(obj) end)
end

function onObjectFlip(player_color, obj)
  if orig_onObjectFlip and orig_onObjectFlip ~= onObjectFlip then
    pcall(function() orig_onObjectFlip(player_color, obj) end)
  end
  pcall(function() _G.place_lost_vaults_marker_for_card(obj) end)
  pcall(function() _G.place_veil_on_loom(obj) end)
end

-- If a card named "The Loom" is placed face-up, find up to 4 cards named
-- "Veil" (on-table or inside bags) and move them onto the Loom card.
_G.place_veil_on_loom = function(loom_card)
  if not loom_card or not loom_card.getName or not loom_card.getPosition then return end
  local ok, name = pcall(function() return loom_card.getName() end)
  if not ok or not name or name ~= "The Loom" then return end

  -- Check if veils have already been placed on this Loom card
  local already_placed = false
  pcall(function() already_placed = loom_card.getVar("veils_placed_on_loom") or false end)
  if already_placed then return end

  local okpos, pos = pcall(function() return loom_card.getPosition() end)
  if not okpos or not pos then return end

  -- Mark immediately that we're processing this Loom card to prevent duplicate runs
  pcall(function() loom_card.setVar("veils_placed_on_loom", true) end)

  local candidates = {}
  local all = getAllObjects()
  for _, o in ipairs(all) do
    if o then
      -- on-table Veil cards
      local okn, nm = pcall(function() return o.getName and o.getName() or o.name end)
      if okn and nm == "Veil" then
        table.insert(candidates, {type = "table", obj = o})
      end
      -- bags: inspect contents for Veil entries
      local isBag = false
      pcall(function() if o.tag and o.tag == "Bag" then isBag = true end end)
      if isBag and o.getObjects then
        local okc, contents = pcall(function() return o.getObjects() end)
        if okc and contents then
          for _, item in ipairs(contents) do
            if item and item.name and item.name == "Veil" then
              table.insert(candidates, {type = "bag", bag = o, guid = item.guid})
            end
          end
        end
      end
    end
  end

  if #candidates == 0 then return end

  local want = 4
  for i = 1, math.min(want, #candidates) do
    local c = candidates[i]
    local target_y = pos.y + 0.6 + ((i - 1) * 0.2)
    if c.type == "table" and c.obj then
      pcall(function()
        if c.obj.setRotation then pcall(function() c.obj.setRotation({0,180,0}) end) end
        if c.obj.setPositionSmooth then
          c.obj.setPositionSmooth({pos.x, target_y, pos.z})
        else
          c.obj.setPosition({pos.x, target_y, pos.z})
        end
      end)
    elseif c.type == "bag" and c.bag and c.guid then
      pcall(function()
        if c.bag.takeObject then
          c.bag.takeObject({
            guid = c.guid,
            position = {pos.x, target_y + 0.5, pos.z},
            callback_function = function(taken)
              Wait.frames(function()
                if taken then
                  pcall(function() if taken.setRotation then taken.setRotation({0,180,0}) end end)
                  if taken.setPositionSmooth then
                    taken.setPositionSmooth({pos.x, target_y, pos.z})
                  elseif taken.setPosition then
                    taken.setPosition({pos.x, target_y, pos.z})
                  end
                end
              end, 1)
            end
          })
        end
      end)
    end
  end
  LOG.INFO("Placed " .. tostring(math.min(want, #candidates)) .. " Veil card(s) onto The Loom")
end
