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
    local initiative = getObjectFromGUID(initiative_GUID)
    local player_board = getObjectFromGUID(
        player_pieces_GUIDs[player_color]["player_board"])
    local pos = player_board.positionToWorld(initiative_pos)

    if (initiative) then
        initiative.setPositionSmooth(pos)
        if not silent then
            broadcastToAll(player_color .. " takes the initiative", player_color)
        end
    end

    Global.setVar("initiative_player", player_color)
end

function InitiativeMarker.seize(player_color,  silent)
    local initiative = getObjectFromGUID(initiative_GUID)
    local player_board = getObjectFromGUID(
        player_pieces_GUIDs[player_color]["player_board"])
    local pos = player_board.positionToWorld(initiative_pos)

    if (initiative) then
        initiative.setPositionSmooth(pos)
        Wait.time(function()
            initiative.setState(2)
        end, 1.5)
        if not silent then
            broadcastToAll(player_color .. " has seized the initiative", player_color)
        end
    else
        broadcastToAll("Initiative has already been seized.", Color.Red)
    end
    Global.setVar("initiative_player", player_color)
end

return InitiativeMarker
