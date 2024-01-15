local LayoutTools = {}

-- Arcs Player Colors {"White", "Yellow", "Red", "Teal"}

local player_boards = {
    ["white"]   = "999dbd",
    ["Yellow"]  = "5aa44c",
    ["Red"]     = "c0c8a1",
    ["Teal"]    = "ae512a"
}

local cities_layout = {
    {-0.255,0.978,-0.828},
    {-0.628,0.978,-0.829},
    {0.117,0.978,-0.828},
    {0.366,0.978,-0.828},
    {-0.876,0.978,-0.829}
}

local resource_layout = {
{0.863,0.209,-0.741},
{0.614,0.209,-0.742},
{0.365,0.209,-0.742},
{-0.381,0.209,-0.743},
{0.116,0.209,-0.742},
{-0.132,0.209,-0.742}
}

function LayoutTools.repositionSet()
    local board = getObjectFromGUID("ae512a")
    for ct,object in ipairs(getObjectsWithTag("pos_find")) do
        local pos = resource_layout[ct]; pos = board.positionToWorld(pos)
        object.setPosition(pos)
    end
end

return LayoutTools