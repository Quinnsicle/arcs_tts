local Campaign = require("src/Campaign")
local BaseGame = require("src/BaseGame")
local ActionCards = require("src/ActionCards")
local AmbitionMarkers = require("src/AmbitionMarkers")
local Initiative = require("src/InitiativeMarker")

local debug = Global.getVar("debug")

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

local toggleLeadersWITHOUT_params = {
    index = 0,
    click_function = "toggleLeaders",
    function_owner = self,
    label = "Play\nWITHOUT\nLeaders & Lore",
    tooltip = "No Leaders",
    position = {0, 0.5, -1.17},
    width = 820,
    height = 260,
    font_size = 72,
    scale = {1, 1, 1},
    color = {0.85, 0.3, 0.2},
    font_color = {0, 0, 0}
}

local toggleLeadersWITH_params = {
    index = 0,
    click_function = "toggleLeaders",
    function_owner = self,
    label = "Play\nWITH\nLeaders & Lore",
    tooltip = "Deals Leaders",
    position = {0, 0.5, -1.17},
    width = 820,
    height = 260,
    font_size = 72,
    scale = {1, 1, 1},
    color = {0.28, 0.52, 0.18},
    font_color = {0, 0, 0}
}

local toggleExpansionEXCLUDE_params = {
    index = 1,
    click_function = "toggleExpansion",
    function_owner = self,
    label = "EXCLUDE\nLeaders & Lore\nExpansion",
    tooltip = "Exclude additional Leaders & Lore",
    position = {-0.45, 0.5, -0.59},
    width = 440,
    height = 260,
    font_size = 60,
    scale = {1, 1, 1},
    color = {0.85, 0.3, 0.2}
}

local toggleExpansionINCLUDE_params = {
    index = 1,
    click_function = "toggleExpansion",
    function_owner = self,
    label = "INCLUDE\nLeaders & Lore\nExpansion",
    tooltip = "Include additional Leaders & Lore",
    position = {-0.45, 0.5, -0.59},
    width = 440,
    height = 260,
    font_size = 60,
    scale = {1, 1, 1},
    color = {0.28, 0.52, 0.18}
}

local splitDiscardFACEDOWN_params = {
    index = 5,
    function_owner = self,
    click_function = "toggleSplitDiscard",
    label = "Discard\nFACEDOWN",
    tooltip = "Discard all cards facedown",
    position = {0.45, 0.5, -0.59},
    width = 440,
    height = 260,
    font_size = 60,
    scale = {1, 1, 1},
    color = {0.85, 0.3, 0.2}
}

local splitDiscardFACEUP_params = {
    index = 5,
    function_owner = self,
    click_function = "toggleSplitDiscard",
    label = "Discard\nFACEUP",
    tooltip = "Discard faceup cards in a separate pile",
    position = {0.45, 0.5, -0.59},
    width = 440,
    height = 260,
    font_size = 60,
    scale = {1, 1, 1},
    color = {0.28, 0.52, 0.18}
}

