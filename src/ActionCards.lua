require("src/GUIDs")
local LOG = require("src/LOG")
local supplies = require("src/Supplies")

local ActionCards = {}

-- Face Down Discard
local fdd_pos = Vector({0.94, 10.00, -1.26})
local fdd_rot = Vector({0.00, 90.00, 180.00})

-- Face Up Discard

local fud_marker_pos = {
    [true] = Vector({-19.93, 0.96, -2.31}),
    [false] = Vector({-19.93, -1.00, -2.31})
}

local fud_pos = Vector({-3.70, 0.10, 0.00})
local fud_rot = Vector({0.00, 90.00, 0.50})
local fud_offset = Vector({0.35, 0.00, 0.00})
local fud_tag = "Face Up Discard Action"

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
    ["Mobilization 7"] = "864dd1",
    ["Event"] = "fe7a80",
    ["Event"] = "eff76c",
    ["Event"] = "39a322"
}

function ActionCards.get_action_deck()
    local action_deck_zone = getObjectFromGUID(action_deck_zone_GUID)
    local action_deck_zone_objects = action_deck_zone.getObjects()

    if (action_deck_zone_objects) then
        for _, v in ipairs(action_deck_zone_objects) do
            if (v.name == "Deck") then
                action_deck_GUID = v.guid
            end
        end
    end

    return getObjectFromGUID(action_deck_GUID)
end

function ActionCards.setup_deck(player_count)
    local four_player_deck = getObjectFromGUID(action_deck_4P_GUID)
    local deck = ActionCards.get_action_deck()
    if (player_count == 4) then
        deck.putObject(four_player_deck)
        Wait.time(function()
            deck.randomize()
        end, 1.5)
    else
        destroyObject(four_player_deck)
    end
end

function ActionCards.setup_events(player_count)
    local event_deck = getObjectFromGUID(event_deck_GUID)
    local deck = ActionCards.get_action_deck()
    if (player_count < 4) then
        event_deck.takeObject().destroy()
    end
    deck.putObject(event_deck)
    Wait.time(function()
        deck.randomize()
    end, 1.5)
end

function ActionCards.toggle_face_up_discard()
    local is_fud_active = Global.getVar("is_face_up_discard_active")
    is_fud_active = not is_fud_active
    local fud_marker = getObjectFromGUID(FUDiscard_marker_GUID)
    fud_marker.setPosition(fud_marker_pos[is_fud_active])
    Global.setVar("is_face_up_discard_active", is_fud_active)
    return is_fud_active
end

function ActionCards.is_face_up_discard_active()
    return Global.getVar("is_face_up_discard_active")
end

function ActionCards.deal_hand()
    broadcastToAll("Shuffle and deal 6 action cards to all players")
    local deck = ActionCards.get_action_deck()
    deck.randomize()
    Wait.time(function()
        deck.deal(6)
    end, 1)
end

function ActionCards.check_deck()
    local deck = ActionCards.get_action_deck()
    local deck_size = #getSeatedPlayers() == 4 and 28 or 20
    return deck_size <= #deck.getObjects()
end

function ActionCards.check_hands()
    local active_players = Global.getVar("active_players")
    for _, player in ipairs(active_players) do
        if #Player[player.color].getHandObjects() > 0 then
            broadcastToAll("" .. player.color .. " still has cards in hand!",
                player.color)
            return true
        end
    end
    return false
end

function ActionCards.clear_played()
    LOG.INFO("ActionCards.clear_played")

    local played_objects = getObjectFromGUID(action_card_zone_GUID).getObjects()

    -- Handle union cards
    local union_marked_cards = ActionCards.union_handling(played_objects)
    local union_center_card_offset = 0

    -- clean up
    for ct, obj in ipairs(played_objects) do
        if (obj.getName() ~= "Action Card") and obj.hasTag("Resource") then
            supplies.returnObject(obj)
        end
        if obj.getName() == "Action Card" then
            if Global.getVar("is_face_up_discard_active") then
                ActionCards.to_face_up_discard(obj)
            end

            local is_union_card = false
            if union_marked_cards and #union_marked_cards > 0 then
                for _, card_info in ipairs(union_marked_cards) do
                    if card_info.guid == obj.guid then
                        ActionCards.to_center_board(obj, union_center_card_offset)
                        union_center_card_offset = union_center_card_offset + 1
                        is_union_card = true
                        break
                    end
                end
            end

            if not is_union_card then
                ActionCards.to_face_down_discard(obj)
            end
        elseif (obj.getName() ~= "Action Card") and obj.hasTag("Court") and not string.find(obj.getDescription(), "Union") then
            local court_discard = getObjectFromGUID(court_discard_zone_GUID)
            if court_discard then
                obj.setPositionSmooth(court_discard.getPosition() + Vector({0, 3, 0}))
                obj.setRotationSmooth(Vector({0, 270, 0}))
            end
        end
    end

    return true
