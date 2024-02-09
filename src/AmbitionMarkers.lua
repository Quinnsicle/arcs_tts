-- Used in all aspects of manipulating zero marker and 3 ambition markers
require("src/GUIDs")

local AmbitionMarkers = {}

local reach_board = getObjectFromGUID(reach_board_GUID)
local marker_zone = getObjectFromGUID(ambition_marker_zone_GUID)
local zero_marker = getObjectFromGUID(zero_marker_GUID)

-- is_face_down = false = lower (blue) side is face up
-- is_face_down = true  = higher (yellow) side is face up
local markers = {
    {
        object = getObjectFromGUID(ambition_marker_GUIDs[1]),
        column_pos = Vector({-0.84,0.2,0}),
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
    },
    {
        object = getObjectFromGUID(ambition_marker_GUIDs[2]),
        column_pos = Vector({-0.92,0.2,0}),
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
    },
    {
        object = getObjectFromGUID(ambition_marker_GUIDs[3]),
        column_pos = Vector({-1.00,0.2,0}),
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
    }
}

local ambitions = {
    {name = "Undeclared", row_pos = Vector({0,0,-1.08})},
    {name = "Tycoon",     row_pos = Vector({0,0,-0.72})},
    {name = "Tyrant",     row_pos = Vector({0,0,-0.34})},
    {name = "Warlord",    row_pos = Vector({0,0,0.05})},
    {name = "Keeper",     row_pos = Vector({0,0,0.43})},
    {name = "Empath",     row_pos = Vector({0,0,0.84})}
}

function AmbitionMarkers.addButton()
    zero_marker.createButton({ 
        click_function = 'declareAmbition',
        function_owner = zero_marker,
        position = {0, 0.05, 0},
        width = 3800,
        height = 950,
        tooltip = 'Declare Ambition'
    })
end

function AmbitionMarkers.declareButton()
    zero_marker.editButton({
        index = 0,
        click_function = 'declareAmbition',
        tooltip = 'Declare Ambition'
    })
end

function AmbitionMarkers.resetButton()
    zero_marker.editButton({ 
        index = 0,
        click_function = 'resetZeroMarker',
        tooltip = 'Reset Zero Marker'
    })
end

function AmbitionMarkers.declare(player_color)

    local action_cards = require("src/ActionCards")
    local lead_info = action_cards.getLeadInfo()

    -- Is there a lead card?
    if (not lead_info) then
        broadcastToColor("No lead card has been played", player_color)
        return
    end

    -- Is there an ambition marker?
    local high_marker = AmbitionMarkers.highestUndeclared()
    if (not high_marker) then
        broadcastToColor("No ambition markers available", player_color)
        return
    end

    -- Get declared ambition 
    local is_faithful = (lead_info.type == "Faithful Zeal" or lead_info.type == "Faithful Wisdom")

    -- Is the lead card a 1?
    if (lead_info.number == 1 and not is_faithful) then
        broadcastToColor("Actions numbered 1 cannot be declared", player_color)
        return
    end

    local power = high_marker[high_marker.object.is_face_down].power_desc

    if (lead_info.number == 7 or is_faithful) then
        broadcastToAll(player_color.." is declaring ambition of choice for "..power, player_color)
        broadcastToColor("Move "..power.." ambition marker to desired ambition", player_color)
    else
        local this_ambition = ambitions[lead_info.number]
        local pos = high_marker.column_pos + this_ambition.row_pos; pos = reach_board.positionToWorld(pos)
        high_marker.object.setPositionSmooth(pos)
        broadcastToAll(player_color.." has declared "..this_ambition.name.." ambition for "..power, player_color)
    end

    zero_marker.setPositionSmooth(reach_board.positionToWorld({1.02,0.2,0.67}))
    zero_marker.setRotationSmooth({0.00, 90.00, 0.00})
    AmbitionMarkers.resetButton()
end

function AmbitionMarkers.highestUndeclared()

    local available_markers = marker_zone.getObjects()
    local high_points = 0
    local high_marker = nil
    local marker_mapping = {
        [ambition_marker_GUIDs[1]] = markers[1],
        [ambition_marker_GUIDs[2]] = markers[2],
        [ambition_marker_GUIDs[3]] = markers[3],
    }

    for _, marker in pairs(available_markers) do
        local this_marker = marker_mapping[marker.getGUID()]
        local this_points = this_marker[this_marker.object.is_face_down].first_power
        if this_points > high_points then
            high_points = this_points
            high_marker = this_marker
        end
    end

    return high_marker

end

function AmbitionMarkers.resetZeroMarker()
    zero_marker.setPositionSmooth(reach_board.positionToWorld({0.94,0.2,1.09}))
    zero_marker.setRotationSmooth({0.00, 180.00, 0.00})
    AmbitionMarkers.declareButton()
end

-- Begin Object Code --
function onLoad()                           AmbitionMarkers.addButton()             end
function declareAmbition(_,player_color)    AmbitionMarkers.declare(player_color)   end
function resetZeroMarker()                  AmbitionMarkers.resetZeroMarker()       end
-- End Object Code --

return AmbitionMarkers