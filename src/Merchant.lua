local Merchant = {}

local cluster_resources = {
    { "Weapon",    "Fuel",    "Material"  },
    { "Psionic",   "Weapon",  "Relic"     },
    { "Material",  "Fuel",    "Weapon"    },
    { "Relic",     "Fuel",    "Material"  },
    { "Weapon",    "Relic",   "Psionic"   },
    { "Material",  "Fuel",    "Psionic"   }
}
  
local ambitions_positions = {
    ["Material"]  =   {-0.76, 1.00, -0.83},
    ["Fuel"]      =   {-0.76, 1.00, -0.62},
    ["Weapon"]    =   {-0.76, 1.00, 0.05},
    ["Relic"]     =   {-0.76, 1.00, 0.43},
    ["Psionic"]   =   {-0.76, 1.00, 0.83}
}

local resource_stacks = {
    ["Material"]  =   getObjectFromGUID(Global.getVar("resources_GUID")["materials"]),
    ["Fuel"]      =   getObjectFromGUID(Global.getVar("resources_GUID")["fuel"]),
    ["Weapon"]    =   getObjectFromGUID(Global.getVar("resources_GUID")["weapons"]),
    ["Relic"]     =   getObjectFromGUID(Global.getVar("resources_GUID")["relics"]),
    ["Psionic"]   =   getObjectFromGUID(Global.getVar("resources_GUID")["psionics"])
}

local board = getObjectFromGUID(Global.getVar("reach_board_GUID"))

function Merchant.setup(clusters)
    for _,cluster in pairs(clusters) do
        for _,resource in pairs(cluster_resources[cluster]) do
            local pos = board.positionToWorld(ambitions_positions[resource])
            resource_stacks[resource].takeObject({ position = pos }).addTag("Merchant")
        end
    end
end

return Merchant