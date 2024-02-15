require("src/GUIDs")
local LOG = require("src/LOG")
local resource = require("src/Resource")

local Merchant = {
    ambition_pos = {
        material = {-0.76, 1.00, -0.83},
        fuel = {-0.76, 1.00, -0.62},
        weapon = {-0.76, 1.00, 0.05},
        relic = {-0.76, 1.00, 0.43},
        psionic = {-0.76, 1.00, 0.83}
    }
}

function Merchant:setup(clusters)
    local board = getObjectFromGUID(reach_board_GUID)
    local ABC = {
        "a",
        "b",
        "c"
    }
    for _, cluster in pairs(clusters) do
        for _, system in pairs(ABC) do
            local merch_resource = resource:getSystem(cluster, system)
            local pos = board.positionToWorld(self.ambition_pos[merch_resource])
            resource:take(merch_resource, pos).addTag("Merchant")
        end
    end
end

return Merchant