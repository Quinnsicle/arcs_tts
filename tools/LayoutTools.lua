local LayoutTools = {}

-- Arcs Player Colors {"White", "Yellow", "Red", "Teal"}

local player_boards = {
    ["white"]   = "999dbd",
    ["Yellow"]  = "5aa44c",
    ["Red"]     = "c0c8a1",
    ["Teal"]    = "ae512a"
}

-- City snaps on play board
local cities_layout = {
    {-0.255,0.978,-0.828},
    {-0.628,0.978,-0.829},
    {0.117,0.978,-0.828},
    {0.366,0.978,-0.828},
    {-0.876,0.978,-0.829}
}

-- Resource snaps on player boards
local resource_layout = {
    {0.863,0.209,-0.741},
    {0.614,0.209,-0.742},
    {0.365,0.209,-0.742},
    {-0.381,0.209,-0.743},
    {0.116,0.209,-0.742},
    {-0.132,0.209,-0.742}
}

-- Agent snaps above court cards
local court_agent_layout = {
    {-0.75,0.825,-2.5}, 
    {-0.45,0.825,-2.5},
    {-0.15,0.825,-2.5},  
    {0.15,0.825,-2.5}, 
    {0.45,0.825,-2.5}, 
    {0.75,0.825,-2.5}, 
    {-0.75,0.825,-1.9}, 
    {-0.45,0.825,-1.9}, 
    {-0.15,0.825,-1.9},
    {0.15,0.825,-1.9},
    {0.45,0.825,-1.9},  
    {0.75,0.825,-1.9}
}

function LayoutTools.repositionSet()
    local board = getObjectFromGUID("89ddf3")
    for ct,object in ipairs(getObjectsWithTag("pos_find")) do
        local pos = court_agent_layout[ct]; pos = board.positionToWorld(pos)
        object.setPosition(pos)
    end
end

return LayoutTools