local DiceBoard = {}

local DICE_BOARD = self

local MESSAGE_COLOR = {
    ["skirmish"] = {0.31, 0.49, 0.51},
    ["skirmish_hover"] = {0.41, 0.59, 0.61},
    ["assault"] = {0.51, 0.15, 0.11},
    ["assault_hover"] = {0.61, 0.25, 0.21},
    ["raid"] = {0.82, 0.45, 0.18},
    ["raid_hover"] = {0.92, 0.55, 0.28}
}

-- UI Variables--
local UI_POS = Vector({0.00, 0.20, 1.20})
local CAMPAIGN_UI_POS = Vector({-1.75, 0.20, -1.20})

local UI_skirmish = {
    click_function = "SpawnSkirmishDie",
    function_owner = DICE_BOARD,
    label = "Skirmish",
    position = Vector({-1.20, 0.00, 0.00}) + UI_POS,
    width = 310,
    height = 130,
    font_size = 60,
    scale = {1, 1, 1},
    color = MESSAGE_COLOR["skirmish"],
    hover_color = MESSAGE_COLOR["skirmish_hover"],
    font_color = {0, 0, 0}
}

local UI_assault = {
    click_function = "SpawnAssaultDie",
    function_owner = DICE_BOARD,
    label = "Assault",
    position = Vector({-0.60, 0.00, 0.00}) + UI_POS,
    width = 310,
    height = 130,
    font_size = 60,
    scale = {1, 1, 1},
    color = MESSAGE_COLOR["assault"],
    hover_color = MESSAGE_COLOR["assault_hover"],
    font_color = {0, 0, 0}
}

local UI_raid = {
    click_function = "SpawnRaidDie",
    function_owner = DICE_BOARD,
    label = "Raid",
    position = Vector({0.00, 0.00, 0.00}) + UI_POS,
    width = 310,
    height = 130,
    font_size = 60,
    scale = {1, 1, 1},
    color = MESSAGE_COLOR["raid"],
    hover_color = MESSAGE_COLOR["raid_hover"],
    font_color = {0, 0, 0}
}

local UI_cluster = {
    click_function = "SpawnClusterDie",
    function_owner = DICE_BOARD,
    label = "Cluster",
    position = Vector({1.20, 0.00, 0.00}) + CAMPAIGN_UI_POS,
    width = 310,
    height = 130,
    font_size = 60,
    scale = {1, 1, 1},
    color = {0.1, 0.1, 0.1},
    font_color = {1, 1, 1}
}

local UI_event = {
    click_function = "SpawnEventDie",
    function_owner = DICE_BOARD,
    label = "Event",
    position = Vector({0.60, 0.00, 0.00}) + CAMPAIGN_UI_POS,
    width = 310,
    height = 130,
    font_size = 60,
    scale = {1, 1, 1},
    color = {0.1, 0.1, 0.1},
    font_color = {1, 1, 1}
}

local UI_roll = {
    click_function = "RollDice",
    function_owner = DICE_BOARD,
    label = "Roll",
    position = Vector({0.95, 0.00, 0.00}) + UI_POS,
    width = 600,
    height = 130,
    font_size = 72,
    scale = {1, 1, 1},
    color = {0.8, 0.8, 0.8},
    font_color = {0, 0, 0}
}

local UI_reset = {
    click_function = "ClearDice",
    function_owner = DICE_BOARD,
    label = "Reset",
    position = Vector({0.95, 0.00, 0.35}) + UI_POS,
    width = 450,
    height = 130,
    font_size = 72,
    scale = {1, 1, 1},
    color = {0.1, 0.1, 0.1},
    font_color = {0.7, 0.7, 0.7}
}

-- Dice Layout --
local GRID_COMBAT = {
    area = {
        x = 2.00,
        y = 5.00,
        z = 3.00
    },
    rows = 6,
    columns = 3
}

local GRID_SPECIAL = {
    area = {
        x = 2.00,
        y = 5.00,
        z = 3.00
    },
    rows = 2,
    columns = 1
}

-- Functional Variables --
local TAG = "Spawned Die"

