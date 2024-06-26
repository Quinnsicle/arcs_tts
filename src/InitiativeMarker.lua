require("src/GUIDs")

local InitiativeMarker = {
    player = nil
}

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

    InitiativeMarker.player = nil
end

function InitiativeMarker.take(player_color)
    local initiative = getObjectFromGUID(initiative_GUID)
    local player_board = getObjectFromGUID(
        player_pieces_GUIDs[player_color]["player_board"])
    local pos = player_board.positionToWorld(initiative_pos)

    if (initiative) then
        initiative.setPositionSmooth(pos)
        broadcastToAll(player_color .. " takes initiative", player_color)
    end

    InitiativeMarker.player = player_color
end

function InitiativeMarker.seize(player_color)
    local initiative = getObjectFromGUID(initiative_GUID)
    local player_board = getObjectFromGUID(
        player_pieces_GUIDs[player_color]["player_board"])
    local pos = player_board.positionToWorld(initiative_pos)

    if (initiative) then
        initiative.setPositionSmooth(pos)
        Wait.time(function()
            initiative.setState(2)
        end, 1.5)
        broadcastToAll(player_color .. " seizes initiative", player_color)
    else
        broadcastToAll("Initiative is already seized.", Color.Red)
    end
    InitiativeMarker.player = player_color
end

return InitiativeMarker
