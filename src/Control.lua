local ActionCards = require("src/ActionCards")
local AmbitionMarkers = require("src/AmbitionMarkers")
local Initiative = require("src/InitiativeMarker")
local RoundManager = require("src/RoundManager")

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
    width = 590,
    position = {-0.2, 0.5, -0.01},
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

local toggle_auto_end_params = {
    index = 5,
    function_owner = self,
    click_function = "toggle_auto_end",
    label = "Toggle\nAuto\nEnd",
    tooltip = "Toggle Auto End Round.\n\nThis will eventually become the default, please report any problems to the Steam Workshop or Github page",
    height = 260,
    width = 220,
    position = {0.6, 0.5, -0.01},
    font_size = 50,
    color = {0.2, 0.5, 0.2},
    hover_color = {0.34, 0.48, 0.34}
}

function onload()
    self.createButton(controls_params)
    self.createButton(start_chapter_params)
    self.createButton(end_round_params)
    self.createButton(takeInitiative_params)
    self.createButton(seizeInitiative_params)
    self.createButton(toggle_auto_end_params)
    self.createButton({
        index = 10,
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
    if ActionCards.count_action_cards() > 0 then
        broadcastToAll("There are still action cards in play, please End Round and try again.", Color.Red)
        return
    end

    Initiative.unseize()
    ActionCards.clear_face_up_discard()

    if (ActionCards.check_hands()) then
        return
    end

    ActionCards.deal_hand()

    local initiative_player = Global.getVar("initiative_player")
    if (initiative_player) then
        broadcastToAll(initiative_player .. " will start the chapter\n",
            initiative_player)
        Turns.turn_color = initiative_player
    else
        broadcastToAll(
            "\n\n!!Could not determine initiative player!!\nPlease ensure initiative marker is near a player board.\n\n")
    end
end

function end_round()
    RoundManager.endRound()
end

function toggle_auto_end()
    local toggle = Global.getVar("is_auto_end_round_enabled")

    toggle = not toggle
    Global.setVar("is_auto_end_round_enabled", toggle)

    if (toggle) then
        local GREEN = {0.2, 0.5, 0.2}
        self.editButton({
            index = 5,
            color = GREEN,
            hover_color = {0.34, 0.48, 0.34}
        })
    else
        local RED = {0.8, 0.3, 0.2}
        self.editButton({
            index = 5,
            color = RED,
            hover_color = {0.48, 0.34, 0.34}
        })
    end
end

function take_initiative(objectButtonClicked, playerColorClicked)
    Initiative.take(playerColorClicked)
end

function seize_initiative(objectButtonClicked, playerColorClicked)
    Initiative.seize(playerColorClicked)
end