local setupBaseGame_params = {
    index = 2,
    click_function = "setupBaseGame",
    function_owner = self,
    label = "Start Base Game",
    position = {0, 0.5, -0.01},
    width = 820,
    height = 260,
    font_size = 90,
    scale = {1, 1, 1},
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local setupCampaignGame_params = {
    index = 3,
    click_function = "setupCampaignGame",
    function_owner = self,
    label = "Start Campaign",
    position = {0, 0.5, 0.57},
    width = 820,
    height = 260,
    font_size = 90,
    scale = {1, 1, 1},
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local showControls_params = {
    index = 4,
    click_function = "toggleControls",
    function_owner = self,
    label = "Show Controls",
    position = {0, 0.5, 1.15},
    width = 820,
    height = 260,
    font_size = 90,
    scale = {1, 1, 1},
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}
local showing_controls = false

-- Control Buttons
local controls_params = {
    index = 0,
    height = 1,
    width = 1,
    click_function = "doNothing",
    label = "Controls",
    tooltip = "",
    font_size = 160,
    color = {0, 0, 0},
    hover_color = {0, 0, 0},
    font_color = {0.8, 0.58, 0.27}
}

local start_round_params = {
    index = 1,
    height = 260,
    width = 820,
    position = {0, 0.5, -0.59},
    click_function = "start_round",
    label = "Start Round",
    tooltip = "",
    font_size = 90,
    font_color = {0, 0, 0},
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local endHand_params = {
    index = 2,
    height = 260,
    width = 820,
    click_function = "endHand",
    label = "End Hand",
    tooltip = "",
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local takeInitiative_params = {
    index = 3,
    height = 260,
    width = 440,
    click_function = "takeInitiative",
    label = "Take\nInitiative",
    tooltip = "",
    position = {-0.45, 0.5, 0.57},
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local seizeInitiative_params = {
    index = 6,
    height = 260,
    width = 440,
    click_function = "seizeInitiative",
    function_owner = self,
    label = "Seize\nInitiative",
    tooltip = "",
    position = {0.45, 0.5, 0.57},
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

function onload()
    ActionCards.draw_bottom_setup()
    self.createButton(toggleLeadersWITHOUT_params)
    self.createButton(toggleExpansionEXCLUDE_params)
    self.createButton(setupBaseGame_params)
    self.createButton(setupCampaignGame_params)
    if (debug) then
        self.createButton(showControls_params)
    end
    self.createButton(splitDiscardFACEUP_params)
    self.createButton({
        index = 6,
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
    -- toggle split discard since the rulebook default is face down
    toggleSplitDiscard()
end

function toggleLeaders()
    local toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_leaders", toggle)

    if (toggle) then
        self.editButton(toggleLeadersWITH_params)
    else
        self.editButton(toggleLeadersWITHOUT_params)
    end
end

function toggleExpansion()
    local toggle = Global.getVar("with_more_to_explore")

    toggle = not toggle
    Global.setVar("with_more_to_explore", toggle)

    if (toggle) then
        self.editButton(toggleExpansionINCLUDE_params)
    else
        self.editButton(toggleExpansionEXCLUDE_params)
    end
end

function toggleSplitDiscard()
    local toggle = ActionCards.toggle_face_up_discard()
    if (toggle) then
        self.editButton(splitDiscardFACEUP_params)
    else
        self.editButton(splitDiscardFACEDOWN_params)
    end
end

function setupBaseGame()
    local base_setup_success = BaseGame.setup()

    if (base_setup_success and Global.getVar("with_leaders")) then
        setLeaderControls()
        return
    end

    if (base_setup_success) then
        setControlButtons()
        start_round()
    end

end

function setup_leaders()

    if BaseGame.setup_leaders() == false then
        broadcastToAll(
            "Place chosen leader near player board to continue.", {
                r = 1,
                g = 0,
                b = 0
            })
        return
    end

    setControlButtons()
    start_round()
end

function setupCampaignGame()
    local campaign_setup_success = Campaign.setup()

    if (campaign_setup_success) then
        setControlButtons()
    end
end

function toggleControls()

    local purple_grey = {0.2, 0.22, 0.33}
    local teal = {0.4, 0.6, 0.6}

    if (showing_controls) then
        showing_controls = false
        setStartupButtons()
        self.editButton({
            index = 4,
            height = 260,
            width = 820,
            label = "Show Control",
            tooltip = "",
            font_size = 90,
            color = teal,
            font_color = {0, 0, 0},
            hover_color = {0.34, 0.38, 0.38}
        })
    else
        showing_controls = true
        setControlButtons()
        self.editButton({
            index = 4,
            height = 260,
            width = 820,
            click_function = "toggleControls",
            label = "Show Setup",
            tooltip = "",
            font_size = 90,
            color = teal,
            font_color = {0, 0, 0},
            hover_color = {0.34, 0.38, 0.38}
        })
    end

end

function setStartupButtons()

    local with_leaders = Global.getVar("with_leaders")
    if (with_leaders) then
        self.editButton(toggleLeadersWITH_params)
    else
        self.editButton(toggleLeadersWITHOUT_params)
    end

    local with_more_to_explore = Global.getVar("with_more_to_explore")
    if (with_more_to_explore) then
        self.editButton(toggleExpansionINCLUDE_params)
    else
        self.editButton(toggleExpansionEXCLUDE_params)
    end

    self.editButton(setupBaseGame_params)
    self.editButton(setupCampaignGame_params)
    self.editButton({
        index = 6,
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
    if (debug) then
        self.editButton(showControls_params)
    end

    if (ActionCards.is_face_up_discard_active()) then
        self.editButton(splitDiscardFACEUP_params)
    else
        self.editButton(splitDiscardFACEDOWN_params)
    end
end

function setLeaderControls()
    self.editButton({
        index = 0,
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
    self.editButton({
        index = 1,
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
    self.editButton({
        index = 2,
        font_size = 88,
        click_function = "setup_leaders",
        label = "Setup Leaders",
        tooltip = ""
    })
    self.editButton({
        index = 3,
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
    self.editButton({
        index = 4,
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
    self.editButton({
        index = 5,
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
end

function setControlButtons()
    self.editButton(controls_params)
    self.editButton(start_round_params)
    self.editButton(endHand_params)
    self.editButton(takeInitiative_params)
    self.editButton(seizeInitiative_params)
    self.editButton({
        index = 5,
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
    if (not showing_controls) then
        self.editButton({
            index = 4,
            height = 1,
            width = 1,
            click_function = "doNothing",
            label = "",
            tooltip = ""
        })
    end
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

function endHand()

    ActionCards.clear_played()
    AmbitionMarkers.resetZeroMarker()
    Initiative.unseize()

    -- Find surpassing card
    local surpass = ActionCards.get_surpassing_card()
    if (surpass == nil) then
        return
    end
    local surpass_name = surpass.type .. " " ..
                             tostring(surpass.number)

    local all_players = Global.getVar("active_players")
    for _, p in ipairs(all_players) do

        if (p.last_action_card and p.last_action_card == surpass_name) then
            Initiative.take(p.color)

            p.last_action_card = nil
        end
    end

end

function takeInitiative(objectButtonClicked, playerColorClicked)

    Initiative.take(playerColorClicked)

end

function seizeInitiative(objectButtonClicked, playerColorClicked)

    Initiative.seize(playerColorClicked)

end
