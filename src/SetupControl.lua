local ArcsPlayer = require("src/ArcsPlayer")
local ActionCards = require("src/ActionCards")
local BaseGame = require("src/BaseGame")
local Campaign = require("src/Campaign")
local Counters = require("src/Counters")

local GOLD = {0.8, 0.58, 0.27}
local BLACK = {0.05, 0.05, 0.05}
local GREEN = {0.2, 0.5, 0.2}
local PURPLE = {0.5, 0.3, 0.7}
local RED = {0.8, 0.3, 0.2}
local LIGHT_GREY = {0.8, 0.8, 0.8}
local HEADER_FONT_SIZE = 170
local HEADER_SCALE = {0.6, 0.6, 0.6}
local HEADER_WIDTH = 0
local HEADER_HEIGHT = 0
local BUTTON_FONT_SIZE = 140
local BUTTON_SCALE = {0.3, 0.6, 0.6}
local BUTTON_WIDTH = 1500
local BUTTON_HEIGHT = 380

local setupTableImageOptions = {
    {
        name = "Default",
        diffuse = "https://steamusercontent-a.akamaihd.net/ugc/15297536227112862/B09A1DE0302BFED6AFF653116F56B110B73F024B/"
    },
    {
        name = "Planets 1",
        diffuse = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/tablemaker/combined_1.png"
    },
    {
        name = "Planets 2",
        diffuse = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/tablemaker/combined_2.png"
    },
    {
        name = "Planets 3",
        diffuse = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/tablemaker/combined_3.png"
    },
    {
        name = "Planets 4",
        diffuse = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/tablemaker/combined_4.png"
    },
    {
        name = "Planets 5",
        diffuse = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/tablemaker/combined_5.png"
    },
    {
        name = "Beyond",
        diffuse = "https://raw.githubusercontent.com/Laurens1234/arcs_ttslaurens/refs/heads/main/assets/tablemaker/Beyond_1.png"
    },
}

