require("src/GUIDs")

local ActionCards = {}

local deck = getObjectFromGUID(action_deck_GUID)

local played_zone = getObjectFromGUID(action_card_zone_GUID)
local lead_zone = getObjectFromGUID(lead_card_zone_GUID)

-- Face Down Discard
local fdd_pos = Vector({0.94, 10.00, -1.26})
local fdd_rot = Vector({0.00, 90.00, 180.00})

-- Face Up Discard
local fud_marker = getObjectFromGUID(FUDiscard_marker_GUID)
local fud_marker_pos = {
    [true] = Vector({-19.93, 0.96, -2.31}),
    [false] = Vector({-19.93, -1.00, -2.31})
}
local fud_discard_action_deck = getObjectFromGUID(
    face_up_discard_action_deck_GUID)
local fud_pos = Vector({-3.60, 0.10, 0.00})
local fud_rot = Vector({0.00, 90.00, 0.50})
local fud_offset = Vector({0.42, 0.00, 0.00})
local fud_tag = "Face Up Discard Action"
local is_fud_active = true

local face_up_discard_guids = {
    ["Administration 1"] = "b994c0",
    ["Administration 2"] = "a2931d",
    ["Administration 3"] = "d129a1",
    ["Administration 4"] = "a66e2a",
    ["Administration 5"] = "94fc68",
    ["Administration 6"] = "6aeb5e",
    ["Administration 7"] = "9b829b",
    ["Aggression 1"] = "f3c7de",
    ["Aggression 2"] = "03b948",
    ["Aggression 3"] = "698e3b",
    ["Aggression 4"] = "2a414a",
    ["Aggression 5"] = "8d6270",
    ["Aggression 6"] = "c421f0",
    ["Aggression 7"] = "9ab788",
    ["Construction 1"] = "dcff50",
    ["Construction 2"] = "8946d4",
    ["Construction 3"] = "36b467",
    ["Construction 4"] = "06317b",
    ["Construction 5"] = "432418",
    ["Construction 6"] = "478926",
    ["Construction 7"] = "0c38cb",
    ["Mobilization 1"] = "5694f9",
    ["Mobilization 2"] = "a6d390",
    ["Mobilization 3"] = "e43e5d",
    ["Mobilization 4"] = "8f521a",
    ["Mobilization 5"] = "bcf2e7",
    ["Mobilization 6"] = "7981dc",
    ["Mobilization 7"] = "864dd1"
}

function ActionCards.setup_deck(player_ct)
    local four_player_deck = getObjectFromGUID(action_deck_4P_GUID)
    if (player_ct == 4) then
        deck.putObject(four_player_deck)
        Wait.time(function()
            deck.randomize()
        end, 1.5)
    else
        destroyObject(four_player_deck)
    end
end

function ActionCards.setup_events(player_ct)
    local event_deck = getObjectFromGUID(event_deck_GUID)
    if (player_ct == 4) then
        event_deck.takeObject().destroy()
    end
    deck.putObject(event_deck)
    Wait.time(function()
        deck.randomize()
    end, 1.5)
end

function ActionCards.toggle_face_up_discard()
    is_fud_active = not is_fud_active
    fud_marker.setPosition(fud_marker_pos[is_fud_active])
    return is_fud_active
end

function ActionCards.is_face_up_discard_active()
    return is_fud_active
end

function ActionCards.deal_hand()
    broadcastToAll("Shuffle and deal 6 action cards to all players")
    deck.randomize()
    Wait.time(function()
        deck.deal(6)
    end, 1)
end

function ActionCards.check_deck()
    local deck_size = #getSeatedPlayers() == 4 and 28 or 20
    return deck_size <= #deck.getObjects()
end

function ActionCards.check_hands()
    local has_hand = false
    for _, player in pairs(Player.getPlayers()) do
        if #player.getHandObjects() > 0 then
            broadcastToAll(
                player.color .. " still has cards in hand!",
                player.color)
            has_hand = true
        end
    end
    return has_hand
end

function ActionCards.clear_played()

    local played_objects = played_zone.getObjects()
    local supplies = require("src/Supplies")

    -- Error on union card
    for _, obj in pairs(played_objects) do
        if obj.hasTag("Guild") then
            broadcastToAll("Resolve Guild card before cleanup!",
                Color.Red)
            return false
        end
    end

    -- clean up
    broadcastToAll("Cleanup action card area")

    for ct, obj in ipairs(played_objects) do
        if (obj.getName() ~= "Action Card") then
            supplies.returnObject(obj)
        elseif (is_fud_active and not obj.is_face_down) then
            ActionCards.to_face_up_discard(obj)
            ActionCards.to_face_down_discard(obj)
        else
            ActionCards.to_face_down_discard(obj)
        end
    end

    return true

end

function ActionCards.to_face_down_discard(card)
    local reach_map = getObjectFromGUID(reach_board_GUID)
    local pos = reach_map.positionToWorld(fdd_pos)
    local rot = fdd_rot
    card.setPositionSmooth(pos)
    card.setRotationSmooth(rot)
end

function ActionCards.to_face_up_discard(card)
    local count = #ActionCards.get_face_up_discard_cards()
    local pos = fud_pos + count * fud_offset;
    pos = fud_marker.positionToWorld(pos)
    local rot = fud_rot

    local card_name = card.getDescription()

    local discarded_card = fud_discard_action_deck.takeObject({
        guid = face_up_discard_guids[card_name]
    })
    discarded_card.addTag(fud_tag)
    discarded_card.setLock(true)
    discarded_card.setPosition(pos)
    discarded_card.setRotation(rot)
end

function ActionCards.clear_face_up_discard()
    for ct, obj in ipairs(ActionCards.get_face_up_discard_cards()) do
        obj.setLock(false)
        obj.removeTag(fud_tag)
        fud_discard_action_deck.putObject(obj)
    end
end

function ActionCards.get_face_up_discard_cards()
    return getObjectsWithTag(fud_tag)
end

-- Returns the type and number of an action card
function ActionCards.get_info(card)

    if (card.getName() ~= "Action Card") then
        return
    end

    local card_type = string.sub(card.getDescription(), 1, -3)
    local card_number =
        tonumber(string.sub(card.getDescription(), -1))

    if (card_type == "Faithful") then
        card_type = card.getRotation().z < 180 and "Faithful Zeal" or
                        "Faithful Wisdom"
    end

    return {
        type = card_type,
        number = card_number
    }

end

-- Returns type and number of lead card
function ActionCards.get_lead_info()
    for _, obj in ipairs(lead_zone.getObjects()) do
        if (obj.getName() == "Action Card") then
            return ActionCards.get_info(obj)
        end
    end
    return nil
end

function ActionCards.draw_bottom_setup()
    deck.addContextMenuItem("Draw bottom card",
        ActionCards.draw_bottom)
end

function ActionCards.draw_bottom(player_color, position, object)
    local hand_zone = Player[player_color].getHandTransform()
    deck.takeObject({
        top = false,
        position = hand_zone.position,
        rotation = hand_zone.rotation + Vector({0, 180, 0})
    })
end

return ActionCards