end

function ActionCards.to_face_down_discard(card)
    LOG.INFO("ActionCards.to_face_down_discard")
    local reach_map = getObjectFromGUID(reach_board_GUID)
    local pos = reach_map.positionToWorld(fdd_pos)
    local rot = fdd_rot
    card.setPositionSmooth(pos)
    card.setRotationSmooth(rot)
end

function ActionCards.to_face_up_discard(card)
    LOG.INFO("ActionCards.to_face_up_discard")
    local count = #ActionCards.get_face_up_discard_cards()
    local pos = fud_pos + count * fud_offset;
    local fud_marker = getObjectFromGUID(FUDiscard_marker_GUID)
    pos = fud_marker.positionToWorld(pos)
    local rot = fud_rot

    local card_name = card.getDescription()

    local discarded_card = nil
    local fud_discard_action_deck = getObjectFromGUID(
        face_up_discard_action_deck_GUID)

    for _, v in ipairs(fud_discard_action_deck.getObjects()) do
        if (v.description == card_name) then
            discarded_card = fud_discard_action_deck.takeObject({
                guid = v.guid
            })
            break
        end
    end

    if (discarded_card) then
        discarded_card.addTag(fud_tag)
        discarded_card.setLock(true)
        discarded_card.setPosition(pos)
        discarded_card.setRotation(rot)
    end

end

function ActionCards.to_center_board(card, offset)
    card_shift_offset = offset * -0.05
    local center_pos = getObjectFromGUID(reach_board_GUID).positionToWorld(Vector({(0.07 + card_shift_offset), 10.00, 0}))
    card.setPositionSmooth(center_pos)
    card.setRotationSmooth(Vector({0, 180, 0}))
end

function ActionCards.clear_face_up_discard()
    LOG.DEBUG("ActionCards.clear_face_up_discard()")
    local fud_discard_action_deck = getObjectFromGUID(
        face_up_discard_action_deck_GUID)

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
    local card_number = tonumber(string.sub(card.getDescription(), -2, -1))

    if (card_type == "Faithful") then
        card_type = card.getRotation().y < 180 and "Faithful Zeal" or
                        "Faithful Wisdom"
    end

    return {
        guid = card.guid,
        type = card_type,
        number = card_number
    }

end

-- Returns type and number of lead card
function ActionCards.get_lead_info()
    local lead = nil
    local is_ambition_declared = false
    local lead_zone = getObjectFromGUID(lead_card_zone_GUID)

    if (lead_zone) then
        for _, obj in ipairs(lead_zone.getObjects()) do
            if (obj.getName() == "Action Card") then
                lead = ActionCards.get_info(obj)
                lead.real_number = lead.number
            end

            if (obj.getName() == "Zero Marker") then
                is_ambition_declared = true
            end
        end
    else
        LOG.ERROR("Could not find lead zone")
    end

    if (is_ambition_declared) then
        LOG.TRACE("ambition is declared, setting lead number to 0")
        lead.number = 0
    end
    if (lead) then
        LOG.DEBUG("leading card: " .. lead.type .. " " .. lead.number)
    end
    return lead
end

function ActionCards.get_surpassing_card()
    local lead = ActionCards.get_lead_info()
    if (not lead) then
        LOG.ERROR("Could not determine lead card")
        return nil
    end

    local surpassing_card = nil
    local max_surpassing_number = 0
    local played_zone = getObjectFromGUID(action_card_zone_GUID)

    for _, v in ipairs(played_zone.getObjects()) do
        if (v.guid == lead.guid) then
            goto continue
        end

        if v.getName() ~= "Action Card" then
            goto continue
        end

        do -- avoid error with goto jumping into surpassing_card scope
            local card = ActionCards.get_info(v)
            if (card) then
                LOG.DEBUG("card: " .. card.type .. " " .. card.number)
            end
            if (card and lead.type == card.type and lead.number < card.number and
                card.number > max_surpassing_number) then
                max_surpassing_number = card.number
                surpassing_card = card
            end
        end
        ::continue::
    end

    if (surpassing_card) then
        LOG.INFO("surpassing card: " .. surpassing_card.type .. " " ..
                     surpassing_card.number)
    end
    return surpassing_card
