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
    }
}

function Resource:takeNamed(name, pos)
    LOG.DEBUG("name:" .. name)
    self.supplies[name].takeObject({
        position = pos,
        smooth = true
    })
end

function Resource:takeSystem(cluster, system, pos)
    LOG.DEBUG("cluster:" .. cluster)
    LOG.DEBUG("system:" .. system)
    self.supplies[self.clusters[cluster][system]].takeObject({
        position = pos,
        smooth = true
    })
end

return Resource