local SCALE_COMBAT = {1.50, 1.50, 1.50}
local SCALE_SPECIAL = {2.50, 2.50, 2.50}

local MAX_COMBAT = 6
local MAX_SPECIAL = 1
local AUTO_CALC_CHECK_INTERVAL_SECONDS = 0.25
local AUTO_CALC_REQUIRED_STABLE_CHECKS = 2
local AUTO_CALC_ROLL_THRESHOLD = 0.05
local AUTO_CALC_ANGULAR_THRESHOLD = 0.05
local auto_calculate_after_roll = false
local auto_calculate_roll_token = 0
local context_menu_added = false

local DICE = {
    ["skirmish"] = {
        custom = {
            image = "https://dl.dropboxusercontent.com/s/3kr0xkvssrwuckb/bombard-die.png",
            type = 1
        },
        scale = SCALE_COMBAT,
        max = MAX_COMBAT
    },
    ["assault"] = {
        custom = {
            image = "https://dl.dropboxusercontent.com/s/6g633hq8t6ba403/asssault-die.png",
            type = 1
        },
        scale = SCALE_COMBAT,
        max = MAX_COMBAT
    },
    ["raid"] = {
        custom = {
            image = "https://dl.dropboxusercontent.com/s/m777tcc1unmox8w/raid-die.png",
            type = 1
        },
        scale = SCALE_COMBAT,
        max = MAX_COMBAT
    },
    ["cluster"] = {
        custom = {
            image = "https://dl.dropboxusercontent.com/s/n7e0c4gpdxyz3aw/number-die.png",
            type = 1
        },
        scale = SCALE_SPECIAL,
        max = MAX_SPECIAL
    },
    ["event"] = {
        custom = {
            image = "https://dl.dropboxusercontent.com/s/nor7ic5s9r20pfv/icon-die.png",
            type = 1
        },
        scale = SCALE_SPECIAL,
        max = MAX_SPECIAL
    }
}

-- Image URLs for each combat die type.
local skirmishDieImage = "https://dl.dropboxusercontent.com/s/3kr0xkvssrwuckb/bombard-die.png"
local assaultDieImage = "https://dl.dropboxusercontent.com/s/6g633hq8t6ba403/asssault-die.png"
local raidDieImage = "https://dl.dropboxusercontent.com/s/m777tcc1unmox8w/raid-die.png"

local function get_broadcast_color(color_name)
    local ok, col = pcall(function() return Color.fromString(color_name) end)
    if ok and col and type(col) == "table" then
        return col
    end
    return {1, 1, 1}
end

local function vector_magnitude(v)
    if type(v) ~= "table" then
        return 0
    end
    local x = v.x or v[1] or 0
    local y = v.y or v[2] or 0
    local z = v.z or v[3] or 0
    return math.sqrt((x * x) + (y * y) + (z * z))
end

local function is_die_moving(die)
    if not die or (die.isDestroyed and die.isDestroyed()) then
        return false
    end

    local linear_speed = 0
    local angular_speed = 0
    local resting = nil

    pcall(function()
        if die.getVelocity then
            linear_speed = vector_magnitude(die.getVelocity())
        end
    end)

    pcall(function()
        if die.getAngularVelocity then
            angular_speed = vector_magnitude(die.getAngularVelocity())
        end
    end)

    pcall(function()
        if die.resting ~= nil then
            resting = die.resting
        end
    end)

    if resting == false then
        return true
    end

    return linear_speed > AUTO_CALC_ROLL_THRESHOLD or angular_speed > AUTO_CALC_ANGULAR_THRESHOLD
end

function DiceBoard.AreDiceStillRolling()
    local dice = DiceBoard.GetDiePool()
    for _, die in ipairs(dice) do
        if is_die_moving(die) then
            return true
        end
    end
    return false
end