end

function ActionCards.count_seize_cards()
    local seize_zone = getObjectFromGUID(seize_zone_GUID)
    if (not seize_zone) then
        return 0
    end
    local seize_zone_objects = seize_zone.getObjects()
    local count = 0
    for _, obj in ipairs(seize_zone_objects) do
        if obj.hasTag("Action") and obj.is_face_down then
            count = count + 1
        end
    end
    return count
end

function ActionCards.count_action_cards()
    local count = 0
    local played_zone = getObjectFromGUID(action_card_zone_GUID)

    for _, obj in ipairs(played_zone.getObjects()) do
        if obj.hasTag("Action") then
            count = count + 1
        end
    end
    return count
end

function ActionCards.find_seize_player()
    local seize_zone = getObjectFromGUID(seize_zone_GUID)
    local seize_zone_objects = seize_zone.getObjects()
    for _, obj in ipairs(seize_zone_objects) do
        if obj.hasTag("Action") and obj.is_face_down then
            local seize_card = ActionCards.get_info(obj)
            local all_players = Global.getVar("active_players")
            for _, p in ipairs(all_players) do
                if p.last_seize_card and p.last_seize_card.type ==
                    seize_card.type and p.last_seize_card.number ==
                    seize_card.number then
                    return p.color
                end
            end
        end
    end
    print("No seize player found despite detecting a seize card")
    return nil
end

function ActionCards.draw_bottom(player_color, position, object)
    local hand_zone = Player[player_color].getHandTransform()
    local deck = ActionCards.get_action_deck()
    local drawn_card = deck.takeObject({
        top = false,
        position = hand_zone.position,
        rotation = hand_zone.rotation + Vector({0, 180, 180})
    })
    -- wait .75 seconds and flip it face up
    Wait.time(function()
        drawn_card.setRotation(Vector({0, 180, 0}))
    end, 0.75)
end

function ActionCards.faceup_discard_visibility(show)
    local visibility = show and {} or
                           {"Red", "White", "Yellow", "Teal", "Black", "Grey"}
    local discard = getObjectFromGUID(FUDiscard_marker_GUID)
    discard.setInvisibleTo(visibility)
end

function ActionCards.get_fud_marker()
    local fud_marker = getObjectFromGUID(FUDiscard_marker_GUID)
    return fud_marker
end

-- Returns a list of action card GUIDs marked for union cards
function ActionCards.union_handling(played_objects)
    LOG.INFO("ActionCards.union_handling")

    local union_marked_cards = {}

    for _, obj in pairs(played_objects) do
        -- Check if the card name contains "UNION" instead of checking tags
        if obj.getName() and string.find(string.upper(obj.getName()), "UNION") then
            -- Find the closest face up action card
            local closest_face_up_action_card = nil
            local min_distance = 20

            for _, card in pairs(played_objects) do
                if card.getName() == "Action Card" and not card.is_face_down then
                    local distance = Vector.distance(obj.getPosition(), card.getPosition())
                    if distance < min_distance then
                        min_distance = distance
                        closest_face_up_action_card = card
                    end
                end
            end

            if closest_face_up_action_card then
                table.insert(union_marked_cards, {
                    guid = closest_face_up_action_card.guid,
                    description = closest_face_up_action_card.getDescription(),
                    reserved_by = obj.getName()
                })
                print("Whoever played " .. obj.getName() .. ", please pull " .. closest_face_up_action_card.getDescription() .. " back into your hand.")

                -- Move the union card to court discard
                local court_discard = getObjectFromGUID(court_discard_zone_GUID)
                if court_discard then
                    obj.setPositionSmooth(court_discard.getPosition() + Vector({0, 3, 0}))
                    obj.setRotationSmooth(Vector({0, 270, 0}))
                end
            else
                broadcastToAll("Union card in play but no face up action cards to mark for union recall", Color.Red)
            end
        end
    end

    return union_marked_cards
end

return ActionCards
