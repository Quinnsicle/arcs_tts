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
    position = Vector({0.60, 0.00, 0.00}) + UI_POS,
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
    position = Vector({1.20, 0.00, 0.00}) + UI_POS,
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
    position = Vector({-0.70, 0.00, 0.30}) + UI_POS,
    width = 650,
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
    position = Vector({0.70, 0.00, 0.30}) + UI_POS,
    width = 650,
    height = 130,
    font_size = 72,
    scale = {1, 1, 1},
    color = {0.8, 0.8, 0.8},
    font_color = {0, 0, 0}
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

function DiceBoard.RollDice()
    for _, die in pairs(DiceBoard.GetDiePool()) do
        die.randomize()
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

    for r = 1, r_ct do
        local pos_x = (r_space * r - r_space / 2) - r_shift
        for c = 1, c_ct do
            local pos_z = (c_space * c - c_space / 2) - c_shift
            table.insert(grid, {
                x = pos_x,
                y = pos_y,
                z = pos_z
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
