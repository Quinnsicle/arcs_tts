local AmbitionControls = {}

local declared_marker = getObjectFromGUID(Global.getVar("ambition_declared_marker_GUID"))
local lead_card_zone = getObjectFromGUID(Global.getVar("lead_card_zone_GUID"))
local power_markers = {
    getObjectFromGUID(Global.getTable("ambition_marker_GUIDs")[1]),
    getObjectFromGUID(Global.getTable("ambition_marker_GUIDs")[2]),
    getObjectFromGUID(Global.getTable("ambition_marker_GUIDs")[3])
}
local names = {
    [2] = "Tycoon",
    [3] = "Tyrant",
    [4] = "Warlord",
    [5] = "Keeper",
    [6] = "Empath"
}

function AmbitionControls.declare(player_color)

    local lead_card = lead_card_zone.getObjects()[1]

    if not lead_card then
        broadcastToColor("No lead card has been played", player_color)
        return
    end

    local declared_ambition = tonumber(string.sub(lead_card.getDescription(),-1))

    if declared_ambition == 1 then
        broadcastToColor("Actions numbered 1 cannot be declared", player_color)
        return
    elseif declared_ambition == 7 then
        broadcastToAll(player_color.." is declaring ambition of choice", player_color)
        broadcastToColor("Move highest available ambition marker to desired ambition", player_color)
    else
        broadcastToAll(player_color.." has declared "..names[declared_ambition].." ambition", player_color)
        broadcastToColor("Move highest available ambition marker to "..names[declared_ambition], player_color)
    end

    declared_marker.setPositionSmooth({-13.51, 0.99, -4.72})
    declared_marker.setRotationSmooth({0.00, 90.00, 0.00})
end

return AmbitionControls