function DiceBoard.ScheduleAutoCalculateAfterRoll(token, player_color)
    local stable_checks = 0

    local function poll()
        if token ~= auto_calculate_roll_token then
            return
        end

        if DiceBoard.AreDiceStillRolling() then
            stable_checks = 0
        else
            stable_checks = stable_checks + 1
            if stable_checks >= AUTO_CALC_REQUIRED_STABLE_CHECKS then
                DiceBoard.UpdateDiceValues(player_color)
                return
            end
        end

        Wait.time(poll, AUTO_CALC_CHECK_INTERVAL_SECONDS)
    end

    Wait.time(poll, AUTO_CALC_CHECK_INTERVAL_SECONDS)
end

function DiceBoard.UpdateDiceValues(player_color)
    local turn_color = nil
    pcall(function()
        if Turns and Turns.turn_color and Turns.turn_color ~= "" then
            turn_color = Turns.turn_color
        end
    end)
    local broadcast_color = get_broadcast_color(turn_color or player_color)
    local totalSelfHits = 0
    local totalIntercepts = 0
    local totalHits = 0
    local totalBuildingHits = 0
    local totalKeys = 0

    local dice = getAllObjects()
    for _, die in ipairs(dice) do
        if die and die.tag == "Dice" then
            local customData = nil
            pcall(function() customData = die.getCustomObject() end)
            if customData ~= nil then
                local texture = customData.image
                local roll = nil
                pcall(function() roll = die.getValue() end)

                if texture == skirmishDieImage then
                    if roll == 1 or roll == 3 or roll == 6 then
                        totalHits = totalHits + 1
                    end
                elseif texture == assaultDieImage then
                    if roll == 1 then
                        totalHits = totalHits + 2
                        totalSelfHits = totalSelfHits + 1
                    elseif roll == 4 then
                        totalHits = totalHits + 1
                        totalSelfHits = totalSelfHits + 1
                    elseif roll == 5 then
                        totalHits = totalHits + 1
                        totalIntercepts = totalIntercepts + 1
                    elseif roll == 6 then
                        totalHits = totalHits + 1
                        totalSelfHits = totalSelfHits + 1
                    elseif roll == 3 then
                        totalHits = totalHits + 2
                    end
                elseif texture == raidDieImage then
                    if roll == 1 then
                        totalBuildingHits = totalBuildingHits + 1
                        totalSelfHits = totalSelfHits + 1
                    elseif roll == 2 then
                        totalKeys = totalKeys + 2
                        totalIntercepts = totalIntercepts + 1
                    elseif roll == 3 then
                        totalKeys = totalKeys + 1
                        totalBuildingHits = totalBuildingHits + 1
                    elseif roll == 4 then
                        totalSelfHits = totalSelfHits + 1
                        totalKeys = totalKeys + 1
                    elseif roll == 5 then
                        totalIntercepts = totalIntercepts + 1
                    elseif roll == 6 then
                        totalBuildingHits = totalBuildingHits + 1
                        totalSelfHits = totalSelfHits + 1
                    end
                end
            end
        end
    end

    broadcastToAll("-------------------", broadcast_color)
    broadcastToAll("Self-Hits: " .. totalSelfHits, broadcast_color)
    broadcastToAll("Intercepts: " .. totalIntercepts, broadcast_color)
    broadcastToAll("-------------------", broadcast_color)
    broadcastToAll("Hits: " .. totalHits, broadcast_color)
    broadcastToAll("Building Hits: " .. totalBuildingHits, broadcast_color)
    broadcastToAll("-------------------", broadcast_color)
    broadcastToAll("Keys: " .. totalKeys, broadcast_color)
    broadcastToAll("-------------------", broadcast_color)
end

function DiceBoard.AddCalculatorContextMenu()
    if context_menu_added then
        return
    end
    DICE_BOARD.addContextMenuItem("Chat Results", function(player_color)
        DiceBoard.UpdateDiceValues(player_color)
    end)
    DICE_BOARD.addContextMenuItem("Toggle Chat Auto", function(player_color)
        auto_calculate_after_roll = not auto_calculate_after_roll
        local status = auto_calculate_after_roll and "ON" or "OFF"
        broadcastToAll("Dice Board auto-calculate after roll: " .. status, get_broadcast_color(player_color))
    end)
    context_menu_added = true
end

