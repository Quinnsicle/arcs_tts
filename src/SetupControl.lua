local ArcsPlayer = require("src/ArcsPlayer")
local ActionCards = require("src/ActionCards")
local BaseGame = require("src/BaseGame")
local Campaign = require("src/Campaign")
local Counters = require("src/Counters")

local gold = {0.8, 0.58, 0.27}

local toggleLeadersWITHOUT_params = {
    index = 0,
    click_function = "toggle_leaders",
    function_owner = self,
    label = "Play with\nLeaders & Lore",
    tooltip = "Enable leaders",
    position = {0, 0.5, -1.17},
    width = 820,
    height = 260,
    font_size = 72,
    scale = {1, 1, 1},
    color = {0.8, 0.3, 0.2},
    font_color = {0, 0, 0}
}
local toggleLeadersWITH_params = {
    index = 0,
    click_function = "toggle_leaders",
    function_owner = self,
    label = "Play with\nLeaders & Lore",
    tooltip = "Disable leaders",
    position = {0, 0.5, -1.17},
    width = 820,
    height = 260,
    font_size = 72,
    scale = {1, 1, 1},
    color = {0.2, 0.5, 0.2},
    font_color = {0, 0, 0}
}
local toggleExpansionEXCLUDE_params = {
    index = 1,
    click_function = "toggle_expansion",
    function_owner = self,
    label = "Leaders & Lore\nExpansion",
    tooltip = "Enable Leaders & Lore Expansion",
    position = {-0.45, 0.5, -0.59},
    width = 440,
    height = 260,
    font_size = 60,
    scale = {1, 1, 1},
    color = {0.8, 0.3, 0.2}
}
local toggleExpansionINCLUDE_params = {
    index = 1,
    click_function = "toggle_expansion",
    function_owner = self,
    label = "Leaders & Lore\nExpansion",
    tooltip = "Disable Leaders & Lore Expansion",
    position = {-0.45, 0.5, -0.59},
    width = 440,
    height = 260,
    font_size = 60,
    scale = {1, 1, 1},
    color = {0.3, 0.5, 0.2}
}
local splitDiscardFACEDOWN_params = {
    index = 2,
    function_owner = self,
    click_function = "toggle_split_discard",
    label = "Split\nDiscard Piles",
    tooltip = "Enable Split Discard",
    position = {0.45, 0.5, -0.59},
    width = 440,
    height = 260,
    font_size = 60,
    scale = {1, 1, 1},
    color = {0.8, 0.3, 0.2}
}
local splitDiscardFACEUP_params = {
    index = 2,
    function_owner = self,
    click_function = "toggle_split_discard",
    label = "Split\nDiscard Piles",
    tooltip = "Disable Split Discard",
    position = {0.45, 0.5, -0.59},
    width = 440,
    height = 260,
    font_size = 60,
    scale = {1, 1, 1},
    color = {0.3, 0.5, 0.2}
}
local setupBaseGame_params = {
    index = 3,
    click_function = "setup_base_game",
    function_owner = self,
    label = "Start Base Game",
    position = {0, 0.5, -0.01},
    width = 820,
    height = 260,
    font_size = 90,
    scale = {1, 1, 1},
    -- color = {0.4, 0.6, 0.6},
    color = {0.05, 0.05, 0.05},
    font_color = gold,
    hover_color = {0.1, 0.1, 0.1}
}
local setupCampaignGame_params = {
    index = 4,
    click_function = "setup_campaign",
    function_owner = self,
    label = "Start Campaign",
    position = {0, 0.5, 0.57},
    width = 820,
    height = 260,
    font_size = 90,
    scale = {1, 1, 1},
    -- color = {0.4, 0.6, 0.6},
    color = {0.05, 0.05, 0.05},
    font_color = gold,
    hover_color = {0.1, 0.1, 0.1}
}
local customSetup_params = {
    index = 6,
    function_owner = self,
    click_function = "custom_setup",
    label = "Custom Setup",
    tooltip = "",
    position = {0, 0.5, 1.15},
    width = 820,
    height = 260,
    font_size = 90,
    scale = {1, 1, 1},
    color = {0.05, 0.05, 0.05},
    font_color = gold,
    hover_color = {0.1, 0.1, 0.1}
}

SetupControl = {
    setup_control_guid = "7299d7",
    setup_control = {},
    teal = {0.4, 0.6, 0.6}
}

function SetupControl:new(o)
    o = o or SetupControl -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function onload()
    self.createButton(toggleLeadersWITHOUT_params)
    self.createButton(toggleExpansionEXCLUDE_params)
    self.createButton(splitDiscardFACEDOWN_params)
    self.createButton(setupBaseGame_params)
    self.createButton(setupCampaignGame_params)
    self.createButton(customSetup_params)

end

function toggle_leaders(obj, color, alt_click)
    local toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_leaders", toggle)

    if (toggle) then
        self.editButton(toggleLeadersWITH_params)
    else
        self.editButton(toggleLeadersWITHOUT_params)
    end
end

function toggle_expansion()
    local toggle = Global.getVar("with_more_to_explore")

    toggle = not toggle
    Global.setVar("with_more_to_explore", toggle)

    if (toggle) then
        self.editButton(toggleExpansionINCLUDE_params)
    else
        self.editButton(toggleExpansionEXCLUDE_params)
    end
end

function toggle_split_discard()
    local is_faceup_active = ActionCards.toggle_face_up_discard()
    if (is_faceup_active) then
        self.editButton(splitDiscardFACEUP_params)
    else
        self.editButton(splitDiscardFACEDOWN_params)
    end
end

function setup_base_game()
    local base_setup_success = BaseGame.setup(Global.getVar("with_leaders"),
        Global.getVar("with_more_to_explore"))

    if (base_setup_success and Global.getVar("with_leaders")) then
        leader_buttons()
        return
    end

    if (base_setup_success) then
        -- TODO Delete self
        destroyObject(self)
    end

end

function setup_leaders()

    if BaseGame.setup_leaders() == false then
        broadcastToAll("\nPlace chosen leader near player board to continue.", {
            r = 1,
            g = 0,
            b = 0
        })
        return
    end

    -- TODO Delete self
    destroyObject(self)
end

function setup_campaign()
    local campaign_setup_success = Campaign.setup(Global.getVar("with_leaders"),
        Global.getVar("with_more_to_explore"))

    if (campaign_setup_success) then
        -- TODO Delete self
        destroyObject(self)
    end
end

function custom_setup()
    Campaign.components_visibility(true)
    BaseGame.components_visibility({
        is_visible = true,
        is_campaign = true,
        is_4p = true,
        leaders_and_lore = true,
        leaders_and_lore_expansion = true
    })

    local active_players = Global.call("getOrderedPlayers")
    if (#active_players < 2 or #active_players > 4) then
        return false
    end

    for _, p in pairs(active_players) do
        ArcsPlayer.setup(p, true)
    end
    Counters.setup()

    local reach_board = getObjectFromGUID(Global.getVar("reach_board_GUID"))
    reach_board.setDescription("in progress")
    destroyObject(self)
end

function leader_buttons()
    self.setPositionSmooth({49.5, 1.2, 0})

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
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
    self.editButton({
        index = 3,
        font_size = 88,
        click_function = "setup_leaders",
        label = "Setup Leaders",
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

function doNothing()
end

return SetupControl
