local ArcsPlayer = require("src/ArcsPlayer")
local ActionCards = require("src/ActionCards")
local BaseGame = require("src/BaseGame")
local Campaign = require("src/Campaign")
local Counters = require("src/Counters")

local gold = {0.8, 0.58, 0.27}
local HEADER_FONT_SIZE = 170
local HEADER_SCALE = {0.6, 0.6, 0.6}
local HEADER_WIDTH = 0
local HEADER_HEIGHT = 0
local BUTTON_FONT_SIZE = 140
local BUTTON_SCALE = {0.3, 0.6, 0.6}
local BUTTON_WIDTH = 1500
local BUTTON_HEIGHT = 380

local optionsText_params = {
    click_function = "doNothing",
    function_owner = self,
    label = "Options",
    tooltip = "Toggle the below options to modify the game setup",
    position = {-0.52, 0.5, -1.15},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = HEADER_FONT_SIZE,
    scale = HEADER_SCALE,
    color = {0.05, 0.05, 0.05},
    font_color = gold,
}

local toggleLeadersWITHOUT_params = {
    index = 1,
    click_function = "toggle_leaders",
    function_owner = self,
    label = " Leaders & Lore ",
    tooltip = "Enable Leaders & Lore mode for base game (8 leaders, 14 lore)",
    position = {-0.51, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = {0.8, 0.3, 0.2},
    font_color = {0, 0, 0}
}
local toggleLeadersWITH_params = {
    index = 1,
    click_function = "toggle_leaders",
    function_owner = self,
    label = " Leaders & Lore ",
    tooltip = "Disable Leaders & Lore mode for base game",
    position = {-0.51, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = {0.2, 0.5, 0.2},
    font_color = {0, 0, 0}
}
local toggleExpansionEXCLUDE_params = {
    index = 2,
    click_function = "toggle_expansion",
    function_owner = self,
    label = "Leaders & Lore\nExpansion Pack",
    tooltip = "Enable Leaders & Lore Expansion Pack (16 total leaders, 28 total lore)",
    position = {-0.51, 0.5, 0},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = {0.8, 0.3, 0.2}
}
local toggleExpansionINCLUDE_params = {
    index = 2,
    click_function = "toggle_expansion",
    function_owner = self,
    label = "Leaders & Lore\nExpansion Pack",
    tooltip = "Disable Leaders & Lore Expansion Pack",
    position = {-0.51, 0.5, 0},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = {0.3, 0.5, 0.2}
}
local splitDiscardFACEDOWN_params = {
    index = 3,
    function_owner = self,
    click_function = "toggle_split_discard",
    label = "Split\nDiscard Piles",
    tooltip = "Reveal face-up played action cards to all players throughout the game",
    position = {-0.51, 0.5, 0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = {0.8, 0.3, 0.2}
}
local splitDiscardFACEUP_params = {
    index = 3,
    function_owner = self,
    click_function = "toggle_split_discard",
    label = "Split\nDiscard Piles",
    tooltip = "Use single face-down discard pile for action cards",
    position = {-0.51, 0.5, 0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = {0.3, 0.5, 0.2}
}
local miniaturesDISABLED_params = {
    index = 4,
    function_owner = self,
    click_function = "toggle_miniatures",
    label = "Miniatures",
    tooltip = "Enable Miniatures",
    position = {-0.51, 0.5, 1.17},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = {0.8, 0.3, 0.2}
}
local miniaturesENABLED_params = {
    index = 4,
    function_owner = self,
    click_function = "toggle_miniatures",
    label = "Miniatures",
    tooltip = "Disable Miniatures",
    position = {-0.51, 0.5, 1.17},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = {0.3, 0.5, 0.2}
}
local setupStartGame_params = {
    click_function = "doNothing",
    function_owner = self,
    label = "Start",
    tooltip = "Once all players have joined, and options are set",
    position = {0.52, 0.5, -1.15},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = HEADER_FONT_SIZE,
    scale = HEADER_SCALE,
    color = {0.05, 0.05, 0.05},
    font_color = gold,
}
local setupBaseGame_params = {
    index = 6,
    click_function = "setup_base_game",
    function_owner = self,
    label = "Base Game \nSetup",
    position = {0.52, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = {0.7, 0.7, 0.7},
    font_color = black,
    hover_color = {0.5, 0.3, 0.7}
}
local setupCampaignGame_params = {
    index = 7,
    click_function = "setup_campaign",
    function_owner = self,
    label = "Campaign \nSetup",
    position = {0.52, 0.5, 0},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = {0.7, 0.7, 0.7},
    font_color = black,
    hover_color = {0.5, 0.3, 0.7}
}
local customSetup_params = {
    index = 8,
    function_owner = self,
    click_function = "custom_setup",
    label = "Manual \nSetup",
    tooltip = "",
    position = {0.52, 0.5, 0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = {0.7, 0.7, 0.7},
    font_color = black,
    hover_color = {0.5, 0.3, 0.7}
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
    self.createButton(optionsText_params)
    self.createButton(toggleLeadersWITHOUT_params)
    self.createButton(toggleExpansionEXCLUDE_params)
    self.createButton(splitDiscardFACEDOWN_params)
    self.createButton(miniaturesDISABLED_params)
    self.createButton(setupStartGame_params)
    self.createButton(setupBaseGame_params)
    self.createButton(setupCampaignGame_params)
    self.createButton(customSetup_params)
end

function toggle_leaders(obj, color, alt_click)
    local toggle = Global.getVar("with_leaders")
    local expansion_toggle = Global.getVar("with_more_to_explore")

    toggle = not toggle
    Global.setVar("with_leaders", toggle)

    if (toggle) then
        self.editButton(toggleLeadersWITH_params)
    else
        self.editButton(toggleLeadersWITHOUT_params)
        if expansion_toggle then
            toggle_expansion()
        end
    end
end

function toggle_expansion()
    local toggle = Global.getVar("with_more_to_explore")
    local leaders_toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_more_to_explore", toggle)

    if (toggle) then
        self.editButton(toggleExpansionINCLUDE_params)
        if not leaders_toggle then
            Global.setVar("with_leaders", true)
            self.editButton(toggleLeadersWITH_params)
        end
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

function toggle_miniatures()
    local toggle = Global.getVar("with_miniatures")
    toggle = not toggle 
    Global.setVar("with_miniatures", toggle)
    if (toggle) then
        self.editButton(miniaturesENABLED_params)
        -- Hide meeples, show miniatures
        BaseGame.miniatures_visibility(true)
    else
        self.editButton(miniaturesDISABLED_params)
        -- Show meeples, hide miniatures
        BaseGame.miniatures_visibility(false)
    end
end

function setup_base_game()
    local base_setup_success = BaseGame.setup(Global.getVar("with_leaders"),
        Global.getVar("with_more_to_explore"),
        Global.getVar("with_miniatures"))

    if (base_setup_success and Global.getVar("with_leaders")) then
        leader_buttons()
        return
    end

    if (base_setup_success) then
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

    destroyObject(self)
end

function setup_campaign()
    local campaign_setup_success = Campaign.setup(Global.getVar("with_leaders"),
        Global.getVar("with_more_to_explore"),
        Global.getVar("with_miniatures"))

    if (campaign_setup_success) then
        destroyObject(self)
    end
end

function custom_setup()
    Global.call("setup_custom_game")
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
