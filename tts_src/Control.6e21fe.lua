local Campaign = require("src/Campaign")
local BaseGame = require("src/BaseGame")

control_GUID = Global.getVar("control_GUID")

-- font_color = {0.8, 0.58, 0.27}, GOLD
local blue = {0.4, 0.6, 0.6}

local toggleLeaders_params = {
    index = 0,
    click_function = "toggleLeaders",
    function_owner = self,
    label = "Play\nWITHOUT\nLeaders & Lore",
    position = {0, 0.5, -1.17},
    width = 820,
    height = 260,
    font_size = 72,
    scale = {1, 1, 1},
    color = {0.85, 0.3, 0.2},
    font_color = {0, 0, 0},
    tooltip = "Recommended for beginners"
}

local toggleExpansion_params = {
    index = 1,
    click_function = "toggleExpansion",
    function_owner = self,
    label = "EXCLUDE\nLeaders & Lore\nExpansion",
    position = {-0.45, 0.5, -0.59},
    width = 440,
    height = 260,
    font_size = 60,
    scale = {1, 1, 1},
    color = {0.85, 0.3, 0.2},
    tooltip = "Exclude additional Leaders & Lore"
}

local splitDiscard_params = {
    index = 5,
    function_owner = self,
    click_function = "toggleSplitDiscard",
    label = "Discard\nFACEDOWN",
    position = {0.45, 0.5, -0.59},
    width = 440,
    height = 260,
    font_size = 60,
    scale = {1, 1, 1},
    color = {0.85, 0.3, 0.2}
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

local dealHand_params = {
    index = 1,
    height = 260,
    width = 820,
    position = {0, 0.5, -0.59},
    click_function = "dealHand",
    label = "Deal Hand",
    tooltip = "",
    font_size = 90,
    font_color = {0, 0, 0},
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local cleanupCards_params = {
    index = 2,
    height = 260,
    width = 820,
    click_function = "cleanupCards",
    label = "Cleanup Cards",
    tooltip = "",
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

local takeInitiative_params = {
    index = 3,
    height = 260,
    width = 820,
    click_function = "takeInitiative",
    label = "Take Initiative",
    tooltip = "",
    font_size = 90,
    color = {0.4, 0.6, 0.6},
    hover_color = {0.34, 0.38, 0.38}
}

function onload()
    self.createButton(toggleLeaders_params)
    self.createButton(toggleExpansion_params)
    self.createButton(setupBaseGame_params)
    self.createButton(setupCampaignGame_params)
    self.createButton(showControls_params)
    self.createButton(splitDiscard_params)
end

function toggleLeaders()
    local toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_leaders", toggle)

    if (toggle) then
        self.editButton({
            index = 0,
            color = {0.28, 0.52, 0.18},
            label = "Play\nWITH\nLeaders & Lore",
            tooltip = "Recommended for experienced players"
        })
    else
        self.editButton({
            index = 0,
            color = {0.85, 0.3, 0.2},
            label = "Play\nWITHOUT\nLeaders & Lore",
            tooltip = "Recommended for beginners"
        })
    end
end

function toggleExpansion()
    local toggle = Global.getVar("with_more_to_explore")

    toggle = not toggle
    Global.setVar("with_more_to_explore", toggle)

    if (toggle) then
        self.editButton({
            index = 1,
            color = {0.28, 0.52, 0.18},
            label = "INCLUDE\nLeaders & Lore\nExpansion",
            tooltip = "Include additional Leaders & Lore"
        })
    else
        self.editButton({
            index = 1,
            color = {0.85, 0.3, 0.2},
            label = "EXCLUDE\nLeaders & Lore\nExpansion",
            tooltip = "Exclude additional Leaders & Lore"
        })
    end
end

function toggleSplitDiscard()
    local toggle = Global.getVar("with_split_discard")

    toggle = not toggle
    Global.setVar("with_split_discard", toggle)

    if (toggle) then
        self.editButton({
            index = 5,
            color = {0.28, 0.52, 0.18},
            label = "Discard\nFACEUP",
            tooltip = "Include additional Leaders & Lore"
        })
    else
        self.editButton({
            index = 5,
            color = {0.85, 0.3, 0.2},
            label = "Discard\nFACEDOWN",
            tooltip = "Exclude additional Leaders & Lore"
        })
    end
end

function setupBaseGame()
    local base_setup_success = BaseGame.setup()

    if (base_setup_success) then
        setControlButtons()
        print("setup success")
    elseif (Global.getVar("with_leaders")) then
        setLeaderControls()
    end
end

function placeStartingPieces()
    BaseGame.dispersePlayerPieces()

    setControlButtons()
end

function setupCampaignGame()
    local campaign_setup_success = Campaign.setup()

    if (campaign_setup_success) then
        setControlButtons()
    end
end

function toggleControls()

    local purple_grey = {0.2, 0.22, 0.33}
    local blue = {0.4, 0.6, 0.6}

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
            color = blue,
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
            color = blue,
            font_color = {0, 0, 0},
            hover_color = {0.34, 0.38, 0.38}
        })
    end

end

function setStartupButtons()
    self.editButton(toggleLeaders_params)
    self.editButton(toggleExpansion_params)
    self.editButton(setupBaseGame_params)
    self.editButton(setupCampaignGame_params)
    self.editButton(showControls_params)
    self.editButton(splitDiscard_params)
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
        click_function = "placeStartingPieces",
        label = "Place Starting Pieces",
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
    print("test1")
    self.editButton(controls_params)
    print("test2")
    self.editButton(dealHand_params)
    print("test3")
    self.editButton(cleanupCards_params)
    print("test4")
    self.editButton(takeInitiative_params)
    print("test5")
    self.editButton({
        index = 5,
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    })
    if (not showing_controls) then
        print("test6")
        self.editButton({
            index = 4,
            height = 1,
            width = 1,
            click_function = "doNothing",
            label = "",
            tooltip = ""
        })
    end
    print("test7")
end

function doNothing()
end

function dealHand()

    -- TODO: check each hand to see if theres cards then error
    -- if condition then
    -- end

    broadcastToAll("Shuffle and deal 6 cards to all players")

    local action_deck = getObjectFromGUID(Global.getVar(
        "action_deck_GUID"))

    action_deck.randomize()

    Wait.time(function()
        action_deck.deal(6)
    end, 0.5)
end

function cleanupCards()
    -- ambition marker
    local ambition_marker_zone = getObjectFromGUID(Global.getVar(
        "ambition_marker_zone_GUID"))
    local marker_zone_pos = ambition_marker_zone.getPosition()

    -- resources

    local action_card_zone = getObjectFromGUID(Global.getVar(
        "action_card_zone_GUID"))
    local action_zone_objects = action_card_zone.getObjects()
    local action_deck_pos = getObjectFromGUID(Global.getVar(
        "action_deck_GUID")).getPosition()

    -- Error on union card
    for i, obj in ipairs(action_zone_objects) do
        if obj.getTags()[2] == "Union" then
            broadcastToAll("Resolve Union card before cleanup!", {
                r = 1,
                g = 0,
                b = 0
            })
            return
        end
    end

    -- clean up
    broadcastToAll("Cleanup action card area")
    for i, obj in ipairs(action_zone_objects) do
        if obj.getTags()[1] == "Action" then
            -- action cards
            obj.setPositionSmooth({action_deck_pos.x,
                                   action_deck_pos.y + 1,
                                   action_deck_pos.z})
            obj.setRotationSmooth({0.00, 90.00, 180.00})
        elseif obj.getTags()[1] == "AmbitionDeclared" then
            -- ambition marker
            obj.setPositionSmooth(marker_zone_pos)
            obj.setRotationSmooth({0.00, 180.00, 180.00})
        elseif obj.getTags()[1] == "Resource" then
            -- resources 
            -- TODO: move to respective supply
        end
    end

end

function takeInitiative(objectButtonClicked, playerColorClicked)

    broadcastToAll(playerColorClicked .. " takes initiative")
    Global.call("takeInitiative", playerColorClicked)

end
