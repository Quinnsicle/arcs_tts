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
    clusters = {{
        ["a"] = "weapon",
        ["b"] = "fuel",
        ["c"] = "material"
    }, {
        ["a"] = "psionic",
        ["b"] = "weapon",
        ["c"] = "relic"
    }, {
        ["a"] = "material",
        ["b"] = "fuel",
        ["c"] = "weapon"
    }, {
        ["a"] = "relic",
        ["b"] = "fuel",
        ["c"] = "material"
    }, {
        ["a"] = "weapon",
        ["b"] = "relic",
        ["c"] = "psionic"
    }, {
        ["a"] = "material",
        ["b"] = "fuel",
        ["c"] = "psionic"
    }}
}

function Resource:take(name, pos)
    LOG.DEBUG("name:" .. name)
    return self.supplies[name].takeObject({
        position = pos,
        rotation = {0, 180, 0},
        smooth = true
    })
end

function Resource:name_from_cluster(cluster, system)
    if (system) then
        return self.clusters[cluster][system]
    else
        return self.clusters[cluster]
    end
end

return Resource
