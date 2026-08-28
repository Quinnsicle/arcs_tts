local DropActionEvents = {}

local deps = nil
local recent_announcements = {}
local DUPLICATE_WINDOW_SECONDS = 1.25

function DropActionEvents.configure(config)
  deps = config
end

local function should_suppress_duplicate(guid, event_kind, player_color)
  local now = os.clock()
  local key = tostring(guid or "") .. "|" .. tostring(event_kind or "") .. "|" .. tostring(player_color or "")
  local prev = recent_announcements[key]
  recent_announcements[key] = now
  return prev and (now - prev) < DUPLICATE_WINDOW_SECONDS
end

local function is_object_in_zone(object, zone)
  if not object or not zone then return false end
  local zone_objects = zone.getObjects()
  for _, obj in ipairs(zone_objects) do
    if obj.guid == object.guid then
      return true
    end
  end
  return false
end

function DropActionEvents.handle_object_drop(player_color, object)
  if not deps or not object then return end

  local object_name = object.getName()

  if object_name == "Power" or object_name == "Objective" then
    local power_color = object.getDescription()
    local player = deps.get_arcs_player(power_color)
    if player then
      Wait.time(function()
        player:update_score()
      end, 0.5)
    end
  end

  if object and object.tag == "Card" and object.hasTag("Action") then
    local played_zone = getObjectFromGUID(deps.action_card_zone_GUID)
    local played_zone_card = is_object_in_zone(object, played_zone)
    if not played_zone_card then
      return
    end

    local wait_id = object.getGUID()
    if deps.zone_waits[wait_id] then
      Wait.stop(deps.zone_waits[wait_id])
      deps.zone_waits[wait_id] = nil
    end
    deps.zone_waits[wait_id] = Wait.condition(function()
      local player = deps.get_arcs_player(Turns.turn_color)
      if not player then
        deps.log_warning("Could not track last played card for " .. Turns.turn_color)
        return
      end

      local seize_zone = getObjectFromGUID(deps.seize_zone_GUID)
      local seize_zone_card = is_object_in_zone(object, seize_zone)

      if object.is_face_down and seize_zone_card then
        if not should_suppress_duplicate(wait_id, "seize", player.color) then
          player:set_last_played_seize_card(object.getDescription())
          broadcastToAll(player.color .. " is seizing the initiative", player.color)
        end
      elseif not object.is_face_down and played_zone_card then
        if not should_suppress_duplicate(wait_id, "played", player.color) then
          local action_cards = deps.get_action_cards()
          player:set_last_played_action_card(action_cards.get_info(object))
        end
      end
      deps.zone_waits[wait_id] = nil
    end, function()
      return object == nil or object.getGUID == nil or object.resting
    end)
  end

  if object_name == "Ambition" then
    local obj_guid = (object and object.getGUID and object.getGUID()) or object.guid
    Wait.time(function()
      local obj = nil
      if obj_guid then
        obj = getObjectFromGUID(obj_guid)
      end
      if not obj then
        obj = object
      end
      if not obj then
        obj = getObjectFromGUID("c9e0ee")
      end
      if obj and obj.getPosition then
        deps.ambition_get_info(obj)
      else
        deps.log_debug("Ambition callback: object missing for guid " .. tostring(obj_guid))
      end
    end, 0.5)
  end
end

function DropActionEvents.handle_player_action(player, action, targets, on_object_drop)
  if action ~= Player.Action.FlipOver then
    return
  end

  if #targets == 1 and targets[1].hasTag("Action") then
    Wait.time(function()
      on_object_drop(player.color, targets[1])
    end, 0.25)
  end

  for _, obj in ipairs(targets) do
    if obj.hasTag("Ship") then
      obj.setState(obj.getStateId() == 1 and 2 or 1)
    end
  end
end

return DropActionEvents