function DiceBoard.setup(object)
    DICE_BOARD.createButton(UI_skirmish)
    DICE_BOARD.createButton(UI_assault)
    DICE_BOARD.createButton(UI_raid)
    DICE_BOARD.createButton(UI_cluster)
    DICE_BOARD.createButton(UI_event)
    DICE_BOARD.createButton(UI_roll)
    DICE_BOARD.createButton(UI_reset)
    spawns_combat = DiceBoard.CreatePositioningGrid(GRID_COMBAT)
    spawns_special = DiceBoard.CreatePositioningGrid(GRID_SPECIAL)
    DiceBoard.ClearDice()
    DiceBoard.AddCalculatorContextMenu()
end

function DiceBoard.SpawnCombatDie(type)

    if is_special then
        DiceBoard.ClearDice()
        is_special = not is_special
    end

    local die = DICE[type]
    if die_count[die] == die.max then
        broadcastToAll("\nMaximum " .. type .. " dice reached.",
            MESSAGE_COLOR[type])
        return
    else
        DiceBoard.SpawnDie(die, spawns_combat)
    end

end

function DiceBoard.SpawnSpecialDie(type)

    if not is_special then
        DiceBoard.ClearDice()
        is_special = not is_special
    end

    local die = DICE[type]
    if die_count[die] == die.max then
        return
    else
        DiceBoard.SpawnDie(die, spawns_special)
    end

end

function DiceBoard.SpawnDie(die, spawn_points)

    local pos = spawn_points[#DiceBoard.GetDiePool() + 1];
    pos = DICE_BOARD.positionToWorld(pos)
    die_count[die] = die_count[die] and die_count[die] + 1 or 1

    local new_die = spawnObject({
        type = "Custom_Dice",
        position = pos,
        scale = die.scale
    })
    new_die.setCustomObject(die.custom)
    new_die.addTag(TAG)

end

function DiceBoard.RollDice(player_color)
    auto_calculate_roll_token = auto_calculate_roll_token + 1
    for _, die in pairs(DiceBoard.GetDiePool()) do
        die.randomize()
    end
    if auto_calculate_after_roll then
        DiceBoard.ScheduleAutoCalculateAfterRoll(auto_calculate_roll_token, player_color)
    end
end

function DiceBoard.ClearDice()
    for _, die in pairs(DiceBoard.GetDiePool()) do
        die.destruct()
    end
    die_count = {}
end

function DiceBoard.GetDiePool()
    return getObjectsWithTag(TAG)
end

function DiceBoard.CreatePositioningGrid(parems)
    local r_ct, c_ct = parems.rows, parems.columns
    local r_space, c_space = parems.area.z / (parems.rows),
        parems.area.x / (parems.columns)
    local r_shift, c_shift = parems.area.z / 2, parems.area.x / 2

    local grid = {}
    local pos_y = parems.area.y

    local row_order
    if r_ct == 2 then  
        row_order = {2, 1}  -- Reversed order for campaign dice
    else  -- Combat dice spawn order (center to edge)
        row_order = {3, 4, 2, 5, 1, 6}
    end

    for _, r in ipairs(row_order) do
        local pos_x = (r_space * r - r_space / 2) - r_shift
        for c = 1, c_ct do
            local pos_z = (c_space * c - c_space / 2) - c_shift
            table.insert(grid, {
                x = pos_x,
                y = pos_y,
                z = pos_z,
                row = r,
                col = c
            })
        end
    end

    return grid
end

-- Begin Object Code --
function onLoad()
    DiceBoard.setup()
end
function SpawnSkirmishDie()
    DiceBoard.SpawnCombatDie("skirmish")
end
function SpawnAssaultDie()
    DiceBoard.SpawnCombatDie("assault")
end
function SpawnRaidDie()
    DiceBoard.SpawnCombatDie("raid")
end
function SpawnClusterDie()
    DiceBoard.SpawnSpecialDie("cluster")
end
function SpawnEventDie()
    DiceBoard.SpawnSpecialDie("event")
end
function RollDice()
    DiceBoard.RollDice()
end
function ClearDice()
    DiceBoard.ClearDice()
end
-- End Object Code --

return DiceBoard
