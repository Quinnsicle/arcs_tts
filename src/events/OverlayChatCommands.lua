local OverlayChatCommands = {}

local function trigger_overlay_update()
  pcall(function()
    if _G["send_overlay_update_ui"] then
      _G["send_overlay_update_ui"]()
    end
  end)
end

local function clear_overlay()
  pcall(function()
    if _G["clear_overlay_ui"] then
      _G["clear_overlay_ui"]()
    end
  end)
end

function OverlayChatCommands.handle(message)
  local msg = tostring(message or "")
  local s = string.lower(msg)

  if string.match(s, "^!overlay%s+start") then
    overlay_sending_enabled = true
    broadcastToAll("Overlay sending ENABLED. Will send updates on each turn.", {0.2, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+stop") then
    overlay_sending_enabled = false
    broadcastToAll("Overlay sending DISABLED.", {0.8, 0.2, 0.2})
    clear_overlay()
    return true
  elseif string.match(s, "^!overlay%s+once") then
    trigger_overlay_update()
    broadcastToAll("Overlay: one update sent.", {0.2, 0.8, 0.2})
    return true
  elseif string.match(s, "^!overlay%s+status") then
    local st = overlay_sending_enabled and "ENABLED" or "DISABLED"
    broadcastToAll("Overlay sending is currently: " .. st, {0.8, 0.8, 0.2})
    return true
  elseif string.match(s, "^!overlay%s+hidecards") then
    overlay_cards_hidden = true
    broadcastToAll("Overlay card faces are now HIDDEN.", {0.8, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+showcards") then
    overlay_cards_hidden = false
    broadcastToAll("Overlay card faces are now VISIBLE.", {0.8, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+togglecards") then
    overlay_cards_hidden = not overlay_cards_hidden
    local state = overlay_cards_hidden and "HIDDEN" or "VISIBLE"
    broadcastToAll("Overlay card faces are now " .. state .. ".", {0.8, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+align%s+left") then
    overlay_align = "left"
    broadcastToAll("Overlay alignment set to LEFT.", {0.2, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+align%s+right") then
    overlay_align = "right"
    broadcastToAll("Overlay alignment set to RIGHT.", {0.2, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+left") then
    overlay_align = "left"
    broadcastToAll("Overlay alignment set to LEFT.", {0.2, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+right") then
    overlay_align = "right"
    broadcastToAll("Overlay alignment set to RIGHT.", {0.2, 0.8, 0.2})
    trigger_overlay_update()
    return true
  elseif string.match(s, "^!overlay%s+help") then
    broadcastToAll(
      "!overlay start = enable automatic sending\n" ..
      "!overlay stop = disable automatic sending\n" ..
      "!overlay once = send one update now\n" ..
      "!overlay status = show whether sending is enabled\n" ..
      "!overlay hidecards = blank the card images in the overlay\n" ..
      "!overlay showcards = show the card images again\n" ..
      "!overlay togglecards = switch card visibility on or off\n" ..
      "!overlay help = show this message\n" ..
      "!overlay align left = position overlay on the left side (default)\n" ..
      "!overlay align right = position overlay on the right side",
      {0.8, 0.8, 0.2}
    )
    return true
  end

  return false
end

return OverlayChatCommands
