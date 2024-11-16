local ActionCards = require("src/ActionCards")
local AmbitionMarkers = require("src/AmbitionMarkers")
local Initiative = require("src/InitiativeMarker")

control_GUID = Global.getVar("control_GUID")

-- font_color = {0.8, 0.58, 0.27}, GOLD
local teal = {0.4, 0.6, 0.6}

-- Button Rows
-- Row 1 - {x, y, -1.17}
-- Row 2 - {x, y, -0.59}
-- Row 3 - {x, y, -0.01}
-- Row 4 - {x, y, 0.57}
-- Row 5 - {x, y, 1.15}

-- Button Columns
-- Full Col   - {0.00, y, z}
-- Left Side  - {-0.45, y, z}
-- Right Side - {0.45, y, z}

-- Dimension
-- Height - height = 260
-- Full Col - width = 820
-- Half Col - width = 440

local controls_params = {
    index = 0,
    function_owner = self,
    click_function = "doNothing",
    label = "Controls",
    height = 1,
    width = 1,
    position = {0, 0.5, -1.17},
    tooltip = "",
    font_size = 160,
    color = {0, 0, 0},
    hover_color = {0, 0, 0},
    font_color = {0.8, 0.58, 0.27}
}

local start_chapter_params = {
    index = 1,
    function_owner = self,
    click_function = "start_chapter",
    label = "Start Chapter",
    tooltip = "Deal action cards",
    height = 260,
    width = 820,
    position = {0, 0.5, -0.59},
    font_size = 90,
    font_color = {0, 0, 0},
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local end_round_params = {
    index = 2,
    function_owner = self,
    click_function = "end_round",
    label = "End Round",
    tooltip = "Cleanup action cards",
    height = 260,
    width = 820,
    position = {0, 0.5, -0.01},
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local takeInitiative_params = {
    index = 3,
    function_owner = self,
    click_function = "take_initiative",
    label = "Take\nInitiative",
    height = 260,
    width = 440,
    tooltip = "",
    position = {-0.45, 0.5, 0.57},
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local seizeInitiative_params = {
    index = 4,
    height = 260,
    width = 440,
    function_owner = self,
    click_function = "seize_initiative",
    label = "Seize\nInitiative",
    tooltip = "",
    position = {0.45, 0.5, 0.57},
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

function onload()
    self.createButton(controls_params)
    self.createButton(start_chapter_params)
    self.createButton(end_round_params)
    self.createButton(takeInitiative_params)
    self.createButton(seizeInitiative_params)
    self.createButton({
        index = 5,
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
end

function doNothing()
end

function start_chapter()
    Initiative.unseize()
    ActionCards.clear_face_up_discard()

    if (ActionCards.check_hands()) then
        return
    end

    ActionCards.deal_hand()

    local initiative_player = Global.getVar("initiative_player")
    broadcastToAll(initiative_player .. " will start the chapter\n", initiative_player)
    Turns.turn_color = initiative_player
    Global.call("startTimer")
end

function end_round()
    -- Seize detection
    local seize_detected = false
    if ActionCards.count_seize_cards() == 1 then
        seize_detected = true
    elseif ActionCards.count_seize_cards() > 1 then
        broadcastToAll("Multiple seize cards detected, please fix the board and try to End Round again", Color.Red)
        return
    end

    local initiative_player = Global.getVar("initiative_player")
    local all_players = Global.getVar("active_players")

    if Initiative.is_seized() and seize_detected then
        -- Someone already manually seized initiative
        Initiative.unseize()
    elseif not Initiative.is_seized() and seize_detected then
        -- Auto seize initiative for player with last played seize card
        local seize_player_color = ActionCards.find_seize_player()
        if seize_player_color then
            Initiative.take(seize_player_color, true)
            broadcastToAll(seize_player_color .. " has seized the initiative", seize_player_color)
        else
            broadcastToAll("Whoever is playing the seize card, pick it up and drop it back into place, then hit End Round again.", Color.Red)
            return
        end
    else
        -- Check for highest surpassing card
        local surpassing = ActionCards.get_surpassing_card()
        if not surpassing then
            broadcastToAll("No surpassing card, ".. initiative_player .. " keeps the initiative", initiative_player)
        else
            -- Assign initiative to player with highest surpassing card
            for _, p in ipairs(all_players) do
                if p.last_action_card and
                   p.last_action_card.type == surpassing.type and
                   p.last_action_card.number == surpassing.number then
                    Initiative.unseize()
                    Initiative.take(p.color, true)
                    broadcastToAll(p.color .. " has surpassed and takes the initiative", p.color)
                    break
                end
            end
        end
    end

    AmbitionMarkers.reset_zero_marker()
    ActionCards.clear_played()
    -- reset p.last_action_card + p.last_seize_card for all players
    -- otherwise weird bugs happen when state carries over to the next round
    for _, p in ipairs(all_players) do
        p.last_action_card = nil
        p.last_seize_card = nil
    end
    broadcastToAll("End Round\n", Color.Purple)

    Turns.turn_color = Global.getVar("initiative_player")
    Initiative.unseize()
end

function take_initiative(objectButtonClicked, playerColorClicked)
    Initiative.take(playerColorClicked)
end

function seize_initiative(objectButtonClicked, playerColorClicked)
    Initiative.seize(playerColorClicked)
end
