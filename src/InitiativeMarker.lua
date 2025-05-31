require("src/GUIDs")

local InitiativeMarker = {}

local initiative_pos = {-2, 0, -2.2}

-- Initiative marker has an unseized and seized state.
-- If initiative marker exists then initiative is unseaized
-- If seized initiative marker exists then initiative is seized

function InitiativeMarker.add_menu()
    local initiative = getObjectFromGUID(initiative_GUID)
    local initiative_seized = getObjectFromGUID(seized_initiative_GUID)
    if (initiative) then
        initiative.addContextMenuItem("Take Initiative", InitiativeMarker.take)
        initiative.addContextMenuItem("Seize Initiative", InitiativeMarker.seize)
    elseif (initiative_seized) then
        initiative_seized.addContextMenuItem("Unseize Initiative",
            InitiativeMarker.unseize)
        initiative_seized.setLock(true)
    end
end

function InitiativeMarker.is_seized()
    local initiative_seized = getObjectFromGUID(seized_initiative_GUID)
    return initiative_seized
end

function InitiativeMarker.unseize()
    local initiative_seized = getObjectFromGUID(seized_initiative_GUID)
    if (initiative_seized) then
        initiative_seized.setState(1)
    end
end

function InitiativeMarker.take(player_color, silent)
    InitiativeMarker._move_initiative(player_color, silent, false)
end

function InitiativeMarker.seize(player_color, silent)
    InitiativeMarker._move_initiative(player_color, silent, true)
end

function InitiativeMarker._move_initiative(player_color, silent, is_seize)
    local initiative = getObjectFromGUID(initiative_GUID)
    local player_board = getObjectFromGUID(
        player_pieces_GUIDs[player_color]["player_board"])

    local pos_z = (player_color == "Red" or player_color == "White") and 2.2 or -2.2
    local rot_y = (player_color == "Red" or player_color == "White") and 180 or 0
    local pos = player_board.positionToWorld({-2, 0, pos_z})

    if (initiative) then
        initiative.setPositionSmooth(pos)
        initiative.setRotationSmooth({0, rot_y, 0})
        if is_seize then
            Wait.time(function()
                initiative.setState(2)
            end, 1.5)
            if not silent then
                broadcastToAll(player_color .. " has seized the initiative", player_color)
            end
        elseif not silent then
            broadcastToAll(player_color .. " takes the initiative", player_color)
        end
    else
        broadcastToAll("Initiative has already been seized.", Color.Red)
    end
    Global.setVar("initiative_player", player_color)
end

return InitiativeMarker
