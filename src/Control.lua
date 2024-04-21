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

local start_round_params = {
    index = 1,
    function_owner = self,
    click_function = "start_round",
    label = "Start Round",
    tooltip = "Deal action cards",
    height = 260,
    width = 820,
    position = {0, 0.5, -0.59},
    font_size = 90,
    font_color = {0, 0, 0},
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local endHand_params = {
    index = 2,
    function_owner = self,
    click_function = "end_hand",
    label = "End Hand",
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
    ActionCards.draw_bottom_setup()
    self.createButton(controls_params)
    self.createButton(start_round_params)
    self.createButton(endHand_params)
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

function start_round()
    Initiative.unseize()
    ActionCards.clear_face_up_discard()

    if (ActionCards.check_hands()) then
        return
    end

    ActionCards.deal_hand()
end

function end_hand()
    ActionCards.clear_played()
    AmbitionMarkers.reset_zero_marker()
    Initiative.unseize()

    -- Find surpassing card
    local surpass = ActionCards.get_surpassing_card()
    if (surpass == nil) then
        return
    end
    local surpass_name = surpass.type .. " " .. tostring(surpass.number)

    local all_players = Global.getVar("active_players")
    for _, p in ipairs(all_players) do

        if (p.last_action_card and p.last_action_card == surpass_name) then
            Initiative.take(p.color)

            p.last_action_card = nil
        end
    end
end

function take_initiative(objectButtonClicked, playerColorClicked)
    Initiative.take(playerColorClicked)
end

function seize_initiative(objectButtonClicked, playerColorClicked)
    Initiative.seize(playerColorClicked)
end
