-----------------------------------------------------
--- Inspired by Lauren's Dice Calculator   
-----------------------------------------------------

local DIE_IMAGES = {
    SKIRMISH = "https://dl.dropboxusercontent.com/s/3kr0xkvssrwuckb/bombard-die.png",
    ASSAULT = "https://dl.dropboxusercontent.com/s/6g633hq8t6ba403/asssault-die.png",
    RAID = "https://dl.dropboxusercontent.com/s/m777tcc1unmox8w/raid-die.png"
}

local UPDATE_INTERVAL = 0.25
local DIE_TYPE_CACHE = {}
local displayObjects = {}
local lastResults = nil

local function findDiceCounterObjects()
    displayObjects = {}
    for _, obj in ipairs(getAllObjects()) do
        if obj.hasTag("DiceCounter") then
            table.insert(displayObjects, obj)
        end
    end
end

local function resultsChanged(newResults)
    if not lastResults then return true end
    
    for key, value in pairs(newResults) do
        if lastResults[key] ~= value then
            return true
        end
    end
    return false
end

local function getDieType(die)
    local customData = die.getCustomObject()
    if not customData or not customData.image then
        return nil
    end
    
    local imageToType = {
        [DIE_IMAGES.SKIRMISH] = "SKIRMISH",
        [DIE_IMAGES.ASSAULT] = "ASSAULT",
        [DIE_IMAGES.RAID] = "RAID"
    }
    
    return imageToType[customData.image]
end

local SKIRMISH_RESULTS = {
    [1] = {hits = 1},
    [3] = {hits = 1},
    [6] = {hits = 1}
}

local ASSAULT_RESULTS = {
    [1] = {hits = 2, selfHits = 1},
    [3] = {hits = 2},
    [4] = {hits = 1, selfHits = 1},
    [5] = {hits = 1, intercepts = 1},
    [6] = {hits = 1, selfHits = 1}
}

local RAID_RESULTS = {
    [1] = {buildingHits = 1, selfHits = 1},
    [2] = {keys = 2, intercepts = 1},
    [3] = {keys = 1, buildingHits = 1},
    [4] = {selfHits = 1, keys = 1},
    [5] = {intercepts = 1},
    [6] = {buildingHits = 1, selfHits = 1}
}

local function newResults()
    return {
        selfHits = 0,
        intercepts = 0,
        hits = 0,
        buildingHits = 0,
        keys = 0
    }
end

-- Get all dice objects on the table
local function getAllDice()
    local dice = {}
    local objects = getAllObjects()
    
    for _, obj in ipairs(objects) do
        if obj.tag == "Dice" then
            table.insert(dice, obj)
        end
    end
    return dice
end

local function processDieRoll(dieType, roll, results)
    local resultTable
    if dieType == "SKIRMISH" then
        resultTable = SKIRMISH_RESULTS[roll]
    elseif dieType == "ASSAULT" then
        resultTable = ASSAULT_RESULTS[roll]
    elseif dieType == "RAID" then
        resultTable = RAID_RESULTS[roll]
    end
    
    if resultTable then
        for key, value in pairs(resultTable) do
            results[key] = results[key] + value
        end
    end
end

local function calculateResults()
    local dice = getAllDice()
    if #dice == 0 then
        return nil
    end

    local results = newResults()

    for _, die in ipairs(dice) do
        local dieType = getDieType(die)
        if dieType then
            local roll = die.getValue()
            processDieRoll(dieType, roll, results)
        end
    end

    return results
end

local function displayResults(results)
    for _, display_obj in ipairs(displayObjects) do
        display_obj.clearButtons()
        
        local result_displays = {
            {label = results.selfHits, pos = {x = 0.33, y = 0.11, z = -0.65}},
            {label = results.intercepts, pos = {x = 0.33, y = 0.11, z = -0.42}},
            {label = results.hits, pos = {x = 0.33, y = 0.11, z = 0.25}},
            {label = results.buildingHits, pos = {x = 0.33, y = 0.11, z = 0.47}},
            {label = results.keys, pos = {x = 0.33, y = 0.11, z = 0.89}}
        }

        for _, display in ipairs(result_displays) do
            if display.label > 0 then
                -- Create shadow button (white text slightly offset to make the black text pop)
                display_obj.createButton({
                    click_function = "doNothing",
                    function_owner = self,
                    label = display.label,
                    position = {x = display.pos.x + 0.01, y = display.pos.y, z = display.pos.z + 0.01},
                    rotation = {0, 0, 0},
                    width = 0,
                    height = 0,
                    font_size = 115,
                    font_color = {1, 1, 1},
                    font_style = "Bold"
                })
            end

            -- Create main button (black or grey based on display.label value)
            display_obj.createButton({
                click_function = "doNothing",
                function_owner = self,
                label = display.label,
                position = display.pos,
                rotation = {0, 0, 0},
                width = 0,
                height = 0,
                font_size = 110,
                font_color = display.label > 0 and {0, 0, 0} or {0.8, 0.8, 0.8},
                font_style = "Bold"
            })
        end
    end
end

function onLoad()
    -- Initial search for display objects
    findDiceCounterObjects()
    Wait.time(function() updateDiceCounts() end, UPDATE_INTERVAL, -1)
end

function updateDiceCounts()
    local results = calculateResults()
    if results and resultsChanged(results) then
        displayResults(results)
        lastResults = results
    end
end

-- Add event handlers in case the counter is cloned or destroyed
function onObjectSpawn(obj)
    if obj.hasTag("DiceCounter") then
        findDiceCounterObjects()
    end
end

function onObjectDestroy(obj)
    if obj.hasTag("DiceCounter") then
        findDiceCounterObjects()
    end
end
