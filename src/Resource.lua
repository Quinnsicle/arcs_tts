require("src/GUIDs")
local LOG = require("src/LOG")

local Resource = {
    supplies = {
        psionic = getObjectFromGUID(resources_GUID["psionics"]),
        relic = getObjectFromGUID(resources_GUID["relics"]),
        weapon = getObjectFromGUID(resources_GUID["weapons"]),
        fuel = getObjectFromGUID(resources_GUID["fuel"]),
        material = getObjectFromGUID(resources_GUID["materials"])

    },
    clusters = {
        {
            ["a"] = "weapon", 
            ["b"] = "fuel", 
            ["c"] = "material"
        },
        {
            ["a"] = "psionic", 
            ["b"] = "weapon", 
            ["c"] = "relic"
        },
        {
            ["a"] = "material", 
            ["b"] = "fuel", 
            ["c"] = "weapon"
        },
        {
            ["a"] = "relic", 
            ["b"] = "fuel", 
            ["c"] = "material"
        },
        {
            ["a"] = "weapon", 
            ["b"] = "relic", 
            ["c"] = "psionic"
        },
        {
            ["a"] = "material", 
            ["b"] = "fuel", 
            ["c"] = "psionic"
        }
    },
    merchant_pos ={
        material = {-0.76, 1.00, -0.83},
        fuel = {-0.76, 1.00, -0.62},
        weapon = {-0.76, 1.00, 0.05},
        relic = {-0.76, 1.00, 0.43},
        psionic = {-0.76, 1.00, 0.83}
    }
}

function Resource:take(name, pos)
    LOG.DEBUG("name:" .. name)
    return self.supplies[name].takeObject({
        position = pos,
        smooth = true
    })
end

function Resource:getSystem(cluster, system)
    return self.clusters[cluster][system]
end

return Resource
