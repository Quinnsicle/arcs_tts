require("src/GUIDs")

local ActionCards = {}

local deck          = getObjectFromGUID(action_deck_GUID)

local played_zone   = getObjectFromGUID(action_card_zone_GUID)
local lead_zone     = getObjectFromGUID(lead_card_zone_GUID)

-- Face Down Discard
local FDD_pos   = Vector({0.94, 10.00, -1.26})
local FDD_rot   = Vector({0.00, 90.00, 180.00})

-- Face Up Discard
local FUD_marker        = getObjectFromGUID(FUDiscard_marker_GUID)
local FUD_pos           = Vector({-4.00,0.00,0.00})
local FUD_rot           = Vector({0.00, 90.00, 0.00})
local FUD_offset        = Vector({0.50,0.50,0.00})
local FUD_tag           = "Face Up Discard Action"
local is_FUD_active     = true

function ActionCards.setupFourPlayer(player_ct)
    local four_player_deck = getObjectFromGUID(action_deck_4P_GUID)
    if (player_ct == 4) then
        deck.putObject(four_player_deck)
        Wait.time(function() deck.randomize() end, 1.5)
    else
        destroyObject(four_player_deck)
    end
end

function ActionCards.setupEvents(player_ct)
    local event_deck = getObjectFromGUID(event_deck_GUID)
    if (player_ct == 4) then
        event_deck.takeObject().destroy()
    end
    deck.putObject(event_deck)
    Wait.time(function() deck.randomize() end, 1.5)
end

function ActionCards.toggleFUD()
    is_FUD_active = not is_FUD_active
    local pos = is_FUD_active and Vector({0,5,0}) or Vector({0,-5,0}); pos = pos + FUD_marker.getPosition()
    FUD_marker.setPosition(pos)
    return is_FUD_active
end

function ActionCards.isFUDActive()
    return is_FUD_active
end

function ActionCards.dealHand()
    broadcastToAll("Shuffle and deal 6 action cards to all players")
    deck.randomize()
    Wait.time(function() deck.deal(6) end, 1)
end

function ActionCards.checkDeck()
    local deck_size = #getSeatedPlayers() == 4 and 28 or 20
    return deck_size <= #deck.getObjects()
end

function ActionCards.checkHands()
    local has_hand = false
    for _, player in pairs(Player.getPlayers()) do
        if #player.getHandObjects() > 0 then
            broadcastToAll(player.color.." still has cards in hand!", player.color)
            has_hand = true
        end
    end
    return has_hand
end

function ActionCards.clearPlayed()

    local played_objects = played_zone.getObjects()
    local supplies  = require("src/Supplies")

    -- Error on union card
    for _, obj in pairs(played_objects) do
        if obj.hasTag("Guild") then
            broadcastToAll("Resolve Guild card before cleanup!", Color.Red)
            return false
        end
    end

    -- clean up
    broadcastToAll("Cleanup action card area")

    for ct, obj in ipairs(played_objects) do
        if (obj.getName() ~= "Action Card") then
            supplies.returnObject(obj)
        elseif (is_FUD_active and not obj.is_face_down) then
            ActionCards.FUDiscard(obj)
        else
            ActionCards.FDDiscard(obj)
        end
    end

    return true

end
 
function ActionCards.FDDiscard(card)
    local reach_map = getObjectFromGUID(reach_board_GUID)
    local pos = reach_map.positionToWorld(FDD_pos)
    local rot = FDD_rot
    card.setPositionSmooth(pos)
    card.setRotationSmooth(rot)
end

function ActionCards.FUDiscard(card)
    local ct = #ActionCards.getFUDCards() + 1
    local pos = FUD_pos + ct*FUD_offset; pos = FUD_marker.positionToWorld(pos)
    local rot = FUD_rot
    card.addTag(FUD_tag)
    card.setPositionSmooth(pos)
    card.setRotationSmooth(rot)
end

function ActionCards.clearFUD()
    for ct, obj in ipairs(ActionCards.getFUDCards()) do
        obj.removeTag(FUD_tag)
        ActionCards.FDDiscard(obj)
    end
end

function ActionCards.getFUDCards()
    return getObjectsWithTag(FUD_tag)
end

-- Returns the type and number of an action card
function ActionCards.getInfo(card)

    if (card.getName() ~= "Action Card") then return end

    local card_type = string.sub(card.getDescription(),1,-3)
    local card_number = tonumber(string.sub(card.getDescription(),-1))

    if (card_type == "Faithful") then
        card_type = card.getRotation().z < 180 
            and "Faithful Zeal"
            or "Faithful Wisdom"
    end

    return {type = card_type, number = card_number}

end

-- Returns type and number of lead card
function ActionCards.getLeadInfo()
    local lead_card = lead_zone.getObjects()[1]
    if (lead_card) then
        return ActionCards.getInfo(lead_card)
    end
    return nil
end

function ActionCards.drawBottomSetup()
    deck.addContextMenuItem("Draw bottom card", ActionCards.drawBottom)
end

function ActionCards.drawBottom(player_color, position, object)
    local hand_zone = Player[player_color].getHandTransform()
    deck.takeObject({
        top = false,
        position = hand_zone.position,
        rotation = hand_zone.rotation + Vector({0,180,0})
    })
end

return ActionCards