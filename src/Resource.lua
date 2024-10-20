require("src/GUIDs")
local LOG = require("src/LOG")

local Resource = {
    supply_tiles = {
        psionic = resources_markers_GUID["psionics"],
        relic = resources_markers_GUID["relics"],
        weapon = resources_markers_GUID["weapons"],
        fuel = resources_markers_GUID["fuel"],
        material = resources_markers_GUID["materials"]
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

    -- perform a raycast to find the topmost resource on the supply tile
    local supply_tile = getObjectFromGUID(self.supply_tiles[name:lower()])
    local hits = Physics.cast(
        {
            origin = supply_tile.getPosition() + Vector(0, -1, 0),
            direction = Vector(0,1,0),
            type = 1
        }
    )

    -- reverse iterate to get the top-most resource first
    local result = nil
    for i = #hits, 1, -1 do
        if hits[i].hit_object.getName():lower() == name:lower() and not hits[i].hit_object.isSmoothMoving() then
            result = hits[i].hit_object
            break
        end
    end

    -- early out if there's no resources in the supply
    if result == nil then
        return result
    end

    if result.getQuantity() ~= -1 then
        result = result.takeObject({
            position = pos,
            rotation = {0, 180, 0},
            smooth = true
        })
    else
        if pos ~= nil then
            result.setPositionSmooth(pos, false, true)
        end
        result.setRotationSmooth({0, 180, 0}, false, true)
    end
    return result
end

function Resource:name_from_cluster(cluster, system)
    if (system) then
        return self.clusters[cluster][system]
    else
        return self.clusters[cluster]
    end
end

return Resource