local setupBackgroundOptions = {
    {
        name = "Custom Sky",
        kind = "custom",
        value = "https://steamusercontent-a.akamaihd.net/ugc/2128570108363703240/7C119AE30B36149F36C42DFD03F43566BD5E18EC/"
    }
}

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
    color = BLACK,
    font_color = GOLD,
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
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
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
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
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
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
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
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
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
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
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
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local miniaturesDISABLED_params = {
    index = 4,
    function_owner = self,
    click_function = "toggle_miniatures",
    label = "Miniatures",
    tooltip = "Enable Miniatures",
    position = {-0.51, 0.5, 1.16},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local miniaturesENABLED_params = {
    index = 4,
    function_owner = self,
    click_function = "toggle_miniatures",
    label = "Miniatures",
    tooltip = "Disable Miniatures",
    position = {-0.51, 0.5, 1.16},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}

local toggleLaurensEXCLUDE_params = {
    index = 9,
    click_function = "toggle_laurens_custom",
    function_owner = self,
    label = " Celestial Leaders\n Expansion",
    tooltip = "Include Celestial Leaders Expansion made by Laurens https://laurens1234.github.io/arcs-arsenal/custom-cards",
    position = {-1.54, 0.5, 2.32},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local toggleLaurensINCLUDE_params = {
    index = 9,
    click_function = "toggle_laurens_custom",
    function_owner = self,
    label = "Celestial Leaders\n Expansion",
    tooltip = "Exclude Celestial Leaders Expansion made by Laurens https://laurens1234.github.io/arcs-arsenal/custom-cards",
    position = {-1.54, 0.5, 2.32},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local toggleDontUseBasePackEXCLUDE_params = {
    index = 10,
    click_function = "toggle_dont_use_base_pack",
    function_owner = self,
    label = " Don't use\n Base & Pack Leaders",
    tooltip = "Remove base and pack leaders from setup",
    position = {-1.54, 0.5, 1.16},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = RED
}
local toggleDontUseBasePackINCLUDE_params = {
    index = 10,
    click_function = "toggle_dont_use_base_pack",
    function_owner = self,
    label = " Don't use\n Base & Pack Leaders",
    tooltip = "Restore base and pack leaders in setup",
    position = {-1.54, 0.5, 1.16},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = RED,
    font_color = BLACK,
    hover_color = GREEN
}
local leaderCountDec_params = {
    index = 11,
    click_function = "leader_count_dec",
    function_owner = self,
    label = "-",
    tooltip = "Decrease leader draft count",
    position = {-1.85, 0.5, 0},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = RED,
    font_color = BLACK,
    hover_color = PURPLE
}
local leaderCountDisplay_params = {
    index = 12,
    click_function = "doNothing",
    function_owner = self,
    label = "",
    tooltip = "Leader draft count",
    position = {-1.54, 0.5, 0},
    width = 300,
    height = 220,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = BLACK,
    font_color = GOLD
}
local leaderCountInc_params = {
    index = 13,
    click_function = "leader_count_inc",
    function_owner = self,
    label = "+",
    tooltip = "Increase leader draft count",
    position = {-1.23, 0.5, 0},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local loreCountDec_params = {
    index = 14,
    click_function = "lore_count_dec",
    function_owner = self,
    label = "-",
    tooltip = "Decrease lore draft count",
    position = {-1.85, 0.5, 0.59},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = RED,
    font_color = BLACK,
    hover_color = PURPLE
}
local loreCountDisplay_params = {
    index = 15,
    click_function = "doNothing",
    function_owner = self,
    label = "",
    tooltip = "Lore draft count",
    position = {-1.54, 0.5, 0.59},
    width = 300,
    height = 220,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = BLACK,
    font_color = GOLD
}
local loreCountInc_params = {
    index = 16,
    click_function = "lore_count_inc",
    function_owner = self,
    label = "+",
    tooltip = "Increase lore draft count",
    position = {-1.23, 0.5, 0.59},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local setDefault_params = {
    index = 17,
    click_function = "set_default_counts",
    function_owner = self,
    label = "Set default\nL&L count",
    tooltip = "Set Leaders and Lore to player_count + 1",
    position = {-1.54, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = PURPLE
}
local setupChoice_params = {
    index = 21,
    click_function = "cycle_setup_choice",
    function_owner = self,
    label = "Setup: Random",
    tooltip = "Cycle chosen setup for current player count (Random -> option -> ... -> Random)",
    position = {-2.56, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = PURPLE
}
local setupTableImage_params = {
    index = 27,
    click_function = "cycle_setup_table_image",
    function_owner = self,
    label = "Table Image:\nDefault",
    tooltip = "Choose the table surface",
    position = {-2.56, 0.5, 1.18},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = PURPLE
}

local setupBackground_params = {
    index = 31,
    click_function = "cycle_setup_background",
    function_owner = self,
    label = "Background:\nSky Field",
    tooltip = "Choose the sky/background image",
    position = {-2.56, 0.5, 0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = PURPLE
}

local setupTableBrightnessDec_params = {
    index = 28,
    click_function = "setup_table_brightness_dec",
    function_owner = self,
    label = "-",
    tooltip = "Decrease setup table brightness",
    position = {-2.87, 0.5, 1.77},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = RED,
    font_color = BLACK,
    hover_color = PURPLE
}
local setupTableBrightnessDisplay_params = {
    index = 29,
    click_function = "doNothing",
    function_owner = self,
    label = "Brightness:\n1.00",
    tooltip = "Current setup table brightness",
    position = {-2.56, 0.5, 1.77},
    width = 600,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = BLACK,
    font_color = GOLD
}
local setupTableBrightnessInc_params = {
    index = 30,
    click_function = "setup_table_brightness_inc",
    function_owner = self,
    label = "+",
    tooltip = "Increase setup table brightness",
    position = {-2.25, 0.5, 1.77},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local initiativeChoice_params = {
    index = 22,
    click_function = "cycle_initiative_choice",
    function_owner = self,
    label = "Initiative: Random",
    tooltip = "Choose which player color gets initiative at game start (Random -> player -> ...)",
    position = {-2.56, 0.5, 0},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = PURPLE
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
    color = BLACK,
    font_color = GOLD,
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
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
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
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
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
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local toggleScavengersEXCLUDE_params = {
    index = 18,
    click_function = "toggle_scavengers",
    function_owner = self,
    label = "PnP#1 Scavengers\n & Scouts Deck",
    tooltip = "Include PnP#1 Scavengers & Scouts deck in setup intead of base court deck",
    position = {-0.51, 0.5, 2.32},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    -- border = {0.4235294117647059, 0.13725490196078433, 0.08627450980392157},
    hover_color = GREEN
}
local toggleScavengersINCLUDE_params = {
    index = 18,
    click_function = "toggle_scavengers",
    function_owner = self,
    label = "PnP#1 Scavengers\n & Scouts Deck",
    tooltip = "Exclude PnP#1 Scavengers & Scouts deck from setup",
    position = {-0.51, 0.5, 2.32},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local togglePnp3EXCLUDE_params = {
    index = 20,
    click_function = "toggle_pnp3_custom",
    function_owner = self,
    label = " PnP#3\n Fated Leaders",
    tooltip = "Include PnP#3 fated leader deck in setup",
    position = {-0.51, 0.5, 3.47},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local togglePnp3INCLUDE_params = {
    index = 20,
    click_function = "toggle_pnp3_custom",
    function_owner = self,
    label = " PnP#3\n Fated Leaders",
    tooltip = "Exclude PnP#3 fated leader deck from setup",
    position = {-0.51, 0.5, 3.47},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local togglePnp2EXCLUDE_params = {
    index = 19,
    click_function = "toggle_pnp2_custom",
    function_owner = self,
    label = " PnP#2\n Lost Vaults",
    tooltip = "Include PnP#2 Lost Vaults in setup",
    position = {-0.51, 0.5, 2.9},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local togglePnp2INCLUDE_params = {
    index = 19,
    click_function = "toggle_pnp2_custom",
    function_owner = self,
    label = " PnP#2\n Lost Vaults",
    tooltip = "Exclude PnP#2 Lost Vaults from setup",
    position = {-0.51, 0.5, 2.9},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}

local beyondTheReach_params = {
    index = 23,
    click_function = "doNothing",
    function_owner = self,
    label = "Beyond \nthe Reach",
    tooltip = "",
    position = {-0.51, 0.5, 1.77},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = HEADER_SCALE,
    color = BLACK,
    font_color = GOLD,
}
local celestial_params = {
    index = 24,
    click_function = "doNothing",
    function_owner = self,
    label = "Celestial",
    tooltip = "",
    position = {-1.54, 0.5, 1.77},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = HEADER_FONT_SIZE,
    scale = HEADER_SCALE,
    color = BLACK,
    font_color = GOLD,
}
local leader_lore_controls_header_params = {
    index = 25,
    click_function = "doNothing",
    function_owner = self,
    label = "L&L\nOptions",
    tooltip = "",
    position = {-1.54, 0.5, -1.15},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = HEADER_SCALE,
    color = BLACK,
    font_color = GOLD,
}
local setup_controls_header_params = {
    index = 26,
    click_function = "doNothing",
    function_owner = self,
    label = "Setup\nOptions",
    tooltip = "",
    position = {-2.56, 0.5, -1.15},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = HEADER_SCALE,
    color = BLACK,
    font_color = GOLD,
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
    -- compute sensible defaults for leader/lore counts so display buttons start with numbers
    local function initial_resolved_default_count()
        -- Count seated players whose colors are in `available_colors`
        local ordered = Global.call("getOrderedPlayers", {true}) or {}
        local n = 0
        local colors = available_colors or {"White", "Yellow", "Red", "Teal", "Pink"}
        for _, p in ipairs(ordered) do
            for _, c in ipairs(colors) do
                if p.color == c then
                    n = n + 1
                    break
                end
            end
        end
        if n >= 2 and n <= 5 then
            return n + 1
        end
        local dbg = Global.getVar("debug_player_count") or 3
        return dbg + 1
    end
    local stored_lcount = Global.getVar("leader_draft_count")
    local stored_locount = Global.getVar("lore_draft_count")
    leaderCountDisplay_params.label = "Leaders:\n" .. (stored_lcount and tostring(stored_lcount) or "Default")
    loreCountDisplay_params.label = "Lore:\n" .. (stored_locount and tostring(stored_locount) or "Default")

    self.createButton(optionsText_params)
    self.createButton(toggleLeadersWITHOUT_params)
    self.createButton(toggleExpansionEXCLUDE_params)
    self.createButton(splitDiscardFACEDOWN_params)
    self.createButton(miniaturesDISABLED_params)
    self.createButton(setupStartGame_params)
    self.createButton(setupBaseGame_params)
    self.createButton(setupCampaignGame_params)
    self.createButton(customSetup_params)
    self.createButton(toggleLaurensEXCLUDE_params)
    self.createButton(toggleDontUseBasePackEXCLUDE_params)
    -- Leader/Lore draft count controls
    self.createButton(leaderCountDec_params)
    self.createButton(leaderCountDisplay_params)
    self.createButton(leaderCountInc_params)
    self.createButton(loreCountDec_params)
    self.createButton(loreCountDisplay_params)
    self.createButton(loreCountInc_params)
    self.createButton(setDefault_params)
    self.createButton(toggleScavengersEXCLUDE_params)
    self.createButton(togglePnp2EXCLUDE_params)
    self.createButton(togglePnp3EXCLUDE_params)
    self.createButton(setupChoice_params)
    self.createButton(initiativeChoice_params)
    self.createButton(beyondTheReach_params)
    self.createButton(celestial_params)
    self.createButton(leader_lore_controls_header_params)
    self.createButton(setup_controls_header_params)
    self.createButton(setupTableImage_params)
    self.createButton(setupTableBrightnessDec_params)
    self.createButton(setupTableBrightnessDisplay_params)
    self.createButton(setupTableBrightnessInc_params)
    -- self.createButton(setupBackground_params)

    -- must add buttons in the order of the actual indices !!!!!!!!!! lowest in here must have highest index

    -- Initialize numeric display labels from globals (resolve default if nil)
    local function resolved_default_count()
        -- Prefer seated players in allowed `available_colors` for defaults
        local ordered = Global.call("getOrderedPlayers", {true}) or {}
        local n = 0
        local colors = available_colors or {"White", "Yellow", "Red", "Teal", "Pink"}
        for _, p in ipairs(ordered) do
            for _, c in ipairs(colors) do
                if p.color == c then
                    n = n + 1
                    break
                end
            end
        end
        if n >= 2 and n <= 5 then
            return n + 1
        end
        local dbg = Global.getVar("debug_player_count") or 3
        return dbg + 1
    end
    local lcount = Global.getVar("leader_draft_count")
    local locount = Global.getVar("lore_draft_count")
    -- Ensure buttons reflect stored values; show "Default" when unset
    if lcount then
        self.editButton({index=12, label = "Leaders:\n" .. tostring(lcount)})
    else
        self.editButton({index=12, label = "Leaders:\nDefault"})
    end
    if locount then
        self.editButton({index=15, label = "Lore:\n" .. tostring(locount)})
    else
        self.editButton({index=15, label = "Lore:\nDefault"})
    end
    -- Initialize setup choice display
    do
        local sc_index = Global.getVar("setup_choice_index") or 0
        local sc_pcount = Global.getVar("setup_choice_player_count")
        local active = Global.call("getOrderedPlayers", {true}) or Global.getTable("active_players") or Player.getPlayers() or {}
        local pcount = #active
        local display_label = "Setup: Random"
        if sc_index and sc_index >= 1 and sc_pcount == pcount then
            local opts = BaseGame.getSetupOptions(pcount) or {}
            if opts[sc_index] and opts[sc_index].name then
                display_label = "Setup: " .. tostring(sc_index) .. "\n" .. tostring(opts[sc_index].name)
            end
        end
        self.editButton({index=21, label = display_label})
    end
    -- Initialize table image display
    do
        local table_image_index = Global.getVar("setup_table_image_index") or 0
        local option = setupTableImageOptions[table_image_index + 1] or setupTableImageOptions[1]
        self.editButton({index=27, label = "Table Image:\n" .. tostring(option.name or "Default")})
    end
    -- Initialize brightness (default 1.0) and display
    do
        local b = Global.getVar("setup_table_brightness") or 1.0
        Global.setVar("setup_table_brightness", b)
        self.editButton({index=29, label = "Brightness:\n" .. string.format("%.2f", b)})
    end
    -- Initialize background display
    -- do
    --     local bg_name = "Sky Field"
    --     pcall(function()
    --         local custom_url = Backgrounds.getCustomURL()
    --         if custom_url and custom_url ~= "" then
    --             bg_name = "Custom Sky"
    --         else
    --             local current_bg = Backgrounds.getBackground()
    --             if current_bg and current_bg ~= "" then
    --                 bg_name = tostring(current_bg)
    --             end
    --         end
    --     end)
    --     self.editButton({index=31, label = "Background:\n" .. tostring(bg_name)})
    -- end
    -- Initialize initiative choice display
    do
        local ic_index = Global.getVar("initiative_choice_index") or 0
        local ic_pcount = Global.getVar("initiative_choice_player_count")
        local ic_color = Global.getVar("initiative_choice_color")
        local active = Global.call("getOrderedPlayers", {true}) or Global.getTable("active_players") or Player.getPlayers() or {}
        local pcount = #active
        local display_label = "Initiative: Random"
        if ic_color and ic_pcount == pcount then
            display_label = "Initiative: " .. tostring(ic_index) .. "\n" .. tostring(ic_color)
        elseif ic_index and ic_index >= 1 and ic_pcount == pcount then
            local colorname = (active[ic_index] and active[ic_index].color) or nil
            if colorname then
                display_label = "Initiative: " .. tostring(ic_index) .. "\n" .. tostring(colorname)
            end
        end
        self.editButton({index=22, label = display_label})
    end
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

function toggle_laurens_custom()
    local toggle = Global.getVar("with_laurens_custom_leader")
    local leaders_toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_laurens_custom_leader", toggle)

    if (toggle) then
        self.editButton(toggleLaurensINCLUDE_params)
        if not leaders_toggle then
            Global.setVar("with_leaders", true)
            self.editButton(toggleLeadersWITH_params)
        end
    else
        self.editButton(toggleLaurensEXCLUDE_params)
    end
end

function toggle_pnp2_custom()
    local toggle = Global.getVar("with_pnp2_lost_vaults")
    local leaders_toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_pnp2_lost_vaults", toggle)

    if (toggle) then
        self.editButton(togglePnp2INCLUDE_params)
        if not leaders_toggle then
            Global.setVar("with_leaders", true)
            self.editButton(toggleLeadersWITH_params)
        end
    else
        self.editButton(togglePnp2EXCLUDE_params)
    end
end

function toggle_pnp3_custom()
    local toggle = Global.getVar("with_pnp3_custom_leader")
    local leaders_toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_pnp3_custom_leader", toggle)

    if (toggle) then
        self.editButton(togglePnp3INCLUDE_params)
        if not leaders_toggle then
            Global.setVar("with_leaders", true)
            self.editButton(toggleLeadersWITH_params)
        end
    else
        self.editButton(togglePnp3EXCLUDE_params)
    end
end

function toggle_dont_use_base_pack()
    local toggle = Global.getVar("dont_use_base_and_pack_leaders")
    toggle = not toggle
    Global.setVar("dont_use_base_and_pack_leaders", toggle)

    if (toggle) then
        self.editButton(toggleDontUseBasePackINCLUDE_params)
    else
        self.editButton(toggleDontUseBasePackEXCLUDE_params)
    end
end

function toggle_scavengers()
    local toggle = Global.getVar("use_scavengers_scouts_deck")

    toggle = not toggle
    Global.setVar("use_scavengers_scouts_deck", toggle)

    if (toggle) then
        self.editButton(toggleScavengersINCLUDE_params)
        
    else
        self.editButton(toggleScavengersEXCLUDE_params)
    end
end
-- Leader/Lore draft count controls
-- Resolve a sensible default (player_count + 1) using active players or debug fallback
local function resolved_default_count()
    -- Prefer seated players in allowed `available_colors` for defaults
    local ordered = Global.call("getOrderedPlayers", {true}) or {}
    local n = 0
    local colors = available_colors or {"White", "Yellow", "Red", "Teal", "Pink"}
    for _, p in ipairs(ordered) do
        for _, c in ipairs(colors) do
            if p.color == c then
                n = n + 1
                break
            end
        end
    end
    if n >= 2 and n <= 5 then
        return n + 1
    end
    local dbg = Global.getVar("debug_player_count") or 3
    return dbg + 1
end

local function display_count_label(count)
    return tostring(count)
end

function change_leader_count(obj, color, delta)
    local current = Global.getVar("leader_draft_count")
    if not current then current = resolved_default_count() end
    local count = math.max(1, math.min(100, current + delta))
    Global.setVar("leader_draft_count", count)
    self.editButton({index=12, label="Leaders:\n" .. display_count_label(count)})
end

function change_lore_count(obj, color, delta)
    local current = Global.getVar("lore_draft_count")
    if not current then current = resolved_default_count() end
    local count = math.max(1, math.min(28, current + delta))
    Global.setVar("lore_draft_count", count)
    self.editButton({index=15, label="Lore:\n" .. display_count_label(count)})
end

function leader_count_dec(obj, color, alt_click)
    change_leader_count(obj, color, -1)
end

function leader_count_inc(obj, color, alt_click)
    change_leader_count(obj, color, 1)
end

function lore_count_dec(obj, color, alt_click)
    change_lore_count(obj, color, -1)
end

function lore_count_inc(obj, color, alt_click)
    change_lore_count(obj, color, 1)
end

function set_default_counts(obj, color, alt_click)
    local def = resolved_default_count()
    Global.setVar("leader_draft_count", def)
    Global.setVar("lore_draft_count", def)
    -- Update displays with prefixes
    self.editButton({index=12, label = "Leaders:\n" .. tostring(def)})
    self.editButton({index=15, label = "Lore:\n" .. tostring(def)})
end

function cycle_setup_choice(obj, color, alt_click)
    -- Determine active players (use ordered players if available)
    local active = Global.call("getOrderedPlayers", {true}) or Global.getTable("active_players") or Player.getPlayers() or {}
    local player_count = #active
    if player_count < 2 or player_count > 5 then
        broadcastToAll("Setup chooser requires 2-5 active players.", {r=1, g=0, b=0})
        return
    end

    local opts = BaseGame.getSetupOptions(player_count) or {}
    local N = #opts
    if N == 0 then
        broadcastToAll("No setup options configured for " .. tostring(player_count) .. " players", {r=1, g=0.5, b=0})
        return
    end

    local cur = Global.getVar("setup_choice_index") or 0
    local next_index = (cur + 1) % (N + 1) -- cycles 0..N (0 == random)
    Global.setVar("setup_choice_index", next_index)
    Global.setVar("setup_choice_player_count", player_count)

    local label
    if next_index == 0 then
        label = "Setup: Random"
    else
        local name = opts[next_index].name or tostring(next_index)
        label = "Setup: " .. "\n" .. tostring(name)
    end
    self.editButton({index=21, label = label})
end

local function get_setup_table_object()
    return getObjectFromGUID(setup_table_GUID)
end

local function get_setup_table_image_index()
    local index = Global.getVar("setup_table_image_index") or 0
    if index < 0 or index >= #setupTableImageOptions then
        return 0
    end
    return index
end

local function set_setup_table_noninteractable()
    local table_obj = get_setup_table_object()
    if not table_obj then
        return
    end

    table_obj.setLock(true)
    table_obj.interactable = false
end

local function apply_setup_table_tint(table_obj, option)
    if not table_obj then
        return
    end
    local base = (option and option.tint) or {r = 1, g = 1, b = 1}
    local brightness = Global.getVar("setup_table_brightness") or 1.0
    local final = {
        r = math.min(1, (base.r or 1) * brightness),
        g = math.min(1, (base.g or 1) * brightness),
        b = math.min(1, (base.b or 1) * brightness)
    }
    table_obj.setColorTint(final)
end

local function apply_setup_table_image(index)
    local table_obj = get_setup_table_object()
    if not table_obj then
        broadcastToAll("Setup table object not found.", {r=1, g=0, b=0})
        return false
    end

    local custom = table_obj.getCustomObject()
    if not custom then
        broadcastToAll("Setup table is not a custom model.", {r=1, g=0, b=0})
        return false
    end

    local option = setupTableImageOptions[index + 1] or setupTableImageOptions[1]
    custom.diffuse = option.diffuse
    table_obj.setCustomObject(custom)
    apply_setup_table_tint(table_obj, option)
    table_obj.reload()
    Wait.frames(function()
        set_setup_table_noninteractable()
    end, 1)
    return true
end

local function change_setup_table_brightness(delta)
    local cur = Global.getVar("setup_table_brightness") or 1.0
    local next = math.max(0, math.min(1, cur + delta))
    Global.setVar("setup_table_brightness", next)
    -- update display
    self.editButton({index=29, label = "Brightness:\n" .. string.format("%.2f", next)})
    -- reapply tint for current table option
    local idx = get_setup_table_image_index()
    local option = setupTableImageOptions[idx + 1] or setupTableImageOptions[1]
    local table_obj = get_setup_table_object()
    apply_setup_table_tint(table_obj, option)
end

function setup_table_brightness_dec(obj, color, alt_click)
    change_setup_table_brightness(-0.05)
end

function setup_table_brightness_inc(obj, color, alt_click)
    change_setup_table_brightness(0.05)
end

local function apply_setup_background(option)
    if not option then
        return false
    end

    local ok = false
    if option.kind == "custom" then
        ok = pcall(function()
            Backgrounds.setCustomURL(option.value)
        end)
    else
        ok = pcall(function()
            Backgrounds.setBackground(option.value)
        end)
    end

    if ok then
        Global.setVar("setup_background_index", option.kind == "custom" and 1 or 0)
        -- self.editButton({index=31, label = "Background:\n" .. tostring(option.name or option.value or "Sky Field")})
        return true
    end

    broadcastToAll("Could not update background image.", {r=1, g=0, b=0})
    return false
end

function cycle_setup_background(obj, color, alt_click)
    local current = Global.getVar("setup_background_index") or 0
    local next_index = (current + 1) % #setupBackgroundOptions
    if apply_setup_background(setupBackgroundOptions[next_index + 1]) then
        Global.setVar("setup_background_index", next_index)
    end
end

function cycle_setup_table_image(obj, color, alt_click)
    local current = get_setup_table_image_index()
    local next_index = (current + 1) % #setupTableImageOptions

    if apply_setup_table_image(next_index) then
        Global.setVar("setup_table_image_index", next_index)
        local option = setupTableImageOptions[next_index + 1] or setupTableImageOptions[1]
        self.editButton({index=27, label = "Table Image:\n" .. tostring(option.name or "Default")})
    end
end

function cycle_initiative_choice(obj, color, alt_click)
    local active = Global.call("getOrderedPlayers", {true}) or Global.getTable("active_players") or Player.getPlayers() or {}
    local player_count = #active
    if player_count < 2 or player_count > 5 then
        broadcastToAll("Initiative chooser requires 2-5 active players.", {r=1, g=0, b=0})
        return
    end

    local N = player_count
    local cur = Global.getVar("initiative_choice_index") or 0
    local next_index = (cur + 1) % (N + 1) -- cycles 0..N (0 == random)
    -- store both index and explicit color for robustness when players join/leave
    Global.setVar("initiative_choice_index", next_index)
    Global.setVar("initiative_choice_player_count", player_count)
    if next_index == 0 then
        Global.setVar("initiative_choice_color", nil)
    else
        local player = active[next_index]
        local color_name = (player and player.color) or nil
        Global.setVar("initiative_choice_color", color_name)
    end

    local label
    if next_index == 0 then
        label = "Initiative: Random"
    else
        local color_name = Global.getVar("initiative_choice_color") or tostring(next_index)
        label = "Initiative: " .. "\n" .. tostring(color_name)
    end
    self.editButton({index=22, label = label})
end

function setup_base_game()
    Global.setVar("is_basegame_setup", true)
    local base_setup_success = BaseGame.setup(Global.getVar("with_leaders"),
        Global.getVar("with_more_to_explore"),
        Global.getVar("with_miniatures"))

    if (base_setup_success and Global.getVar("with_leaders")) then
        Global.call("save_game_starting_players")
        local sc2obj = nil
        if setup_control_2 ~= nil then
            sc2obj = getObjectFromGUID(setup_control_2)
        end
        if sc2obj then
            destroyObject(sc2obj)
        end
        local sc3obj = nil
        if setup_control_3 ~= nil then
            sc3obj = getObjectFromGUID(setup_control_3)
        end
        if sc3obj then
            destroyObject(sc3obj)
        end
        leader_buttons()
        return
    end

    if (base_setup_success) then
        Global.call("save_game_starting_players")
        local sc2obj = nil
        if setup_control_2 ~= nil then
            sc2obj = getObjectFromGUID(setup_control_2)
        end
        if sc2obj then
            destroyObject(sc2obj)
        end
        local sc3obj = nil
        if setup_control_3 ~= nil then
            sc3obj = getObjectFromGUID(setup_control_3)
        end
        if sc3obj then
            destroyObject(sc3obj)
        end
        destroyObject(self)
    end

end

function setup_leaders()
   -- Global.setVar("is_basegame_setup", false)
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
    Global.setVar("is_basegame_setup", false)
    local campaign_setup_success = Campaign.setup(Global.getVar("with_leaders"),
        Global.getVar("with_more_to_explore"),
        Global.getVar("with_miniatures"))

    if (campaign_setup_success) then
        Global.call("save_game_starting_players")
        local sc2obj = nil
        if setup_control_2 ~= nil then
            sc2obj = getObjectFromGUID(setup_control_2)
        end
        if sc2obj then
            destroyObject(sc2obj)
        end
        local sc3obj = nil
        if setup_control_3 ~= nil then
            sc3obj = getObjectFromGUID(setup_control_3)
        end
        if sc3obj then
            destroyObject(sc3obj)
        end
        destroyObject(self)
    end
end

function custom_setup()
    Global.setVar("is_basegame_setup", false)
    Global.call("setup_custom_game")
    Global.call("save_game_starting_players")
    local sc2obj = nil
    if setup_control_2 ~= nil then
        sc2obj = getObjectFromGUID(setup_control_2)
    end
    if sc2obj then
        destroyObject(sc2obj)
    end
    local sc3obj = nil
    if setup_control_3 ~= nil then
        sc3obj = getObjectFromGUID(setup_control_3)
    end
    if sc3obj then
        destroyObject(sc3obj)
    end
    destroyObject(self)
end

function leader_buttons()
    self.setPositionSmooth({54.25, 1.2, 0})

    self.editButton({
        index = 2,
        click_function = "setup_leaders",
        label = "Setup Leaders",
        color = GREEN,
        font_color = BLACK,
        hover_color = PURPLE,
        tooltip = "Setup ship placements and acquire resources based on the leader detected to the left of each player board"
    })

    -- Clear all other buttons
    local empty_button = {
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    }

    for i = 0, 30 do
        if i ~= 2 then  -- Skip the leader button
            empty_button.index = i
            self.editButton(empty_button)
        end
    end
end

function doNothing()
end

return SetupControl